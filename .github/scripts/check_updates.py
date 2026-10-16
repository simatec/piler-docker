#!/usr/bin/env python3
"""Check for new versions that Dependabot cannot detect and report them as issues.

Covered:
  - Piler release package (github.com/jsuto/piler), pinned in build/Dockerfile
  - MariaDB (MARIA_DB_VERSION in build/build.conf), patch updates of the current LTS line only
  - Images with a fixed tag in config/piler-default.yml and config/piler-ssl.yml

One issue (label "version-check") is kept per component: it is created when an update
is found, updated when an even newer version appears and closed once the repo is current.

Usage: check_updates.py [--dry-run]   (needs the gh CLI and GH_TOKEN unless --dry-run)
"""

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
COMPOSE_FILES = ["config/piler-default.yml", "config/piler-ssl.yml"]
LABEL = "version-check"
TITLE_PREFIX = "Update available: "
PILER_REPO = "jsuto/piler"


def http_get(url, headers=None):
    req = urllib.request.Request(url, headers={"User-Agent": "piler-docker-version-check", **(headers or {})})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read()


def http_json(url, headers=None):
    return json.loads(http_get(url, headers))


def github_json(path):
    headers = {"Accept": "application/vnd.github+json"}
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return http_json(f"https://api.github.com/{path}", headers)


def read_conf(path):
    """Read KEY="value" lines of a shell config file."""
    values = {}
    for line in (ROOT / path).read_text().splitlines():
        m = re.match(r'^\s*([A-Z_][A-Z0-9_]*)="?([^"#]*?)"?\s*$', line)
        if m:
            values[m.group(1)] = m.group(2)
    return values


def dockerfile_args():
    return dict(re.findall(r'^ARG (\w+)="([^"]*)"', (ROOT / "build/Dockerfile").read_text(), re.M))


def parse_version(tag):
    return tuple(int(p) for p in tag.split(".")) if re.fullmatch(r"\d+(\.\d+)*", tag) else None


def newest_tag(tags, current, same_minor=False):
    """Newest numeric tag with the same number of components as `current` (1.6 -> 1.7, not 1.6.45)."""
    cur = parse_version(current)
    if cur is None:
        return None
    candidates = [v for v in map(parse_version, tags) if v and len(v) == len(cur) and v > cur]
    if same_minor:
        candidates = [v for v in candidates if v[:2] == cur[:2]]
    return ".".join(map(str, max(candidates))) if candidates else None


def docker_hub_tags(image):
    repo = image if "/" in image else f"library/{image}"
    token = http_json(f"https://auth.docker.io/token?service=registry.docker.io&scope=repository:{repo}:pull")["token"]
    tags, url = [], f"https://registry-1.docker.io/v2/{repo}/tags/list?n=10000"
    while url:
        req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
        with urllib.request.urlopen(req, timeout=60) as resp:
            tags += json.loads(resp.read()).get("tags") or []
            link = re.search(r"<([^>]+)>", resp.headers.get("Link", ""))
        url = f"https://registry-1.docker.io{link.group(1)}" if link else None
    return tags


def check_piler():
    args = dockerfile_args()
    current, distro = args["PILER_VERSION"], args["PILER_DISTRO"]
    release = github_json(f"repos/{PILER_REPO}/releases/latest")
    latest = release["tag_name"].removeprefix("piler-")
    if not parse_version(latest) or parse_version(latest) <= parse_version(current):
        return "Piler", current, None, None

    lines = [
        f"A new Piler release is available: [{release['tag_name']}]({release['html_url']}).",
        "",
        f"Packages for `{distro}` (the distro of the base image in `build/Dockerfile`):",
        "",
    ]
    commit = None
    for arch in ("amd64", "arm64"):
        pattern = rf"piler_{re.escape(latest)}-{re.escape(distro)}-([0-9a-f]+)_{arch}\.deb"
        asset = next((a for a in release["assets"] if re.fullmatch(pattern, a["name"])), None)
        if not asset:
            lines.append(f"- {arch}: **no package found** - check whether the base image has to change")
            continue
        commit = re.fullmatch(pattern, asset["name"]).group(1)
        digest = (asset.get("digest") or "").removeprefix("sha256:")
        if not digest:
            digest = hashlib.sha256(http_get(asset["browser_download_url"])).hexdigest()
        lines.append(f"- `PILER_SHA256_{arch.upper()}=\"{digest}\"` ({asset['name']})")
    if commit:
        lines += ["", f"`PILER_VERSION=\"{latest}\"`, `PILER_COMMIT=\"{commit}\"`"]
    lines += [
        "",
        "Update the values in `build/Dockerfile`, `PILER_VERSION` in `build/build.conf` and",
        "`piler.conf.example` and the version table in `README.md`, then check the release notes",
        "for required migration steps.",
    ]
    return "Piler", current, latest, "\n".join(lines)


