USE students;
INSERT INTO `students` (`email`,`aws_user_id`,`accountid`,`forticloud_user`,`forticloud_password`,`fgt_ip`,`fgt_user`,`fgt_password`,`fgt_api_key`,`fgt_api_url`,`fad_user`,`fad_password`,`fad_ip`,`fad_ip_nat`,`server_ip`,`k8s_ca_cert`,`k8s_sdn_token`,`server_test`,`server_check`) 
VALUES ('user0@fortidemoscloud.com','r1-user0','12345678','fortiexpert0','secret-key','1.2.3.4','admin','i-instanceid','tajt49f8zp4g6cngj6cpbae8k','https://10.1.0.10:8443','admin','fad-password','10.1.0.135','10.1.0.136','10.10.0.138','k8s certificate','k8s_sdn_token','0','00:00:00 AM');
COMMIT;