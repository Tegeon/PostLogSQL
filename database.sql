CREATE TABLE `postfix_logs` (
  `id` int(11) NOT NULL auto_increment,
  `postfix_id` varchar(128) NOT NULL default '',
  `message_id` varchar(128) NOT NULL default '',
  `delivery_success` enum('yes','no') NOT NULL default 'no',
  `status` text NOT NULL,
  `hostname` varchar(128) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;