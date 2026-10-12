-- MySQL dump 10.13  Distrib 8.4.9, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: movie_booking_test
-- ------------------------------------------------------
-- Server version	8.4.9

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `movie_booking_test`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `movie_booking_test` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `movie_booking_test`;

--
-- Table structure for table `booking_seats`
--

DROP TABLE IF EXISTS `booking_seats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_seats` (
  `booking_id` bigint NOT NULL,
  `seat_number` varchar(12) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`booking_id`,`seat_number`),
  CONSTRAINT `fk_seat_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_seats`
--

LOCK TABLES `booking_seats` WRITE;
/*!40000 ALTER TABLE `booking_seats` DISABLE KEYS */;
INSERT INTO `booking_seats` VALUES (1,'A1'),(2,'A2'),(3,'A1'),(4,'A1'),(5,'A1'),(6,'A1'),(7,'A1'),(7,'A2'),(8,'A1'),(9,'A1'),(10,'A1'),(11,'A2'),(12,'A1'),(13,'A1'),(14,'A1'),(15,'A2'),(16,'A1'),(17,'A1'),(18,'A1'),(19,'A1'),(20,'A1'),(20,'A2'),(21,'A1'),(22,'A1'),(23,'A1'),(24,'A2'),(25,'A1'),(26,'A1'),(27,'A1'),(28,'A2'),(29,'A1'),(30,'A1'),(31,'A1'),(32,'A1'),(33,'A1'),(33,'A2'),(34,'A1'),(35,'A1'),(36,'A1'),(37,'A2'),(38,'A1'),(39,'A1');
/*!40000 ALTER TABLE `booking_seats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `show_id` bigint NOT NULL,
  `number_of_tickets` int NOT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `booking_date` timestamp(6) NOT NULL,
  `status` enum('PENDING','CONFIRMED','CANCELLED') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_booking_user` (`user_id`),
  KEY `idx_booking_show_status` (`show_id`,`status`),
  CONSTRAINT `fk_booking_show` FOREIGN KEY (`show_id`) REFERENCES `movie_shows` (`id`),
  CONSTRAINT `fk_booking_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `bookings_chk_1` CHECK ((`number_of_tickets` > 0)),
  CONSTRAINT `bookings_chk_2` CHECK ((`total_amount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
INSERT INTO `bookings` VALUES (1,1,1,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(2,2,1,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(3,4,2,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(4,7,3,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(5,8,3,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(6,16,7,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(7,19,8,2,2501.00,'2029-12-31 18:30:00.000000','PENDING'),(8,22,9,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(9,29,11,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(10,32,13,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(11,32,13,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(12,35,14,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(13,44,17,1,1250.50,'2029-12-31 18:30:00.000000','CONFIRMED'),(14,50,21,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(15,51,21,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(16,53,22,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(17,56,23,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(18,57,23,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(19,65,27,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(20,68,28,2,2501.00,'2029-12-31 18:30:00.000000','PENDING'),(21,71,29,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(22,78,31,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(23,81,33,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(24,81,33,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(25,84,34,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(26,93,37,1,1250.50,'2029-12-31 18:30:00.000000','CONFIRMED'),(27,99,41,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(28,100,41,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(29,102,42,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(30,105,43,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(31,106,43,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(32,114,47,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(33,117,48,2,2501.00,'2029-12-31 18:30:00.000000','PENDING'),(34,120,49,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(35,127,51,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(36,130,53,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(37,130,53,1,1250.50,'2029-12-31 18:30:00.000000','CANCELLED'),(38,133,54,1,1250.50,'2029-12-31 18:30:00.000000','PENDING'),(39,142,57,1,1250.50,'2029-12-31 18:30:00.000000','CONFIRMED');
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flyway_schema_history`
--

DROP TABLE IF EXISTS `flyway_schema_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flyway_schema_history` (
  `installed_rank` int NOT NULL,
  `version` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `script` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `checksum` int DEFAULT NULL,
  `installed_by` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `execution_time` int NOT NULL,
  `success` tinyint(1) NOT NULL,
  PRIMARY KEY (`installed_rank`),
  KEY `flyway_schema_history_s_idx` (`success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flyway_schema_history`
--

LOCK TABLES `flyway_schema_history` WRITE;
/*!40000 ALTER TABLE `flyway_schema_history` DISABLE KEYS */;
INSERT INTO `flyway_schema_history` VALUES (1,'1','initial schema','SQL','V1__initial_schema.sql',-2108146293,'movie_booking_test','2026-09-22 01:08:40',9305,1);
/*!40000 ALTER TABLE `flyway_schema_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movie_shows`
--

DROP TABLE IF EXISTS `movie_shows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movie_shows` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `movie_id` bigint NOT NULL,
  `theatre_id` bigint NOT NULL,
  `show_date` date NOT NULL,
  `show_time` time(6) NOT NULL,
  `ticket_price` decimal(12,2) NOT NULL,
  `status` enum('SCHEDULED','COMPLETED','CANCELLED') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_show_movie` (`movie_id`),
  KEY `idx_show_schedule` (`theatre_id`,`status`,`show_date`),
  CONSTRAINT `fk_show_movie` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`id`),
  CONSTRAINT `fk_show_theatre` FOREIGN KEY (`theatre_id`) REFERENCES `theatres` (`id`),
  CONSTRAINT `movie_shows_chk_1` CHECK ((`ticket_price` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movie_shows`
--

LOCK TABLES `movie_shows` WRITE;
/*!40000 ALTER TABLE `movie_shows` DISABLE KEYS */;
INSERT INTO `movie_shows` VALUES (1,1,1,'2030-02-01','12:00:00.000000',1250.50,'CANCELLED'),(2,2,2,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(3,3,3,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(4,4,4,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(5,5,5,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(6,6,5,'2030-02-01','18:00:00.000000',1250.50,'SCHEDULED'),(7,7,6,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(8,8,7,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(9,9,8,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(10,10,9,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(11,11,10,'2030-02-01','11:00:00.000000',1250.50,'SCHEDULED'),(13,12,11,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(14,13,12,'2030-02-01','12:00:00.000000',1250.50,'COMPLETED'),(15,14,13,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(16,15,14,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(17,17,16,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(18,18,17,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(19,18,17,'2030-02-01','14:00:00.000000',1250.50,'SCHEDULED'),(20,18,17,'2030-02-01','23:00:00.000000',1250.50,'SCHEDULED'),(21,19,18,'2030-02-01','12:00:00.000000',1250.50,'CANCELLED'),(22,20,19,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(23,21,20,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(24,22,21,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(25,23,22,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(26,24,22,'2030-02-01','18:00:00.000000',1250.50,'SCHEDULED'),(27,25,23,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(28,26,24,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(29,27,25,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(30,28,26,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(31,29,27,'2030-02-01','11:00:00.000000',1250.50,'SCHEDULED'),(33,30,28,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(34,31,29,'2030-02-01','12:00:00.000000',1250.50,'COMPLETED'),(35,32,30,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(36,33,31,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(37,35,33,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(38,36,34,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(39,36,34,'2030-02-01','14:00:00.000000',1250.50,'SCHEDULED'),(40,36,34,'2030-02-01','23:00:00.000000',1250.50,'SCHEDULED'),(41,37,35,'2030-02-01','12:00:00.000000',1250.50,'CANCELLED'),(42,38,36,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(43,39,37,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(44,40,38,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(45,41,39,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(46,41,39,'2030-02-01','18:00:00.000000',1250.50,'SCHEDULED'),(47,43,40,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(48,44,41,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(49,45,42,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(50,46,43,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(51,47,44,'2030-02-01','11:00:00.000000',1250.50,'SCHEDULED'),(53,48,45,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(54,49,46,'2030-02-01','12:00:00.000000',1250.50,'COMPLETED'),(55,50,47,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(56,51,48,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(57,53,50,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(58,54,51,'2030-02-01','12:00:00.000000',1250.50,'SCHEDULED'),(59,54,51,'2030-02-01','14:00:00.000000',1250.50,'SCHEDULED'),(60,54,51,'2030-02-01','23:00:00.000000',1250.50,'SCHEDULED');
/*!40000 ALTER TABLE `movie_shows` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movies`
--

DROP TABLE IF EXISTS `movies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movies` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(4000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` int NOT NULL,
  `language` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `genre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `release_date` date NOT NULL,
  `status` enum('UPCOMING','NOW_SHOWING','ENDED') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `movies_chk_1` CHECK ((`duration` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movies`
--

LOCK TABLES `movies` WRITE;
/*!40000 ALTER TABLE `movies` DISABLE KEYS */;
INSERT INTO `movies` VALUES (1,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(2,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(3,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(4,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(5,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(6,'Example','Description',100,'English','Drama','2029-01-01','UPCOMING'),(7,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(8,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(9,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(10,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(11,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(12,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(13,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(14,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(15,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(17,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(18,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(19,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(20,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(21,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(22,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(23,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(24,'Example','Description',100,'English','Drama','2029-01-01','UPCOMING'),(25,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(26,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(27,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(28,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(29,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(30,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(31,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(32,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(33,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(35,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(36,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(37,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(38,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(39,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(40,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(41,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(42,'Example','Description',100,'English','Drama','2029-01-01','UPCOMING'),(43,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(44,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(45,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(46,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(47,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(48,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(49,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(50,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(51,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(53,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING'),(54,'Example','Description',120,'English','Drama','2029-01-01','NOW_SHOWING');
/*!40000 ALTER TABLE `movies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `booking_id` bigint NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `payment_date` timestamp(6) NULL DEFAULT NULL,
  `payment_method` enum('SIMULATED') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('PENDING','COMPLETED','FAILED','REFUNDED') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_id` (`booking_id`),
  CONSTRAINT `fk_payment_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `payments_chk_1` CHECK ((`amount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','REFUNDED'),(2,4,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','REFUNDED'),(3,6,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','FAILED'),(4,8,1250.50,NULL,'SIMULATED','PENDING'),(5,11,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','FAILED'),(6,12,1250.50,NULL,'SIMULATED','PENDING'),(7,13,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','COMPLETED'),(8,14,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','REFUNDED'),(9,17,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','REFUNDED'),(10,19,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','FAILED'),(11,21,1250.50,NULL,'SIMULATED','PENDING'),(12,24,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','FAILED'),(13,25,1250.50,NULL,'SIMULATED','PENDING'),(14,26,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','COMPLETED'),(15,27,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','REFUNDED'),(16,30,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','REFUNDED'),(17,32,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','REFUNDED'),(18,34,1250.50,NULL,'SIMULATED','PENDING'),(19,37,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','FAILED'),(20,38,1250.50,NULL,'SIMULATED','PENDING'),(21,39,1250.50,'2029-12-31 18:30:00.000000','SIMULATED','COMPLETED');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `theatres`
--

DROP TABLE IF EXISTS `theatres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `theatres` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacity` int NOT NULL,
  `status` enum('ACTIVE','INACTIVE') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `theatres_chk_1` CHECK ((`capacity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `theatres`
--

LOCK TABLES `theatres` WRITE;
/*!40000 ALTER TABLE `theatres` DISABLE KEYS */;
INSERT INTO `theatres` VALUES (1,'Cinema','Colombo',12,'ACTIVE'),(2,'Cinema','Colombo',12,'ACTIVE'),(3,'Cinema','Colombo',12,'ACTIVE'),(4,'Cinema','Colombo',12,'ACTIVE'),(5,'Cinema','Colombo',12,'ACTIVE'),(6,'Cinema','Colombo',12,'ACTIVE'),(7,'Cinema','Colombo',12,'ACTIVE'),(8,'Cinema','Colombo',12,'ACTIVE'),(9,'Cinema','Colombo',12,'ACTIVE'),(10,'Cinema','Colombo',12,'ACTIVE'),(11,'Cinema','Colombo',12,'ACTIVE'),(12,'Cinema','Colombo',12,'ACTIVE'),(13,'Cinema','Colombo',12,'ACTIVE'),(14,'Cinema','Colombo',12,'ACTIVE'),(16,'Cinema','Colombo',12,'ACTIVE'),(17,'Cinema','Colombo',12,'INACTIVE'),(18,'Cinema','Colombo',12,'ACTIVE'),(19,'Cinema','Colombo',12,'ACTIVE'),(20,'Cinema','Colombo',12,'ACTIVE'),(21,'Cinema','Colombo',12,'ACTIVE'),(22,'Cinema','Colombo',12,'ACTIVE'),(23,'Cinema','Colombo',12,'ACTIVE'),(24,'Cinema','Colombo',12,'ACTIVE'),(25,'Cinema','Colombo',12,'ACTIVE'),(26,'Cinema','Colombo',12,'ACTIVE'),(27,'Cinema','Colombo',12,'ACTIVE'),(28,'Cinema','Colombo',12,'ACTIVE'),(29,'Cinema','Colombo',12,'ACTIVE'),(30,'Cinema','Colombo',12,'ACTIVE'),(31,'Cinema','Colombo',12,'ACTIVE'),(33,'Cinema','Colombo',12,'ACTIVE'),(34,'Cinema','Colombo',12,'INACTIVE'),(35,'Cinema','Colombo',12,'ACTIVE'),(36,'Cinema','Colombo',12,'ACTIVE'),(37,'Cinema','Colombo',12,'ACTIVE'),(38,'Cinema','Colombo',12,'ACTIVE'),(39,'Cinema','Colombo',12,'ACTIVE'),(40,'Cinema','Colombo',12,'ACTIVE'),(41,'Cinema','Colombo',12,'ACTIVE'),(42,'Cinema','Colombo',12,'ACTIVE'),(43,'Cinema','Colombo',12,'ACTIVE'),(44,'Cinema','Colombo',12,'ACTIVE'),(45,'Cinema','Colombo',12,'ACTIVE'),(46,'Cinema','Colombo',12,'ACTIVE'),(47,'Cinema','Colombo',12,'ACTIVE'),(48,'Cinema','Colombo',12,'ACTIVE'),(50,'Cinema','Colombo',12,'ACTIVE'),(51,'Cinema','Colombo',12,'INACTIVE');
/*!40000 ALTER TABLE `theatres` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('ADMIN','CUSTOMER') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=148 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Test User','ec5cb983-cdc5-4241-8342-8957773ee39b@example.com','$2a$10$qBfncaAGbChO7GOf1L5D3OuceW2l94qIdIbYxBJfOBetJiuj2UAzK','CUSTOMER'),(2,'Test User','a140c588-3127-4ec8-9233-036e68010e92@example.com','$2a$10$wrpB0.JUrSuLSPflRNOeJuilYjLLAtqfwGmceGYC6shNiA8Tfk.L6','CUSTOMER'),(3,'Test User','443f3c64-e1ed-4e17-b5eb-36557651ca3d@example.com','$2a$10$7UnQMQhKx1Rm8PqE/UQ3ROx3ijqkLo0Qh832mrD4s/.RJKTeY.Hsu','ADMIN'),(4,'Test User','9c9d53e8-c30b-43e5-af32-9e370cc8ba91@example.com','$2a$10$Ree49P5SbD4JTBLfW1oTIu9fV08RMHa17RBEgoYNEENe7gNsbMGjK','CUSTOMER'),(5,'Test User','d07c08a0-a71b-474f-a8b5-5acb0cc60fc1@example.com','$2a$10$z4hyJw2f.iNClX5C9JmGAuTUgh4.Is4mpVo8DOvZyIBLIcpnz1Qe.','CUSTOMER'),(6,'Test User','98b9330f-469c-4cc8-9557-0730fcf8025f@example.com','$2a$10$tG/AVzbTciT7WgrKR27DrOBtQdX3cOan7ZnkYOvxeHCkZYlVPBItG','ADMIN'),(7,'Test User','4b469ee5-5233-4e7a-b960-e6b3842f0b83@example.com','$2a$10$rUi.kWJeg.8N0UoNcVK92O9YoKxkg6URq9hv4xFKYSXV9r8i57nvi','CUSTOMER'),(8,'Test User','1827dadc-0c1d-42b3-99cf-a3f3d9256545@example.com','$2a$10$vkHk5N0m/bP/0my4pzrowOH1Fi1MDVlhQkhFVGGR9e1rGPBjI0TjG','CUSTOMER'),(9,'Test User','33129323-e4f5-4d6e-89c6-78ee9ac4c61a@example.com','$2a$10$oQ7zWKm5RVE2o//5xoxyOe/nDQS4uDImXX43m0UDr41wDJZ3pREnO','ADMIN'),(10,'Test User','4d3d1c59-ebc9-4b1c-9f32-38e4a778b06e@example.com','$2a$10$t.53vbtBxItid/ADE3i3w.pGXjizouUelCNyKBDTpDUcjPkTg9yqC','CUSTOMER'),(11,'Test User','5040d6fb-3c25-443c-b859-e603ee0a5485@example.com','$2a$10$TB88U9XTIGX2jr40piQ97.MxALxVaquL/zWtJMS0EQ5tMqtfXxZN6','CUSTOMER'),(12,'Test User','3b85765b-f315-4d84-b069-2555796fb3f6@example.com','$2a$10$XGcrZzmizG55T8dkgOMG0.b5DMukG8u855Mk9FPDBGVvxKTv72x2q','ADMIN'),(13,'Test User','dae46e0c-560d-435f-ab9b-8d6d78af0850@example.com','$2a$10$iO/BfuIM1Sy9nL4dRPwhou8xNaSahoSORJAjLHP4t8qQkNzJBteTO','CUSTOMER'),(14,'Test User','a54322a1-7fe3-4f49-83ff-d523b8b9f9e1@example.com','$2a$10$ibZdlZjYIlmdvmuZ.JUKMOBauj.UXrH/Yj73nHxnGMOtTL3SPULLa','CUSTOMER'),(15,'Test User','13870e74-64ef-40c7-9518-47e16522ca0a@example.com','$2a$10$vzYiAeqm1wfB3WvvACMTROzZUxOr5hkLWl1BE0H4aCyrE9F/ccIoq','ADMIN'),(16,'Test User','2fcd18b1-3140-4120-a889-9c205eb8428e@example.com','$2a$10$IQJBIKw51oodlMaER0oXWe0dTO2rx8W0NPV071QkInjWYlOmQQw7K','CUSTOMER'),(17,'Test User','cc8a4042-d8f2-466f-8c63-330635e42150@example.com','$2a$10$uW5YMvhKVU4vEjqyLGmupusNuhkQcFo5s8Ftgdku51AWykGj0meKq','CUSTOMER'),(18,'Test User','0a0a21aa-9803-406c-9544-aeff120ae34d@example.com','$2a$10$ofd/G7Q7ZeI.Sd.emE8IrOOpmG7xVkyhRUC7QvNLUcqDtrY5/P0ue','ADMIN'),(19,'Test User','6c9340fc-cc22-4c0d-acf5-a9db48bfae38@example.com','$2a$10$rdJ3ZroH8VqRY0b1G93tU.y6h9CT6TvdWX10N7bTTQZPcbOCAgEii','CUSTOMER'),(20,'Test User','2c63b558-07fe-4eac-af61-e32a844ad82c@example.com','$2a$10$PRUT/2cqlh5gIbXAW7TlQOu2s.JumuHcXrVyJFtzVPZd/kNjmuTfO','CUSTOMER'),(21,'Test User','9312c2f2-3429-4dd4-935a-abfbb98eda27@example.com','$2a$10$bBZCF03gQnDA.nK6XPrbEuFLuhWijRMDzx1ecY6b/ufRCoF.Deazu','ADMIN'),(22,'Test User','8608bcfc-889b-4137-af36-01070415f222@example.com','$2a$10$d5Upt5LkmY7a/mUVTfUXeOeq2BRSxUD11l3MfdV5lbE9.DhwViLk.','CUSTOMER'),(23,'Test User','d6d27b3e-3409-46d7-9811-aa21bc3922d8@example.com','$2a$10$g/.4gXfHyad0LRHUH8.DMuMCp/rG3ONEaAuDcf/BvEgHK0mC.5moe','CUSTOMER'),(24,'Test User','b8f424ef-6eae-4a52-9b9e-658251e84739@example.com','$2a$10$yiasDTjaswbowlNUM0ayruh340nSLh3mxy1.lOs4mHq.dupIs/zQC','ADMIN'),(25,'Test User','89e9a604-6231-4298-a412-c973f2dd0ac3@example.com','$2a$10$ubbbAGoIENh5C.fxkzvTPu7NnYU3dnvBgaqzbcRKOvii8UpVWpSha','CUSTOMER'),(26,'Test User','3aa05426-8df4-4cd5-88da-5bbfca7024ed@example.com','$2a$10$4icWFQDtfnnUJ4H3OIk5YeRp9jwwelccdfWNEhNf36Lmqg59WmyCi','CUSTOMER'),(27,'Test User','aeff5b7b-116a-4b44-809f-b62d9cbe50ef@example.com','$2a$10$BceuEPCdS02.UQxBo1AseO1S0DYNf4XaoZgzMrJ2beOH61RR2Sweq','ADMIN'),(28,'Customer','6a2e5901-15be-4e7d-996b-cc0e4d15b9a7@example.com','$2a$10$sypaskElPDKzGscHaQVwsuBdH7syhExQqEGh8h.10yApvA/WxYbJa','CUSTOMER'),(29,'Test User','e122d2fc-0ca2-49b4-aee7-1d584c9a1b30@example.com','$2a$10$q/9/bMbexei4v7lj/O4hFuhRpLCRa6FCbPPlFjHNoFDjd662txAeW','CUSTOMER'),(30,'Test User','34635923-4902-4ef0-b721-7969fce0673c@example.com','$2a$10$IR.6Zs.sYcb8S93b6q7crusZXSmJl6sML87KYbNra6NiveDmhZD7S','CUSTOMER'),(31,'Test User','9df12b5c-f781-46a2-9994-bbfbab83297c@example.com','$2a$10$Ng7ut8SgEt2tWTzQvFGvIuE7rUuh.xA1TLMRcJDJBKvFY2wfpwTZ6','ADMIN'),(32,'Test User','da1924c8-5741-4bf6-91a3-16276d2bc1cf@example.com','$2a$10$iDHfT4KeYNjq7G/AzBX7zuQbtATj3gpy0ey13lAT7e1i.bKjRxDpS','CUSTOMER'),(33,'Test User','a500bd6b-e9dd-40db-b074-b92553eade4f@example.com','$2a$10$/emQS/bNlmwtN9UiEkCXpeRqHUx8ChlnIw5Xrh0BLKy7byyXBaGWi','CUSTOMER'),(34,'Test User','b8646c74-c285-40e2-8b63-96c16a73cf1c@example.com','$2a$10$hp65OEbpEJ76fe7no57.SOc5S/PXgnn8cu1904KY.E6ZTwBrAIpdK','ADMIN'),(35,'Test User','7fb85541-6ea9-4fc3-b3f1-6190e0da8a38@example.com','$2a$10$uB2aGi2UynZRlCnAvwbz8.lE..qllXGbZG6bynsJWVf7wR9yj8rL2','CUSTOMER'),(36,'Test User','a27e9b07-c474-4657-b1b7-16a24602f39d@example.com','$2a$10$4W8u0ZIlS4P/5mHZx3ZcCe2B7TKMxlrJybL0j608QnvEi./6Shq7C','CUSTOMER'),(37,'Test User','1d462344-7c72-4972-9c32-310c4f653fc5@example.com','$2a$10$ngjApNWBcwAyMYyKIEpwxumep3HFmon36MbNbG.MnOhpwadLR6RRq','ADMIN'),(38,'Test User','3a83a2be-8f81-407a-bace-af2a54f397b3@example.com','$2a$10$asOiGyXe2dCWhL2l0/cVtOUiMklW2tmKBOivPbKVQa8eLH1LJYPZq','CUSTOMER'),(40,'Test User','26d2f501-69d1-4ab0-b7a8-a2539284ee19@example.com','$2a$10$3N2mVDTQKT6J1O8YL6Uyhe1uhybKgLogvtZeKoOmZA6OrQlmCcsGK','CUSTOMER'),(41,'Test User','e4c5c351-ed49-4048-b525-67faef1b807e@example.com','$2a$10$Fe57y88cjfL16BQft9W0teYhqJE9JkLO4Pdl7aGGgl1fVj7za6AYS','CUSTOMER'),(43,'Test User','d7c24a81-c3e0-4ea1-a6bb-88d136e39565@example.com','$2a$10$kJIGcV3wzpn7s3op1mFjfOlaRI9HRGa0ZvSvQVuV.dT1K0QrN2SMy','ADMIN'),(44,'Test User','3d83f1ef-145e-463a-8dbe-7d96ebc64479@example.com','$2a$10$xPJJKd1qGY5/v2wb8V4uZu6Xfhiqj5MvfwZlZzNmUTukck7JEQG0u','CUSTOMER'),(45,'Test User','e337fc5f-eeea-4fcf-9ffe-53b17a038048@example.com','$2a$10$PtXvsCqXQRFHwYkyY9bRP.IESllBGSdL1QA3WidTbHTyQtMoiGMaa','CUSTOMER'),(46,'Test User','f1ca1bc0-ff97-4c00-9fb3-01f6f4047aba@example.com','$2a$10$Pi1kF0GxN7eFrUz9/5SUCe6lZ7Vmedhd.j0GTIVUdDvVA098AoRlq','ADMIN'),(47,'Test User','ff8a4aa1-badb-42ca-aae3-69754f3e8b54@example.com','$2a$10$Xj6GDgJVEvBjfccz0TCTK.8tOAlyTZMjrE..nVjIjVtfOtKNhzaC6','CUSTOMER'),(48,'Test User','fb7aea6a-ae62-4ae8-90e3-0b89cfef5a2e@example.com','$2a$10$c3kq.2NX16PLljaI6FJSauJGQIJ9S7/UxHN0/wT7Z7a9tIi/mcyQS','CUSTOMER'),(49,'Test User','ee346121-76b5-4905-99ed-66a413cc911b@example.com','$2a$10$mwU6QoQ2bsT9Yv6ICrQTrO4SPV0nmvrIBoRdaij5jr.yUq13/cGjW','ADMIN'),(50,'Test User','56414dbe-5074-4659-82ee-a3f181c045db@example.com','$2a$10$dI7UqGBCMorIQQ8/7gzheeu8ZltSSXLfj7mALM.lGo4vxwuEbh4Ui','CUSTOMER'),(51,'Test User','8eee6324-e9c8-48b5-98a0-c3fa1e8db7f2@example.com','$2a$10$8SFGLOdRqxuPd1CMXJ1F8eFbe50r4RU7biPjANDPziISRQPxRPRDm','CUSTOMER'),(52,'Test User','07c50344-fa03-4e30-9bf0-77b116e5e80a@example.com','$2a$10$Qxl.7xiZUxXpR0LcY7hweuGG/e2MSMk/xekncLEsipDEOujDsaCha','ADMIN'),(53,'Test User','3ed247e6-7f67-4156-904c-f948b675bf30@example.com','$2a$10$ppkyv2VkGVswrlif8jVSqeKj.IGJXhh6Gc8aprgB5cnZh/kc2gzyq','CUSTOMER'),(54,'Test User','e6193cd9-db17-4885-b8d2-0fbe62492698@example.com','$2a$10$Uj/bCZbqf9MvQxYZ6e9DUuImWcxZDD3Uxm2eOMCIebD67eX2iXtwW','CUSTOMER'),(55,'Test User','2832a6ad-6ad4-4288-a2f1-26b3a3ba674e@example.com','$2a$10$.Fu.7MuuLRmgn6QjPeB3MO86aBhra2Yo73Yj03/BECs0X58SgRwE2','ADMIN'),(56,'Test User','8be302af-a1de-4e95-adaf-7f794fc9109b@example.com','$2a$10$Ta/f8.U5pwNAvFCZTR2xaOSXzVGjfkJBdClUcBbfShzcfq1lUOF..','CUSTOMER'),(57,'Test User','103469c4-2f34-4bbf-8c5c-9c52279a3692@example.com','$2a$10$gg4e5T/oMuRLTjqOcoF7c.CBIlhZyuAsjUc4TpkGrVqkJtJGZv9Cy','CUSTOMER'),(58,'Test User','b63bb197-bc62-4564-95d5-e551ca6fe10a@example.com','$2a$10$q7t1ipiOBzbNoCi0MyeFRec/vt/pMqUt/xZI7uuUnxgJSDDZX31Ry','ADMIN'),(59,'Test User','e7e361f8-9405-4a0a-8c01-cdc28ff9dafb@example.com','$2a$10$NGLmPG4PT2ml9fx3qDVEWepAt.kNg8gCNWBIdHT4vpKCdeIqSQ.3i','CUSTOMER'),(60,'Test User','91170ce2-0ee0-4bd3-8a79-bfad66ffd0a6@example.com','$2a$10$mMfIxzogpuzp3nVxM7p40euipgjBFzDuDu7VQ9/GfzWT66ZCE6qj2','CUSTOMER'),(61,'Test User','13d1c0c3-97f5-4930-86fc-1498b44b5d1f@example.com','$2a$10$P2HtQrzxapXdaojbFveFKeH7VzzGnohI2kmLviebmyiC5JxQQDVPy','ADMIN'),(62,'Test User','edecc34c-a1c3-4ad6-8be5-a5464c5156a3@example.com','$2a$10$Ktzyp0RV5fKMrNswHUIVfOfa6qRrg4Sl83qdjf18MPcbi8Tk17TEW','CUSTOMER'),(63,'Test User','99804bd4-bb0e-4dd0-8b84-e812271a7e5a@example.com','$2a$10$2ei1dimv1pcJEwdEMmosU.dNiL3n9htzxaCPAwFMzaQqRvdRubmX2','CUSTOMER'),(64,'Test User','d5328de6-6d79-407e-9ac1-192b77f658d4@example.com','$2a$10$w4Mj5koHWv0BqMzR.lrJE.HHENckZgxPCvIbwvistWLidMrzo1IZa','ADMIN'),(65,'Test User','e936a1b7-faa7-4191-9228-922d2570d44b@example.com','$2a$10$kLSimg/NOzRfVTiSLq/5GO2g2AMGx6cIyF7sOy3gKSAoUr7FbsiSa','CUSTOMER'),(66,'Test User','97ac6e82-c004-45e2-90b6-68051cfadc00@example.com','$2a$10$QFXazupMPC71jeQg.3CTeutyJ.BAhm2cDztZfDArQfNDL3O60BPK6','CUSTOMER'),(67,'Test User','d226cd2a-b3de-4b8e-aa75-adff8ee3e612@example.com','$2a$10$YLd2EfRlvAbPBoX7NS9mhOdjtrcvt8FPA/Hmk04a/M/8UfD4/yVG6','ADMIN'),(68,'Test User','4dd81cb6-70fa-4e2b-a4e9-f7067f98cce1@example.com','$2a$10$MIJVGaHBmHxTVGWd7e06Q.szET6/XaRGCewTZ0gIwjdlb.ZcM6Kom','CUSTOMER'),(69,'Test User','e16dd1d3-a35f-4676-9d64-b88078365ff3@example.com','$2a$10$Wih0lLCEx9pV5hCOzKdx0.irrUcxQ6aCTbgGs5QizW3WfW44pG1Wi','CUSTOMER'),(70,'Test User','d7d9ebd0-530d-43d6-bc28-11c643d35968@example.com','$2a$10$0XG2x8tNmz6UgW0G0nNHLuXBpbrepnskm2boMSW9q559c0QIIHPVu','ADMIN'),(71,'Test User','74a77568-84e2-4a6c-a8dc-da2919db53ef@example.com','$2a$10$3HQF9XRHj4B8OW6sN8qXnu9dj9ZQ2ePeUJH3JJHwVNZ13hWOc2cZS','CUSTOMER'),(72,'Test User','046dae92-1547-4aaf-b672-5676775ee0f6@example.com','$2a$10$LRGtx6qVsS4GQzS1sbBAXeihDvUugY09zTFCOWgdX/zYv1nQfzjuO','CUSTOMER'),(73,'Test User','28b90e9d-999b-4ee1-9b69-0baa30b81dac@example.com','$2a$10$Ct3ua6FEjk8ou66dxl6ffek1ws5wr5TKN3tDuKb6t2gSMPc4Oe7mG','ADMIN'),(74,'Test User','9fba899e-144f-4334-a78b-6139c78e1c4b@example.com','$2a$10$t/rqVdHkhhnoOoz9kjOSj.SnRaunGdQr.m9NaBsb5lGzNDNbvIiui','CUSTOMER'),(75,'Test User','96af3786-abfb-4737-9f98-206db1fd69d0@example.com','$2a$10$TwHLMwUmqX5sHDNQsFINZebPdYvY1/9s7diq.qaGIe7r82VDD7GK6','CUSTOMER'),(76,'Test User','359dc647-7c4a-4af4-9032-211ea2020628@example.com','$2a$10$J0TYAwtiodj9/iHEmx44vernE/D2.lhE.DX1evq2/RI8Hd6jGt/ai','ADMIN'),(77,'Customer','6f454510-77ab-4eee-bc88-7368f22d196d@example.com','$2a$10$2xcoYJGXJIA9qwendTdJku4EHjB84.FR3QRk23v/B2Tnr99pcp/YK','CUSTOMER'),(78,'Test User','d5297176-82c4-45fc-88da-bfa46ec0d64b@example.com','$2a$10$jkubgbXT5GdFN9WhxNb21OUYEAMHbN08bKsoGXwQpinahbstBYpUa','CUSTOMER'),(79,'Test User','7a3ebbe7-d7be-4957-98e7-658cc7b834e6@example.com','$2a$10$.0lfGJI532Ekh06Vpzz7vuBfW6UtflzRfBAqe09nubqw9BDoH0LHy','CUSTOMER'),(80,'Test User','13023255-eae7-4c4f-8d55-1ae6bc6d3c0b@example.com','$2a$10$bfBiB9HUvLaAidM6qRu7eOzDh7p.3HxBlIQUKkhNfon9kCKhRMsHS','ADMIN'),(81,'Test User','95d221f5-de91-4851-b4cd-de2d05b6fcb3@example.com','$2a$10$dN7zd.w0s5h2j14c5DCQWe0cQu06sAR2q8d6KArbY1q4t8u99IGcu','CUSTOMER'),(82,'Test User','07104c0b-9729-48a7-baa1-4dc1dbff9b2f@example.com','$2a$10$tNkVHXPFLRs5iNCx9JJyWeSPBFf1HBfJLqGgkUE09RK29dhPq4Hyu','CUSTOMER'),(83,'Test User','a5459b8b-d924-4e59-81d8-94e1d1d62505@example.com','$2a$10$db3hYDFT45RbEquZmkyYROGP/LpNpcp47AQdmSXYCdn2SnK3kIBre','ADMIN'),(84,'Test User','f6ebea9d-3acd-4a7a-a040-5c8fc1a4dc9a@example.com','$2a$10$QeUdsXdCqIX3wLnDTdLHhugy8UzpS4nJjEy6oOrl6iQQmU9eHV.2O','CUSTOMER'),(85,'Test User','a835fcbc-f0a6-4086-b045-84a6cf9410e0@example.com','$2a$10$JHEorCypg1GephNH2nYts.1NaiimG5UWItgesJsW0M2hG25ch8lry','CUSTOMER'),(86,'Test User','c8a08d4c-eb4d-42b7-a212-d8110f935799@example.com','$2a$10$421wHAGaGc8f6cYIgO.q/uQVaf75uUA80xs8EWA65cneWFkZl5rs2','ADMIN'),(87,'Test User','e32f7ab5-e390-4b52-b9cc-7a8daf9c918c@example.com','$2a$10$8IuaAAbVNlcWq7/70B/zTeGJRuJeCbpJt6BbZSTyjH0UfywJQET1a','CUSTOMER'),(89,'Test User','53d1b170-bf3b-4a1e-9a33-0faaac9567b9@example.com','$2a$10$E945DXCJ9SOcBPepJ1DxYOPVK1Il3bbSoJXOa4HyAXRM//J44GQBS','CUSTOMER'),(90,'Test User','c33d96db-5e0d-4802-b27c-29165f4a4a0d@example.com','$2a$10$pjDqBqyPstgwWYaYpf6Zm.HP406fQaAMTcWDPxJDqd/E8ZpWn2y8S','CUSTOMER'),(92,'Test User','d8a45ee7-439b-4230-9f7d-64916a99ddd4@example.com','$2a$10$aFnoTT75/oRAXB2QFh9NUOHf.6ZIlpbWkttD2LSycSjH7l4uFhn8W','ADMIN'),(93,'Test User','29bc3bd7-23fb-4368-9188-f3f9f54422a6@example.com','$2a$10$5y1.34z0lKbmfK70jT1LjeYzPfYeZ0vhB914TKG.zvt/ANhAfDJqe','CUSTOMER'),(94,'Test User','b798531c-bc15-4312-a910-7ab7231a9f46@example.com','$2a$10$rr9O8qb29FBOmm9.r6dneOKoBfawAMUgs5UtcWcKDHlG2SJbSHFLy','CUSTOMER'),(95,'Test User','a0d1c663-f39f-4be1-8576-3b1f5fb005a1@example.com','$2a$10$qxZJBA9VW5EezvNPrkzOle9/AY5TcTTszc431zGb0wetCaVhzE/gy','ADMIN'),(96,'Test User','8c098bae-cdc2-491a-af7f-774083092cab@example.com','$2a$10$Z9QTIekQWUdOARlWDeSepuXvIwNUPau6fbfw49So2/Q2wCnggsjVa','CUSTOMER'),(97,'Test User','8206a2cd-f000-474f-b1e5-dbe3731ef82b@example.com','$2a$10$U2MvVc11gIJC9mSsWVHn/e40Bph3Jfq/3NMsh1tNNJVGeofosmmLK','CUSTOMER'),(98,'Test User','3668f2c4-664c-4f48-b8d2-2003abd604ea@example.com','$2a$10$xzF76LvPqWTrjqj0qkU7P.e1NqDK2IfRH0bAWRjCaCiYjG/ezDo3y','ADMIN'),(99,'Test User','6a547374-3596-4c54-b7c5-e2af4183619b@example.com','$2a$10$XKPQaOLwhDlAk5Lqxyp86eZFZs9cYVlzlUuUEL.OAoaEFWb3i7M8m','CUSTOMER'),(100,'Test User','4660f33e-7aad-4b5e-acc2-616fcf93fa12@example.com','$2a$10$zUlKbUbjlgu.u2FdjI9/t.weQRdqk9kotx.LJZsBTpQu.BeoetW1C','CUSTOMER'),(101,'Test User','b4cc3524-7471-4bb0-9330-927d66d18172@example.com','$2a$10$ZmiNiVnKeZlfk0xCwJgtf.QNBm8AhAf3Zgrcm4OGrDJX0jt70nevq','ADMIN'),(102,'Test User','76071976-4016-4123-ac40-02475c217e7a@example.com','$2a$10$VVlPx4IesrtnR3hWFaXqCukd/V0kUP0hZmSfitvT1vkiL/w9xqal.','CUSTOMER'),(103,'Test User','e5fdcfed-1502-4724-a260-ee35883ebbfa@example.com','$2a$10$NOv0uV09s3QQEMe6lXiWLOHKHTMHa23PuK5TaN87/n52A5/RlvJKi','CUSTOMER'),(104,'Test User','1626d1bf-7d7b-4990-8dfa-c698ebf19398@example.com','$2a$10$gDdszlWNSBppqmp/953ksOtI0xO2REgJ05OAZl99BnZT5ri1Sdza.','ADMIN'),(105,'Test User','d91b5246-3a78-4190-a1b7-d71ee0dee3ee@example.com','$2a$10$y96F0y3r4Zlgwi7x9go73OrEMN34LSULqkpXHH/RvZtAdPJLinpku','CUSTOMER'),(106,'Test User','a296f412-b466-45b2-915a-236abdb4cca8@example.com','$2a$10$g/v//nqP8Z5qOraadQvX0u54Pcpe6nhyCyJa/J/iQ0nzy0eO5eDAC','CUSTOMER'),(107,'Test User','c3138574-3aea-43d4-850c-37f9c235a295@example.com','$2a$10$1TBVJFjFpAHnBdjwMNFqlOeJdUxz2O2rNBo2ieYDPaMo34si9RP1K','ADMIN'),(108,'Test User','6553ba9b-9713-4005-9cf6-0ee5ad09513e@example.com','$2a$10$oOrDdP0Qe1XStrNt49yYeOXq2hF61YSI5u2elaiZlX2A0dJgr0BtO','CUSTOMER'),(109,'Test User','53955420-0f8c-4f33-94e2-687eb07cb7bb@example.com','$2a$10$cwKxFEkRFY2cX3r4k4gjWuOy/ntmNe5XLsO/7iPJZiw.Iwla7QuxC','CUSTOMER'),(110,'Test User','0fbd2d01-a6a8-421d-b4b3-fffc7280aee3@example.com','$2a$10$w8T430ttpavJqsEQpXBbK.qez7G.X0cSh4KvlV415fCNPH.7T7FiS','ADMIN'),(111,'Test User','9666175b-1e4a-4c20-88f0-dd6edf392203@example.com','$2a$10$/WnyclfISUmE/GoaXdm15.U370Tx0FBkmKmNOfvJf3M3i9kUANWTq','CUSTOMER'),(112,'Test User','d73dc69d-8bc1-4fbd-9726-376dbe067ec2@example.com','$2a$10$dSPC4htIkfjPUVsL0N9xV.m6XUSGHRu2pPmdPOURc6OTxfQVOompu','CUSTOMER'),(113,'Test User','3abc472a-d510-474e-91a4-f2f4087363d1@example.com','$2a$10$jeOje1EMajrENoDQdQcSM.c.uvETQR9eE9vZcadAtAehy9fB6OTzG','ADMIN'),(114,'Test User','0ed356e1-5dec-44ac-80ee-2c7e47eb8b6b@example.com','$2a$10$WrMiJzIHnwN3P1nBpLyBXutH.vWAble2lKLzbm6aEwzYhI5WiOROW','CUSTOMER'),(115,'Test User','51f1a493-116e-498b-a71d-28128cb192d3@example.com','$2a$10$G.Gzi81iVrAWMOLwX4usBO1leYbBwv8TVxTPg5dNHIOo5G9pPQSuC','CUSTOMER'),(116,'Test User','36b3a035-4c4a-496c-956d-fd4a626ccd5b@example.com','$2a$10$2cI2N5NhjolEcmoac0Kmp.lhK4AOITzHPRNViv5Ya52lc88MP6TCy','ADMIN'),(117,'Test User','ffb7cc8c-6c3b-4a9c-a830-4c1568caff6d@example.com','$2a$10$w37js2bM0/9WeZ/HlMc1VOoGTH6gzn1k/xTjL53aWufBPn6lK8eTG','CUSTOMER'),(118,'Test User','66725106-dd56-4647-9c04-06c0dbec22f5@example.com','$2a$10$c1EBaIN/qbrvIo.cjNAUqOoT8vbK/twYXk7TO3tvwbP23GZQ9uP0q','CUSTOMER'),(119,'Test User','8c7f40d9-e91a-4979-8e68-8a84f2214758@example.com','$2a$10$9Chjf68ekKG/VxB6mu8TWOvjVLG293wtwe3qtiemZFi8knvuETziq','ADMIN'),(120,'Test User','0fd2c683-0950-43c0-b028-99095f8f0c5a@example.com','$2a$10$fD3puq6t9rMyeVhzIGL41u.I8nMjWTJ.LrjpLr2XiUG0t0afJdTT.','CUSTOMER'),(121,'Test User','d2646ebb-468e-471f-9a53-bc3fabf42a70@example.com','$2a$10$w50MeluiYRVCiFpDJhzApeEvFhtV1LonKCwtvR4GVbJbsQolVZHAq','CUSTOMER'),(122,'Test User','decc3d77-caeb-4447-b775-29657bec6bc7@example.com','$2a$10$AwEdTyp7mt4jY56q5g5p4ufJWb1N.iIWgZcORyU9kD22.m971.hzq','ADMIN'),(123,'Test User','6f568604-3a49-4ad9-ae57-6bd39d3c7c6d@example.com','$2a$10$1SjXtGLoZO.2sxpoYLE70ecV/XzVM4O6Fe.DOJg7ZAhAQbs5UXXZ2','CUSTOMER'),(124,'Test User','b74f3ba1-02b6-40ba-8bdc-a0c59095b545@example.com','$2a$10$5tWLiMXV7CsC/P5OaefeEev4ey4OIhD5Eg0WLtOGqWZzR9m27MOhC','CUSTOMER'),(125,'Test User','16101d85-d22a-43f8-9486-61a81a8bf142@example.com','$2a$10$ofPOW/vTAL9EYQzGglUN7u3Z9nNSjYNYiZIwHrr0YxFXfqU498XOq','ADMIN'),(126,'Customer','97f704fc-3405-48d1-8d99-64169386d5c5@example.com','$2a$10$lSDGVYpPXX1JPwCcuTMDG.3Imo5IoBVMIEswfdsOC6ElfcQ3AzgO2','CUSTOMER'),(127,'Test User','87e47210-81a5-4e15-aa5d-793fb813c1d3@example.com','$2a$10$hPxDdSgx9ocgos/cHY9guu/Ukmpus2d9OLPjWwqVpxH53V/J4fUdC','CUSTOMER'),(128,'Test User','6ce3905f-657f-46fe-9bf4-d83d6fa74015@example.com','$2a$10$EpKqwr.p0r.SkU2WvyJvFOhHeWiWzYoIwJMdZfxw3.Ra0XM4FEeeO','CUSTOMER'),(129,'Test User','6d989ec5-77ea-458d-9226-aa4489f96ac0@example.com','$2a$10$XF1bkIzRgytozbxSTqaKAOfoTP4oqSO6IYtMQ0.lo8Va.dtv94FCW','ADMIN'),(130,'Test User','2f78ee07-6c37-4812-ad03-1ace65ff5a69@example.com','$2a$10$elc/lA6zwc/Ka1RECjnMoerMiC4wXdunOZ7yklhsp/BBH4v/tAUR2','CUSTOMER'),(131,'Test User','310d25e0-68b8-403c-a644-7cdf60ad84f7@example.com','$2a$10$TM86JNdjaVDwTS0LrE4KR.pkgbGkPxVi7IRbIOsWiZjpf4JxsCK76','CUSTOMER'),(132,'Test User','3ddd9cc3-8e3f-4b35-94a3-6ce7edfb5d33@example.com','$2a$10$WmL2MO9vy3CjUzZfjo94VuRT4TBZgGQ6f7n.wUXQAFurNBasRbkhS','ADMIN'),(133,'Test User','75ce9942-eb4f-47b5-b39d-ab3b6cead22d@example.com','$2a$10$gVcI9ZOlNW5.stP/o6jR1uUd6nJR8z6qD31.opT9K7a/I4NXIzvwK','CUSTOMER'),(134,'Test User','23658131-ebf4-4826-b883-60377aa074e2@example.com','$2a$10$Av0V/qn4OPmoA9rTPsWR2u3Jp3u5mrZkW9Cw8CP/3Ddx4UEVvAba6','CUSTOMER'),(135,'Test User','36f5e7f4-d591-4502-8c80-c046eecea330@example.com','$2a$10$1ZGlGdqR6F0MKRZY4zoe/OuR0cXWTRL7jwrbhmZD95O08Vhbz2NjC','ADMIN'),(136,'Test User','a177173c-10b0-4844-9f98-e3b41f64aba5@example.com','$2a$10$4qWTSez5IB16pHbjx4C2/O8DpsgmQeo0dY.5qd6B8qFRCIvS7V0Pu','CUSTOMER'),(138,'Test User','b1b3bdf8-bf70-47ab-abea-aad25cc47169@example.com','$2a$10$UzbTbHd6a7l60Yp0HO4J6eZJQDgjLmbp4ZmMKsJ4ONpUhptTh8NOC','CUSTOMER'),(139,'Test User','e66c5fef-fec7-43d9-8735-69f1a30ab110@example.com','$2a$10$x9e.RITeV6TGFgM4N/TDgeJBOv3jdM1YrWfmmp5INDWvcs7CNc5Fq','CUSTOMER'),(141,'Test User','10b546c0-7d16-4f93-bf9f-50d8d993afbb@example.com','$2a$10$I5IKWPAnlx5lSCwBruD2CerJOZPNlEMEu0mnHGb0QiERm3BgWVGd6','ADMIN'),(142,'Test User','198b83aa-08fc-4cbc-acca-e9f69c21c5dd@example.com','$2a$10$.wPzgPn48oYNUKhXS7sXBugWXNULBf9Bg6F8c5ePkird78paLuDdK','CUSTOMER'),(143,'Test User','c83fc483-a9cc-4c00-ace4-32703d523863@example.com','$2a$10$8TOeK3x0oIShPp8FdsOo5.ERfCgCV/zNdNzcCJmH6qvGcb4Ii1Nh2','CUSTOMER'),(144,'Test User','fed8d22f-37c4-4e18-aa8f-bc5d1193d199@example.com','$2a$10$KxhCnEXnP7Lsxb3LPsfFvuMujfr/0W7zyIutR44iUlY2sdkGl9aaK','ADMIN'),(145,'Test User','a6adf565-a5c7-4a7b-9aa4-c37e75b1fb6e@example.com','$2a$10$.o3Q8XaEWPAVVVBk9eFw3.dr79ht5TEJorFW.8KaDd3pU6ifMgIQS','CUSTOMER'),(146,'Test User','f0157df5-15ce-4270-992b-4fc4a02acea9@example.com','$2a$10$bz8HTCCbaGSJ6Bg4NKfzB.nXEvevHqH0UXE3w0UWetL1aF1CKvOT6','CUSTOMER'),(147,'Test User','81c841b8-89fc-435b-8587-26f7084b0c5c@example.com','$2a$10$ZruA.C43SmiVB/KVRn3Uf.60cQ2p5lWB1/z4HtFa562n1/ZKeOery','ADMIN');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'movie_booking_test'
--

--
-- Dumping routines for database 'movie_booking_test'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-11 18:45:30
