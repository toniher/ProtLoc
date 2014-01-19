# MySQL Navigator Xport
# Database: prova
# flipe@localhost

# CREATE DATABASE prova;
# USE prova;

CREATE TABLE `ProtSet` (
  `ACC` int(11) NOT NULL auto_increment,
  `CLASS` int(11) NOT NULL,
  `SWISS` varchar(20) NOT NULL,
  `WORD` varchar(20) NOT NULL,
  `SEQ` text NOT NULL,
  `NOTE` text NOT NULL,
  PRIMARY KEY  (`ACC`)
) TYPE=MyISAM COMMENT='Protein set';

