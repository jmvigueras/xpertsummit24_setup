SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+01:00";

CREATE DATABASE IF NOT EXISTS students;
USE students;
DROP TABLE IF EXISTS students;
CREATE TABLE `students` (
  `email` varchar(255) COLLATE latin1_spanish_ci NOT NULL,
  `aws_user_id` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `accountid` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `forticloud_user` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `forticloud_password` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `fgt_ip` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `fgt_user` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `fgt_password` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `fad_user` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `fad_password` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `fad_ip` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `fad_ip_nat` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `fgt_api_key` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `server_ip` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  `k8s_ca_cert` varchar(8192) DEFAULT '',
  `k8s_sdn_token`varchar(8192) DEFAULT '',
  `server_test` tinyint(1) DEFAULT '0',
  `server_check` varchar(255) COLLATE latin1_spanish_ci DEFAULT '',
  PRIMARY KEY (email)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;