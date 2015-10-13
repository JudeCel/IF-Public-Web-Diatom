-- MySQL dump 10.15  Distrib 10.0.21-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: if
-- ------------------------------------------------------
-- Server version	10.0.21-MariaDB-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `id` bigint(20) NOT NULL,
  `Created` datetime NOT NULL,
  `Modified` datetime DEFAULT NULL,
  `Deleted` datetime DEFAULT NULL,
  `OwnerEmail` varchar(320) CHARACTER SET utf8 DEFAULT NULL,
  `Disabled` datetime DEFAULT NULL,
  `TrialExpiration` datetime DEFAULT NULL,
  `Status` int(11) NOT NULL DEFAULT '102000100',
  `StatusModified` datetime NOT NULL,
  `BillingAccountID` varchar(150) CHARACTER SET utf8 DEFAULT NULL,
  `BillingSubscriptionID` varchar(150) CHARACTER SET utf8 DEFAULT NULL,
  `BillingEmail` varchar(320) CHARACTER SET utf8 DEFAULT NULL,
  `BillingAlternateEmail` varchar(320) CHARACTER SET utf8 DEFAULT NULL,
  `CancellationDate` datetime DEFAULT NULL,
  `BillingIntervalType` int(11) NOT NULL DEFAULT '0',
  `Updated` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_Account_Status_MType_ID` (`Status`),
  KEY `FK_account_billingIntervalType` (`BillingIntervalType`),
  CONSTRAINT `FK_account_billingIntervalType` FOREIGN KEY (`BillingIntervalType`) REFERENCES `mtype` (`ID`),
  CONSTRAINT `FK_account_status` FOREIGN KEY (`Status`) REFERENCES `mtype` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AVG_ROW_LENGTH=319;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contactlist`
--