def check_mariadb():
    # Only patch releases of the current line: new major/minor lines are not necessarily LTS.
    current = read_conf("build/build.conf")["MARIA_DB_VERSION"]
    latest = newest_tag(docker_hub_tags("mariadb"), current, same_minor=True)
    body = latest and (
        f"MariaDB `{latest}` is available on [Docker Hub](https://hub.docker.com/_/mariadb).\n\n"
        "Update `MARIA_DB_VERSION` in `build/build.conf` and `piler.conf.example` and the version table in `README.md`."
    )
    return "MariaDB", current, latest, body


def compose_images():
    """{(image, tag): [files]} for images with a fixed tag (no ${VARIABLE})."""
    images = {}
    for path in COMPOSE_FILES:
        for image, tag in re.findall(r"^\s*image:\s*([^\s:$]+):([^\s$]+)\s*$", (ROOT / path).read_text(), re.M):
            images.setdefault((image, tag), []).append(path)
    return images


def check_image(image, tag, files):
    latest = newest_tag(docker_hub_tags(image), tag)
    hub = f"https://hub.docker.com/_/{image}" if "/" not in image else f"https://hub.docker.com/r/{image}"
    body = latest and (
        f"`{image}:{latest}` is available on [Docker Hub]({hub}).\n\n"
        f"Update the tag in {', '.join(f'`{f}`' for f in files)} and the version table in `README.md`."
    )
    return image, tag, latest, body


def gh(*args):
    return subprocess.run(["gh", *args], check=True, capture_output=True, text=True).stdout


def report(results, dry_run):
    if dry_run:
        for component, current, latest, body in results:
            print(f"\n=== {component}: {current} -> {latest or 'up to date'}")
            if body:
                print(body)
        return

    gh("label", "create", LABEL, "--color", "0366d6", "--description", "New upstream version available", "--force")
    open_issues = json.loads(gh("issue", "list", "--label", LABEL, "--state", "open", "--json", "number,title", "--limit", "200"))
    for component, current, latest, body in results:
        prefix = f"{TITLE_PREFIX}{component} "
        issue = next((i for i in open_issues if i["title"].startswith(prefix)), None)
        if latest:
            title = f"{prefix}{current} → {latest}"
            if issue is None:
                print(f"{component}: creating issue '{title}'")
                gh("issue", "create", "--title", title, "--body", body, "--label", LABEL)
            elif issue["title"] != title:
                print(f"{component}: updating issue #{issue['number']} to '{title}'")
                gh("issue", "edit", str(issue["number"]), "--title", title, "--body", body)
            else:
                print(f"{component}: issue #{issue['number']} already open")
        elif issue:
            print(f"{component}: up to date, closing issue #{issue['number']}")
            gh("issue", "close", str(issue["number"]), "--comment", f"{component} is up to date ({current}).")
        else:
            print(f"{component}: up to date ({current})")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dry-run", action="store_true", help="print the results instead of creating issues")
    opts = parser.parse_args()

    checks = [("Piler", check_piler), ("MariaDB", check_mariadb)]
    checks += [(i, lambda i=i, t=t, f=f: check_image(i, t, f)) for (i, t), f in compose_images().items()]

    results, failed = [], False
    for name, check in checks:
        try:
            results.append(check())
        except Exception as exc:  # keep checking the other components
            failed = True
            print(f"::error::{name}: version check failed: {exc}", file=sys.stderr)

    report(results, opts.dry_run)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
