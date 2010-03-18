CREATE DATABASE `postlogsql`;

CREATE TABLE `postfix_logs` (
	`id` int(11) NOT NULL auto_increment,
	`postfix_id` varchar(128) NOT NULL default '',
	`message_id` varchar(128) NOT NULL default '',
	`delivery_success` enum('yes','no') NOT NULL default 'no',
	`status` text NOT NULL,
	`status_code` int unsigned NULL,
	`hostname` varchar(128) NOT NULL default '',
	PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;