DROP TABLE IF EXISTS `contactlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contactlist` (
  `ID` bigint(20) NOT NULL,
  `AccountID` bigint(20) NOT NULL,
  `Created` datetime NOT NULL,
  `Modified` datetime NOT NULL,
  `Deleted` datetime DEFAULT NULL,
  `Name` varchar(200) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_UserGroup_AccountID_Account_ID` (`AccountID`),
  CONSTRAINT `FK_UserGroup_AccountID_Account_ID` FOREIGN KEY (`AccountID`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contactlistuser`
--

DROP TABLE IF EXISTS `contactlistuser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contactlistuser` (
  `ID` bigint(20) NOT NULL,
  `AccountID` bigint(20) NOT NULL,
  `Created` datetime NOT NULL,
  `Modified` datetime NOT NULL,
  `Deleted` datetime DEFAULT NULL,
  `UserID` bigint(20) NOT NULL,
  `ContactListID` bigint(20) NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `IX_UserGroupUser` (`UserID`,`ContactListID`),
  KEY `FK_UserGroupUser_AccountID_Account_ID` (`AccountID`),
  KEY `FK_UserGroupUser_UserGroupID_UserGroup_ID` (`ContactListID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `conversations`
--

DROP TABLE IF EXISTS `conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conversations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_from_id` int(11) NOT NULL COMMENT 'who initiated this converstation',
  `user_to_id` int(11) NOT NULL DEFAULT '0' COMMENT 'who the conversation was targeting, ''0'' is for all',
  `topic_id` int(11) NOT NULL COMMENT 'what was user_from ''talking'' about?',
  `message` text NOT NULL,
  `posted_date_time` datetime NOT NULL COMMENT 'time the message was sent',
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_cv_user_from` (`user_from_id`),
  KEY `fk_cv_user_to` (`user_to_id`),
  KEY `fk_cv_topic` (`topic_id`),
  CONSTRAINT `fk_cv_topic` FOREIGN KEY (`topic_id`) REFERENCES `topics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_cv_user_from` FOREIGN KEY (`user_from_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_cv_user_to` FOREIGN KEY (`user_to_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `country_lookup`
--

DROP TABLE IF EXISTS `country_lookup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country_lookup` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `HACC_Country_Code` char(4) CHARACTER SET utf8 NOT NULL,
  `country_name` varchar(100) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=248 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_log`
--

DROP TABLE IF EXISTS `email_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `sent_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `receiver` varchar(100) NOT NULL,
  `subject` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `sender` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1183 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `events` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `topic_id` int(11) NOT NULL DEFAULT '0',
  `reply_id` int(11) DEFAULT NULL,
  `cmd` tinytext,
  `tag` int(11) NOT NULL DEFAULT '0',
  `uid` varchar(64) DEFAULT NULL,
  `event` text,
  `thumbs_up` int(11) DEFAULT '0',
  `timestamp` int(11) NOT NULL COMMENT 'I''m using this to store the date as an integer, this should result in faster searches and remove timezone problems at dates will be stored using UNIX_TIMESTAMP()',
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `SK_Topic_Tag` (`topic_id`,`tag`)
) ENGINE=InnoDB AUTO_INCREMENT=78042702 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `forgotpasswordrequest`
--

DROP TABLE IF EXISTS `forgotpasswordrequest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forgotpasswordrequest` (
  `id` int(11) NOT NULL,
  `email` varchar(50) NOT NULL,
  `token` varchar(50) NOT NULL,
  `expirationDate` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `green_room`
--

DROP TABLE IF EXISTS `green_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `green_room` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `top_message` text,
  `session_information` text,
  `session_details` text,
  `overview` text,
  `greeting` text,
  `session_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=47 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hiloid`
--

DROP TABLE IF EXISTS `hiloid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hiloid` (
  `NextHi` bigint(20) NOT NULL,
  PRIMARY KEY (`NextHi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` tinytext,
  `timestamp` int(11) NOT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=78052802 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `menu_lookup`
--

DROP TABLE IF EXISTS `menu_lookup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_lookup` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_name` varchar(30) NOT NULL,
  `URL` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mtype`
--

DROP TABLE IF EXISTS `mtype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mtype` (
  `ID` int(11) NOT NULL,
  `Name` varchar(500) CHARACTER SET utf8 NOT NULL,
  `Description` varchar(1000) CHARACTER SET utf8 DEFAULT NULL,
  `MTypeGroupID` int(11) NOT NULL,
  `DisplayOrder` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_MType_MTypeGroupID_MTypeGroup_ID` (`MTypeGroupID`),
  CONSTRAINT `FK_MType_MTypeGroupID_MTypeGroup_ID` FOREIGN KEY (`MTypeGroupID`) REFERENCES `mtypegroup` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mtypegroup`
--

DROP TABLE IF EXISTS `mtypegroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mtypegroup` (
  `ID` int(11) NOT NULL,
  `Name` varchar(500) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `offline_transactions`
--

DROP TABLE IF EXISTS `offline_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `offline_transactions` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `session_id` int(11) NOT NULL,
  `topic_id` int(11) NOT NULL,
  `reply_user_id` int(11) DEFAULT NULL,
  `message_id` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41410006 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `participant_lists`
--

DROP TABLE IF EXISTS `participant_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `participant_lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` int(11) NOT NULL,
  `participant_id` int(11) NOT NULL COMMENT 'the participant in question',
  `ul_id` int(11) DEFAULT NULL,
  `participant_reply_id` int(11) DEFAULT NULL,
  `participant_rating_id` int(11) DEFAULT NULL,
  `participant_colour_lookup_id` int(11) DEFAULT NULL,
  `comments` text,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_pl_participant` (`participant_id`),
  KEY `session_id` (`session_id`),
  KEY `participant_reply_id` (`participant_reply_id`),
  KEY `participant_rating_id` (`participant_rating_id`),
  CONSTRAINT `fk_pl_participant` FOREIGN KEY (`participant_id`) REFERENCES `participants` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `participant_lists_ibfk_3` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `participants`
--

DROP TABLE IF EXISTS `participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `participants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `brand_project_id` int(11) NOT NULL,
  `dob` varchar(100) DEFAULT NULL,
  `ethnicity` varchar(100) DEFAULT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `brand_segment` varchar(100) DEFAULT NULL,
  `participant_reply_id` int(11) DEFAULT NULL,
  `participant_colour_lookup_id` int(11) DEFAULT NULL,
  `invite_again` varchar(100) NOT NULL DEFAULT 'Yes' COMMENT 'this is set at the end of the session so that the moderator can decide if the participant is good and should be invited again.',
  `interested` int(11) DEFAULT NULL,
  `optional1` varchar(100) DEFAULT NULL,
  `optional2` varchar(100) DEFAULT NULL,
  `optional3` varchar(100) DEFAULT NULL,
  `optional4` varchar(100) DEFAULT NULL,
  `optional5` varchar(100) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_pa_brand_project` (`brand_project_id`),
  KEY `fk_pa_user` (`user_id`),
  KEY `participant_reply_id` (`participant_reply_id`),
  CONSTRAINT `fk_pa_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=73699705 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `post_code_suburb_lookup`
--

DROP TABLE IF EXISTS `post_code_suburb_lookup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_code_suburb_lookup` (
  `SuburbId` int(11) NOT NULL,
  `PostCode` int(4) DEFAULT NULL,
  `Suburb` text,
  `State` varchar(100) NOT NULL DEFAULT 'South Australia',
  `Country` varchar(200) NOT NULL DEFAULT 'AUSTRALIA',
  `lat` float(10,6) DEFAULT NULL,
  `lng` float(10,6) DEFAULT NULL,
  PRIMARY KEY (`SuburbId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resources`
--

DROP TABLE IF EXISTS `resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type_id` int(11) NOT NULL DEFAULT '0',
  `topic_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `thumb_URL` text COMMENT 'used primarily if this is an image',
  `URL` text NOT NULL,
  `HTML` text,
  `JSON` text,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_re_type` (`type_id`),
  CONSTRAINT `FK_resources_TypeId` FOREIGN KEY (`type_id`) REFERENCES `mtype` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=72406937 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sess`
--

DROP TABLE IF EXISTS `sess`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sess` (
  `lastActivity` datetime DEFAULT NULL,
  `iPAddress` varchar(32) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '100000200',
  `type` int(11) NOT NULL DEFAULT '101000100',
  `expires` datetime DEFAULT NULL,
  `ID` bigint(20) NOT NULL,
  `AccountID` bigint(20) DEFAULT NULL,
  `Created` datetime NOT NULL,
  `Modified` datetime DEFAULT NULL,
  `Deleted` datetime DEFAULT NULL,
  `UserID` int(11) DEFAULT NULL,
  `Updated` datetime DEFAULT NULL,
  KEY `FK_sess_type` (`type`),
  KEY `FK_sess_status` (`status`),
  CONSTRAINT `FK_sess_status` FOREIGN KEY (`status`) REFERENCES `mtype` (`ID`),
  CONSTRAINT `FK_sess_type` FOREIGN KEY (`type`) REFERENCES `mtype` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `session_emails`
--

DROP TABLE IF EXISTS `session_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` int(11) NOT NULL,
  `email_type_id` int(11) NOT NULL,
  `greeting` varchar(255) DEFAULT NULL,
  `subject` text NOT NULL,
  `email_message_top` text,
  `email_message_bottom` text,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  `email_video` varchar(255) DEFAULT NULL,
  `email_image` varchar(255) DEFAULT NULL,
  `email_image_desc` text,
  `detail_1` text,
  `detail_2` text,
  `detail_3` text,
  `detail_4` text,
  `detail_5` text,
  `detail_6` text,
  PRIMARY KEY (`id`),
  KEY `email_type_id` (`email_type_id`),
  KEY `session_id` (`session_id`),
  CONSTRAINT `session_emails_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='this table stores the custom email texts for a particular se';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `session_staff`
--

DROP TABLE IF EXISTS `session_staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session_staff` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'the user_id will be taken from client_users',
  `session_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL DEFAULT '106000300',
  `comments` text,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_ss_user` (`user_id`),
  KEY `fk_ss_session` (`session_id`),
  KEY `fk_ss_type` (`type_id`),
  CONSTRAINT `FK_session_staff` FOREIGN KEY (`type_id`) REFERENCES `mtype` (`ID`),
  CONSTRAINT `fk_ss_session` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_ss_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `brand_project_id` int(11) DEFAULT NULL,
  `name` varchar(45) NOT NULL DEFAULT 'untitled' COMMENT 'name of the session',
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `incentive_details` text,
  `status_id` int(11) NOT NULL DEFAULT '104000100',
  `active_topic_id` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  `colours_used` text,
  `expirationDate` datetime DEFAULT NULL,
  `accountId` bigint(20) DEFAULT NULL,
  `facilitatorId` bit(20) DEFAULT NULL,
  `sessionLogoName` varchar(100) DEFAULT NULL COMMENT 'filename of the session logo',
  `sessionLogoExt` varchar(5) DEFAULT NULL COMMENT 'file extension of the session logo',
  PRIMARY KEY (`id`),
  KEY `fk_se_brand_project` (`brand_project_id`),
  KEY `status_id` (`status_id`),
  KEY `active_topic_id` (`active_topic_id`),
  CONSTRAINT `FK_sessions` FOREIGN KEY (`status_id`) REFERENCES `mtype` (`ID`),
  CONSTRAINT `sessions_ibfk_6` FOREIGN KEY (`active_topic_id`) REFERENCES `topics` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=79678901 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_activity_logs`
--

DROP TABLE IF EXISTS `topic_activity_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topic_activity_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` int(11) NOT NULL,
  `topic_id` int(11) NOT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `session_id` (`session_id`),
  KEY `topic_id` (`topic_id`),
  CONSTRAINT `topic_activity_logs_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `topic_activity_logs_ibfk_2` FOREIGN KEY (`topic_id`) REFERENCES `topics` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='this table keeps track of active topics.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topics`
--

DROP TABLE IF EXISTS `topics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL DEFAULT 'untitled' COMMENT 'name of the topic',
  `type` varchar(10) NOT NULL DEFAULT 'chat' COMMENT 'type of conversation : chat, whiteboard, image, video, audio, vote',
  `URL` varchar(255) DEFAULT NULL COMMENT 'links to any media we want to show, image, video or audio.  Images use the whiteboard, but have the image as the background',
  `topic_status_id` int(11) NOT NULL DEFAULT '110000100',
  `topic_order_id` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  `description` text,
  `accountId` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_to_session` (`session_id`),
  KEY `FK_topics` (`topic_status_id`),
  CONSTRAINT `FK_topics` FOREIGN KEY (`topic_status_id`) REFERENCES `mtype` (`ID`),
  CONSTRAINT `fk_to_session` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=79083003 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_logins`
--

DROP TABLE IF EXISTS `user_logins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_logins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `username` varchar(45) NOT NULL,
  `password` varchar(45) NOT NULL COMMENT 'this value will be hashed for security',
  `security_question` text COMMENT 'for extra security, the user can be asked this question',
  `security_answer` text COMMENT 'for extra security, the user must answer this',
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  `key_value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=78527502 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `userrole`
--

DROP TABLE IF EXISTS `userrole`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userrole` (
  `id` bigint(11) NOT NULL,
  `userId` bigint(11) NOT NULL,
  `roleId` bigint(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_login_id` int(11) DEFAULT NULL,
  `ifs_admin` tinyint(1) NOT NULL DEFAULT '0',
  `avatar_resource_id` int(11) DEFAULT NULL,
  `avatar_info` varchar(45) NOT NULL DEFAULT '0:3:0:0:0:0' COMMENT 'head:face:hair:top:accessory:desk',
  `name_first` varchar(45) DEFAULT NULL,
  `name_last` varchar(45) DEFAULT NULL,
  `email` varchar(45) DEFAULT NULL,
  `phone` varchar(45) DEFAULT NULL,
  `fax` varchar(45) DEFAULT NULL,
  `mobile` varchar(45) DEFAULT NULL,
  `Gender` varchar(100) DEFAULT NULL,
  `job_title` varchar(200) DEFAULT NULL,
  `address_id` int(11) DEFAULT NULL,
  `invites` int(11) NOT NULL DEFAULT '0',
  `invites_accepted` int(11) NOT NULL DEFAULT '0',
  `invites_not_now` int(11) NOT NULL DEFAULT '0',
  `invites_not_interested` int(11) NOT NULL DEFAULT '0',
  `invites_no_reply` int(11) NOT NULL DEFAULT '0',
  `last_invite_name` varchar(255) DEFAULT NULL,
  `green_room_visit` tinyint(1) NOT NULL DEFAULT '0',
  `persistence` varchar(1024) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  `uses_landline` tinyint(1) DEFAULT NULL COMMENT 'TRUE= use `phone` field as "phone" in e-mails. `mobile` otherwise',
  `passwordCrypt` varchar(100) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `code` varchar(20) DEFAULT NULL,
  `company` varchar(100) DEFAULT NULL,
  `accountId` int(11) DEFAULT NULL,
  `passwordExpiration` datetime DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `token` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_us_avatar` (`avatar_resource_id`),
  KEY `fk_user_login` (`user_login_id`),
  KEY `FK_users` (`status`),
  CONSTRAINT `FK_users` FOREIGN KEY (`status`) REFERENCES `mtype` (`ID`),
  CONSTRAINT `fk_us_avatar` FOREIGN KEY (`avatar_resource_id`) REFERENCES `resources` (`id`),
  CONSTRAINT `fk_user_login` FOREIGN KEY (`user_login_id`) REFERENCES `user_logins` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79699102 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `votes`
--

DROP TABLE IF EXISTS `votes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `votes` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` int(11) DEFAULT NULL,
  `count` int(11) NOT NULL DEFAULT '0',
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=73629007 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `votes_by`
--

DROP TABLE IF EXISTS `votes_by`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `votes_by` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `vote_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `topic_id` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-10-12 18:14:15
