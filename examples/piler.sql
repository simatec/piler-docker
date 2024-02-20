-- MariaDB dump 10.19  Distrib 10.6.17-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: mailpiler
-- ------------------------------------------------------
-- Server version	10.6.17-MariaDB-1:10.6.17+maria~ubu2004

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `archiving_rule`
--

DROP TABLE IF EXISTS `archiving_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archiving_rule` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `domain` varchar(128) DEFAULT NULL,
  `from` varchar(128) DEFAULT NULL,
  `to` varchar(128) DEFAULT NULL,
  `subject` varchar(128) DEFAULT NULL,
  `body` varchar(128) DEFAULT NULL,
  `_size` char(2) DEFAULT NULL,
  `size` int(11) DEFAULT 0,
  `attachment_name` varchar(128) DEFAULT NULL,
  `attachment_type` varchar(64) DEFAULT NULL,
  `_attachment_size` char(2) DEFAULT NULL,
  `attachment_size` int(11) DEFAULT 0,
  `spam` tinyint(1) DEFAULT -1,
  `days` int(11) DEFAULT 0,
  `folder_id` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `from` (`from`,`to`,`subject`,`body`,`_size`,`size`,`attachment_name`,`attachment_type`,`_attachment_size`,`attachment_size`,`spam`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archiving_rule`
--

LOCK TABLES `archiving_rule` WRITE;
/*!40000 ALTER TABLE `archiving_rule` DISABLE KEYS */;
/*!40000 ALTER TABLE `archiving_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attachment`
--

DROP TABLE IF EXISTS `attachment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attachment` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `piler_id` char(36) NOT NULL,
  `attachment_id` int(11) NOT NULL,
  `name` tinyblob DEFAULT NULL,
  `type` varchar(128) DEFAULT NULL,
  `sig` char(64) NOT NULL,
  `size` int(11) DEFAULT 0,
  `ptr` bigint(20) unsigned DEFAULT 0,
  `deleted` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `attachment_idx` (`piler_id`),
  KEY `attachment_idx2` (`sig`,`size`,`ptr`),
  KEY `attachment_idx3` (`ptr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attachment`
--

LOCK TABLES `attachment` WRITE;
/*!40000 ALTER TABLE `attachment` DISABLE KEYS */;
/*!40000 ALTER TABLE `attachment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit`
--

DROP TABLE IF EXISTS `audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ts` int(11) NOT NULL,
  `email` varchar(128) NOT NULL,
  `domain` varchar(128) NOT NULL,
  `action` int(11) NOT NULL,
  `ipaddr` varchar(39) NOT NULL,
  `meta_id` bigint(20) unsigned NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `vcode` char(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `audit_idx` (`email`),
  KEY `audit_idx2` (`action`),
  KEY `audit_idx3` (`ipaddr`),
  KEY `audit_idx4` (`ts`),
  KEY `audit_idx5` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit`
--

LOCK TABLES `audit` WRITE;
/*!40000 ALTER TABLE `audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `autosearch`
--

DROP TABLE IF EXISTS `autosearch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `autosearch` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query` varchar(512) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `autosearch`
--

LOCK TABLES `autosearch` WRITE;
/*!40000 ALTER TABLE `autosearch` DISABLE KEYS */;
/*!40000 ALTER TABLE `autosearch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `counter`
--

DROP TABLE IF EXISTS `counter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `counter` (
  `rcvd` bigint(20) unsigned DEFAULT 0,
  `virus` bigint(20) unsigned DEFAULT 0,
  `duplicate` bigint(20) unsigned DEFAULT 0,
  `ignore` bigint(20) unsigned DEFAULT 0,
  `size` bigint(20) unsigned DEFAULT 0,
  `stored_size` bigint(20) unsigned DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `counter`
--

LOCK TABLES `counter` WRITE;
/*!40000 ALTER TABLE `counter` DISABLE KEYS */;
INSERT INTO `counter` VALUES (0,0,0,0,0,0);
/*!40000 ALTER TABLE `counter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `counter_stats`
--

DROP TABLE IF EXISTS `counter_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `counter_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `domain` varchar(255) NOT NULL,
  `sent` int(11) NOT NULL,
  `recd` int(11) NOT NULL,
  `sentsize` int(11) NOT NULL,
  `recdsize` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `email` (`email`),
  KEY `domain` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `counter_stats`
--

LOCK TABLES `counter_stats` WRITE;
/*!40000 ALTER TABLE `counter_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `counter_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_settings`
--

DROP TABLE IF EXISTS `customer_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(128) NOT NULL,
  `branding_text` varchar(255) DEFAULT NULL,
  `branding_url` varchar(255) DEFAULT NULL,
  `branding_logo` varchar(255) DEFAULT NULL,
  `support_link` varchar(255) DEFAULT NULL,
  `background_colour` varchar(255) DEFAULT NULL,
  `text_colour` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_settings`
--

LOCK TABLES `customer_settings` WRITE;
/*!40000 ALTER TABLE `customer_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deleted`
--

DROP TABLE IF EXISTS `deleted`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deleted` (
  `id` bigint(20) unsigned NOT NULL,
  `requestor` varchar(128) NOT NULL,
  `reason1` varchar(128) NOT NULL,
  `date1` int(10) unsigned DEFAULT 0,
  `approver` varchar(128) DEFAULT NULL,
  `reason2` varchar(128) DEFAULT NULL,
  `date2` int(10) unsigned DEFAULT 0,
  `deleted` tinyint(1) DEFAULT -1,
  UNIQUE KEY `id` (`id`),
  KEY `id_2` (`id`),
  KEY `deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deleted`
--

LOCK TABLES `deleted` WRITE;
/*!40000 ALTER TABLE `deleted` DISABLE KEYS */;
/*!40000 ALTER TABLE `deleted` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `domain`
--

DROP TABLE IF EXISTS `domain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domain` (
  `domain` char(64) NOT NULL,
  `mapped` char(64) NOT NULL,
  `ldap_id` int(11) DEFAULT 0,
  PRIMARY KEY (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domain`
--

LOCK TABLES `domain` WRITE;
/*!40000 ALTER TABLE `domain` DISABLE KEYS */;
INSERT INTO `domain` VALUES ('local','local',0);
/*!40000 ALTER TABLE `domain` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `domain_user`
--

DROP TABLE IF EXISTS `domain_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domain_user` (
  `domain` char(64) NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  KEY `domain_user_idx` (`domain`),
  KEY `domain_user_idx2` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domain_user`
--

LOCK TABLES `domain_user` WRITE;
/*!40000 ALTER TABLE `domain_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `domain_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email`
--

DROP TABLE IF EXISTS `email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email` (
  `uid` int(10) unsigned NOT NULL,
  `email` char(128) NOT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email`
--

LOCK TABLES `email` WRITE;
/*!40000 ALTER TABLE `email` DISABLE KEYS */;
INSERT INTO `email` VALUES (0,'admin@local'),(1,'auditor@local');
/*!40000 ALTER TABLE `email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_groups`
--

DROP TABLE IF EXISTS `email_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_groups` (
  `uid` int(10) unsigned NOT NULL,
  `gid` int(10) unsigned NOT NULL,
  UNIQUE KEY `uid` (`uid`,`gid`),
  KEY `email_groups_idx` (`uid`,`gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_groups`
--

LOCK TABLES `email_groups` WRITE;
/*!40000 ALTER TABLE `email_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folder`
--

DROP TABLE IF EXISTS `folder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folder` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT 0,
  `name` char(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `parent_id` (`parent_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folder`
--

LOCK TABLES `folder` WRITE;
/*!40000 ALTER TABLE `folder` DISABLE KEYS */;
/*!40000 ALTER TABLE `folder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folder_extra`
--

DROP TABLE IF EXISTS `folder_extra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folder_extra` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL,
  `name` char(64) NOT NULL,
  UNIQUE KEY `uid` (`uid`,`name`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folder_extra`
--

LOCK TABLES `folder_extra` WRITE;
/*!40000 ALTER TABLE `folder_extra` DISABLE KEYS */;
/*!40000 ALTER TABLE `folder_extra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folder_message`
--

DROP TABLE IF EXISTS `folder_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folder_message` (
  `folder_id` bigint(20) NOT NULL,
  `id` bigint(20) NOT NULL,
  UNIQUE KEY `folder_id` (`folder_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folder_message`
--

LOCK TABLES `folder_message` WRITE;
/*!40000 ALTER TABLE `folder_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `folder_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folder_rule`
--

DROP TABLE IF EXISTS `folder_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folder_rule` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `domain` varchar(100) DEFAULT NULL,
  `from` varchar(100) DEFAULT NULL,
  `to` varchar(100) DEFAULT NULL,
  `subject` varchar(128) DEFAULT NULL,
  `body` varchar(128) DEFAULT NULL,
  `_size` char(2) DEFAULT NULL,
  `size` int(11) DEFAULT 0,
  `attachment_name` varchar(128) DEFAULT NULL,
  `attachment_type` varchar(64) DEFAULT NULL,
  `_attachment_size` char(2) DEFAULT NULL,
  `attachment_size` int(11) DEFAULT 0,
  `spam` tinyint(1) DEFAULT -1,
  `days` int(11) DEFAULT 0,
  `folder_id` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain` (`domain`,`from`,`to`,`subject`,`body`,`_size`,`size`,`attachment_name`,`attachment_type`,`_attachment_size`,`attachment_size`,`spam`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folder_rule`
--

LOCK TABLES `folder_rule` WRITE;
/*!40000 ALTER TABLE `folder_rule` DISABLE KEYS */;
/*!40000 ALTER TABLE `folder_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folder_user`
--

DROP TABLE IF EXISTS `folder_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folder_user` (
  `id` bigint(20) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  KEY `folder_user_idx` (`id`),
  KEY `folder_user_idx2` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folder_user`
--

LOCK TABLES `folder_user` WRITE;
/*!40000 ALTER TABLE `folder_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `folder_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `google`
--

DROP TABLE IF EXISTS `google`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `google` (
  `id` char(32) NOT NULL,
  `email` char(128) NOT NULL,
  `access_token` char(255) DEFAULT NULL,
  `refresh_token` char(255) DEFAULT NULL,
  `created` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `google`
--

LOCK TABLES `google` WRITE;
/*!40000 ALTER TABLE `google` DISABLE KEYS */;
/*!40000 ALTER TABLE `google` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `google_imap`
--

DROP TABLE IF EXISTS `google_imap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `google_imap` (
  `id` char(32) NOT NULL,
  `email` char(128) NOT NULL,
  `last_msg_id` bigint(20) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `google_imap`
--

LOCK TABLES `google_imap` WRITE;
/*!40000 ALTER TABLE `google_imap` DISABLE KEYS */;
/*!40000 ALTER TABLE `google_imap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_email`
--

DROP TABLE IF EXISTS `group_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_email` (
  `id` bigint(20) unsigned NOT NULL,
  `email` char(128) NOT NULL,
  KEY `group_email_idx` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_email`
--

LOCK TABLES `group_email` WRITE;
/*!40000 ALTER TABLE `group_email` DISABLE KEYS */;
/*!40000 ALTER TABLE `group_email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_user`
--

DROP TABLE IF EXISTS `group_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_user` (
  `id` bigint(20) unsigned NOT NULL,
  `email` char(128) NOT NULL,
  KEY `group_user_idx` (`id`),
  KEY `group_user_idx2` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_user`
--

LOCK TABLES `group_user` WRITE;
/*!40000 ALTER TABLE `group_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `group_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `import`
--

DROP TABLE IF EXISTS `import`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `server` varchar(255) NOT NULL,
  `created` int(11) DEFAULT 0,
  `started` int(11) DEFAULT 0,
  `finished` int(11) DEFAULT 0,
  `updated` int(11) DEFAULT 0,
  `status` int(11) DEFAULT 0,
  `total` int(11) DEFAULT 0,
  `imported` int(11) DEFAULT 0,
  `duplicate` int(11) DEFAULT 0,
  `error` int(11) DEFAULT 0,
  `cleared` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `import`
--

LOCK TABLES `import` WRITE;
/*!40000 ALTER TABLE `import` DISABLE KEYS */;
/*!40000 ALTER TABLE `import` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ldap`
--

DROP TABLE IF EXISTS `ldap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ldap` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL,
  `ldap_type` varchar(255) NOT NULL,
  `ldap_host` varchar(255) NOT NULL,
  `ldap_base_dn` varchar(255) NOT NULL,
  `ldap_bind_dn` varchar(255) NOT NULL,
  `ldap_bind_pw` varchar(255) NOT NULL,
  `ldap_auditor_member_dn` varchar(255) DEFAULT NULL,
  `ldap_mail_attr` varchar(128) DEFAULT NULL,
  `ldap_account_objectclass` varchar(128) DEFAULT NULL,
  `ldap_distributionlist_attr` varchar(128) DEFAULT NULL,
  `ldap_distributionlist_objectclass` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ldap`
--

LOCK TABLES `ldap` WRITE;
/*!40000 ALTER TABLE `ldap` DISABLE KEYS */;
/*!40000 ALTER TABLE `ldap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `legal_hold`
--

DROP TABLE IF EXISTS `legal_hold`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `legal_hold` (
  `email` varchar(128) NOT NULL,
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `legal_hold`
--

LOCK TABLES `legal_hold` WRITE;
/*!40000 ALTER TABLE `legal_hold` DISABLE KEYS */;
/*!40000 ALTER TABLE `legal_hold` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metadata`
--

DROP TABLE IF EXISTS `metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `metadata` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `from` varchar(255) NOT NULL,
  `fromdomain` varchar(255) NOT NULL,
  `subject` blob DEFAULT NULL,
  `spam` tinyint(1) DEFAULT 0,
  `arrived` int(10) unsigned NOT NULL,
  `sent` int(10) unsigned NOT NULL,
  `retained` int(10) unsigned NOT NULL,
  `deleted` tinyint(1) DEFAULT 0,
  `size` int(11) DEFAULT 0,
  `hlen` int(11) DEFAULT 0,
  `direction` int(11) DEFAULT 0,
  `attachments` int(11) DEFAULT 0,
  `piler_id` char(36) NOT NULL,
  `message_id` varchar(255) NOT NULL,
  `reference` char(64) NOT NULL,
  `digest` char(64) NOT NULL,
  `bodydigest` char(64) NOT NULL,
  `vcode` char(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `metadata_idx` (`piler_id`),
  KEY `metadata_idx2` (`message_id`),
  KEY `metadata_idx3` (`reference`),
  KEY `metadata_idx4` (`bodydigest`),
  KEY `metadata_idx5` (`deleted`),
  KEY `metadata_idx6` (`arrived`),
  KEY `metadata_idx7` (`retained`),
  KEY `metadata_idx8` (`fromdomain`),
  KEY `metadata_idx9` (`from`),
  KEY `metadata_idx10` (`sent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metadata`
--

LOCK TABLES `metadata` WRITE;
/*!40000 ALTER TABLE `metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `note`
--

DROP TABLE IF EXISTS `note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `note` (
  `_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `id` bigint(20) unsigned NOT NULL,
  `uid` int(11) NOT NULL,
  `note` text DEFAULT NULL,
  UNIQUE KEY `id` (`id`,`uid`),
  KEY `_id` (`_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `note`
--

LOCK TABLES `note` WRITE;
/*!40000 ALTER TABLE `note` DISABLE KEYS */;
/*!40000 ALTER TABLE `note` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `online`
--

DROP TABLE IF EXISTS `online`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `online` (
  `username` varchar(128) NOT NULL,
  `ts` int(11) DEFAULT 0,
  `last_activity` int(11) DEFAULT 0,
  `ipaddr` varchar(64) DEFAULT NULL,
  UNIQUE KEY `username` (`username`,`ipaddr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `online`
--

LOCK TABLES `online` WRITE;
/*!40000 ALTER TABLE `online` DISABLE KEYS */;
/*!40000 ALTER TABLE `online` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `option`
--

DROP TABLE IF EXISTS `option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `option` (
  `key` char(64) NOT NULL,
  `value` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `option`
--

LOCK TABLES `option` WRITE;
/*!40000 ALTER TABLE `option` DISABLE KEYS */;
INSERT INTO `option` VALUES ('enable_purge','1');
/*!40000 ALTER TABLE `option` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `private`
--

DROP TABLE IF EXISTS `private`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `private` (
  `id` bigint(20) unsigned NOT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `id_2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `private`
--

LOCK TABLES `private` WRITE;
/*!40000 ALTER TABLE `private` DISABLE KEYS */;
/*!40000 ALTER TABLE `private` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rcpt`
--

DROP TABLE IF EXISTS `rcpt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rcpt` (
  `id` bigint(20) unsigned NOT NULL,
  `to` varchar(128) NOT NULL,
  `todomain` varchar(128) NOT NULL,
  UNIQUE KEY `id` (`id`,`to`),
  KEY `rcpt_idx` (`id`),
  KEY `rcpt_idx2` (`to`),
  KEY `rcpt_idx3` (`todomain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rcpt`
--

LOCK TABLES `rcpt` WRITE;
/*!40000 ALTER TABLE `rcpt` DISABLE KEYS */;
/*!40000 ALTER TABLE `rcpt` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `remote`
--

DROP TABLE IF EXISTS `remote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `remote` (
  `remotedomain` char(64) NOT NULL,
  `remotehost` char(64) NOT NULL,
  `basedn` char(255) NOT NULL,
  `binddn` char(255) NOT NULL,
  `sitedescription` char(64) DEFAULT NULL,
  PRIMARY KEY (`remotedomain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `remote`
--

LOCK TABLES `remote` WRITE;
/*!40000 ALTER TABLE `remote` DISABLE KEYS */;
/*!40000 ALTER TABLE `remote` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `retention_rule`
--

DROP TABLE IF EXISTS `retention_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `retention_rule` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `domain` varchar(100) DEFAULT NULL,
  `from` varchar(100) DEFAULT NULL,
  `to` varchar(100) DEFAULT NULL,
  `subject` varchar(128) DEFAULT NULL,
  `body` varchar(128) DEFAULT NULL,
  `_size` char(2) DEFAULT NULL,
  `size` int(11) DEFAULT 0,
  `attachment_name` varchar(100) DEFAULT NULL,
  `attachment_type` varchar(64) DEFAULT NULL,
  `_attachment_size` char(2) DEFAULT NULL,
  `attachment_size` int(11) DEFAULT 0,
  `spam` tinyint(1) DEFAULT -1,
  `days` int(11) DEFAULT 0,
  `folder_id` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain` (`domain`,`from`,`to`,`subject`,`body`,`_size`,`size`,`attachment_name`,`attachment_type`,`_attachment_size`,`attachment_size`,`spam`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `retention_rule`
--

LOCK TABLES `retention_rule` WRITE;
/*!40000 ALTER TABLE `retention_rule` DISABLE KEYS */;
/*!40000 ALTER TABLE `retention_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search`
--

DROP TABLE IF EXISTS `search`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search` (
  `email` char(128) NOT NULL,
  `ts` int(11) DEFAULT 0,
  `term` text NOT NULL,
  KEY `search_idx` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search`
--

LOCK TABLES `search` WRITE;
/*!40000 ALTER TABLE `search` DISABLE KEYS */;
/*!40000 ALTER TABLE `search` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sph_counter`
--

DROP TABLE IF EXISTS `sph_counter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sph_counter` (
  `counter_id` bigint(20) NOT NULL,
  `max_doc_id` bigint(20) NOT NULL,
  PRIMARY KEY (`counter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sph_counter`
--

LOCK TABLES `sph_counter` WRITE;
/*!40000 ALTER TABLE `sph_counter` DISABLE KEYS */;
INSERT INTO `sph_counter` VALUES (1,0);
/*!40000 ALTER TABLE `sph_counter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sph_index`
--

DROP TABLE IF EXISTS `sph_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sph_index` (
  `id` bigint(20) NOT NULL,
  `from` tinyblob DEFAULT NULL,
  `to` blob DEFAULT NULL,
  `fromdomain` tinyblob DEFAULT NULL,
  `todomain` blob DEFAULT NULL,
  `subject` blob DEFAULT NULL,
  `arrived` int(10) unsigned NOT NULL,
  `sent` int(10) unsigned NOT NULL,
  `body` mediumblob DEFAULT NULL,
  `size` int(11) DEFAULT 0,
  `direction` int(11) DEFAULT 0,
  `folder` int(11) DEFAULT 0,
  `attachments` int(11) DEFAULT 0,
  `attachment_types` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sph_index`
--

LOCK TABLES `sph_index` WRITE;
/*!40000 ALTER TABLE `sph_index` DISABLE KEYS */;
/*!40000 ALTER TABLE `sph_index` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag` (
  `_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `id` bigint(20) NOT NULL,
  `uid` int(11) NOT NULL,
  `tag` varchar(255) DEFAULT NULL,
  UNIQUE KEY `id` (`id`,`uid`),
  KEY `_id` (`_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tag`
--

LOCK TABLES `tag` WRITE;
/*!40000 ALTER TABLE `tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `timestamp`
--

DROP TABLE IF EXISTS `timestamp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `timestamp` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `start_id` bigint(20) DEFAULT 0,
  `stop_id` bigint(20) DEFAULT 0,
  `hash_value` varchar(128) DEFAULT NULL,
  `count` int(11) DEFAULT 0,
  `response_time` bigint(20) DEFAULT 0,
  `response_string` blob NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timestamp`
--

LOCK TABLES `timestamp` WRITE;
/*!40000 ALTER TABLE `timestamp` DISABLE KEYS */;
/*!40000 ALTER TABLE `timestamp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `uid` int(10) unsigned NOT NULL,
  `username` char(64) NOT NULL,
  `realname` char(64) DEFAULT NULL,
  `samaccountname` char(64) DEFAULT NULL,
  `password` char(128) DEFAULT NULL,
  `domain` char(64) DEFAULT NULL,
  `dn` char(255) DEFAULT '*',
  `isadmin` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (0,'admin','built-in piler admin','','$1$PItc7d$zsUgON3JRrbdGS11t9JQW1','local','*',1),(1,'auditor','built-in piler auditor','','$1$SLIIIS$JMBwGqQg4lIir2P2YU1y.0','local','*',2);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_settings`
--

DROP TABLE IF EXISTS `user_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_settings` (
  `username` char(64) NOT NULL,
  `pagelen` int(11) DEFAULT 20,
  `theme` char(8) DEFAULT 'default',
  `lang` char(2) DEFAULT NULL,
  `ga_enabled` int(11) DEFAULT 0,
  `ga_secret` varchar(255) DEFAULT NULL,
  UNIQUE KEY `username` (`username`),
  KEY `user_settings_idx` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_settings`
--

LOCK TABLES `user_settings` WRITE;
/*!40000 ALTER TABLE `user_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usergroup`
--

DROP TABLE IF EXISTS `usergroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usergroup` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `groupname` char(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `groupname` (`groupname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usergroup`
--

LOCK TABLES `usergroup` WRITE;
/*!40000 ALTER TABLE `usergroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `usergroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `v_attachment`
--

DROP TABLE IF EXISTS `v_attachment`;
/*!50001 DROP VIEW IF EXISTS `v_attachment`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_attachment` AS SELECT
 1 AS `i`,
  1 AS `piler_id`,
  1 AS `attachment_id`,
  1 AS `ptr`,
  1 AS `refcount` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_messages`
--

DROP TABLE IF EXISTS `v_messages`;
/*!50001 DROP VIEW IF EXISTS `v_messages`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_messages` AS SELECT
 1 AS `id`,
  1 AS `piler_id`,
  1 AS `from`,
  1 AS `fromdomain`,
  1 AS `to`,
  1 AS `todomain`,
  1 AS `subject`,
  1 AS `size`,
  1 AS `direction`,
  1 AS `sent`,
  1 AS `retained`,
  1 AS `arrived`,
  1 AS `digest`,
  1 AS `bodydigest`,
  1 AS `deleted`,
  1 AS `attachments` */;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_attachment`
--

/*!50001 DROP VIEW IF EXISTS `v_attachment`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`mailpiler`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_attachment` AS select `attachment`.`id` AS `i`,`attachment`.`piler_id` AS `piler_id`,`attachment`.`attachment_id` AS `attachment_id`,`attachment`.`ptr` AS `ptr`,(select count(0) from `attachment` where `attachment`.`ptr` = `i`) AS `refcount` from `attachment` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_messages`
--

/*!50001 DROP VIEW IF EXISTS `v_messages`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`mailpiler`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_messages` AS select `metadata`.`id` AS `id`,`metadata`.`piler_id` AS `piler_id`,`metadata`.`from` AS `from`,`metadata`.`fromdomain` AS `fromdomain`,`rcpt`.`to` AS `to`,`rcpt`.`todomain` AS `todomain`,`metadata`.`subject` AS `subject`,`metadata`.`size` AS `size`,`metadata`.`direction` AS `direction`,`metadata`.`sent` AS `sent`,`metadata`.`retained` AS `retained`,`metadata`.`arrived` AS `arrived`,`metadata`.`digest` AS `digest`,`metadata`.`bodydigest` AS `bodydigest`,`metadata`.`deleted` AS `deleted`,`metadata`.`attachments` AS `attachments` from (`metadata` join `rcpt`) where `metadata`.`id` = `rcpt`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-02-20 15:34:35
