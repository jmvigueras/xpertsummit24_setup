USE students;
INSERT INTO `students` (`email`,`aws_user_id`,`accountid`,`forticloud_user`,`forticloud_password`,`fgt_ip`,`fgt_user`,`fgt_password`,`fad_user`,`fad_password`,`fad_ip`,`fad_ip_nat`,`fgt_api_key`,`server_ip`,`k8s_ca_cert`,`k8s_sdn_token`,`server_test`,`server_check`) 
VALUES ('user0@fortidemoscloud.com','r1-user0','12345678','fortiexpert0','secret-key','1.2.3.4','admin','i-instanceid','admin','fas-password','10.1.0.135','10.1.0.136','tajt49f8zp4g6cngj6cpbae8k','1.2.3.4','10.1.0.138','k8s_sdn_token','0','00:00:00 AM');
COMMIT;