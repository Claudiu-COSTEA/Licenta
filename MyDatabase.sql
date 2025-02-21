CREATE TABLE `users` (
  `user_UUID` int AUTO_INCREMENT PRIMARY KEY,
  `user_email` varchar(50) NOT NULL,
  `user_full_name` varchar(50) NOT NULL,
  `user_type` ENUM('Wrestling club','Referee','Coach','Wrestler') NOT NULL
);

CREATE TABLE `wrestlers` (
  `wrestler_UUID` int PRIMARY KEY,
  `coach_UUID` int NOT NULL,
  `wrestling_style` ENUM('Greco Roman','Freestyle','Women') NOT NULL
);

CREATE TABLE `coaches` (
  `coach_UUID` int PRIMARY KEY,
  `wrestling_club_UUID` int NOT NULL,
  `wrestling_style` ENUM('Greco Roman','Freestyle','Women') NOT NULL
);

CREATE TABLE `referees` (
  `referee_UUID` int PRIMARY KEY,
  `wrestling_style` ENUM('Greco Roman','Freestyle','Women') NOT NULL
);

CREATE TABLE `wrestling_club` (
  `wrestling_club_UUID` int PRIMARY KEY,
  `wrestling_club_location` varchar(50) NOT NULL
);

CREATE TABLE `competitions` (
  `competition_UUID` int AUTO_INCREMENT PRIMARY KEY,
  `competition_name` varchar(100) NOT NULL,
  `competition_start_date` datetime NOT NULL,
  `competition_end_date` datetime NOT NULL,
  `competition_location` varchar(50) NOT NULL
);

CREATE TABLE `competitions_invitations` (
  `competition_invitation_UUID` int AUTO_INCREMENT, 
  `competition_UUID` int NOT NULL, 
  `recipient_UUID` int NOT NULL, 
  `recipient_role` ENUM('Wrestling Club','Referee','Coach','Wrestler') NOT NULL, 
  `weight_category` varchar(20), 
  `invitation_status` varchar(20) NOT NULL, 
  `invitation_date` datetime NOT NULL, 
  `invitation_deadline` datetime NOT NULL, 
  `invitation_response_date` datetime, 
  PRIMARY KEY (`competition_UUID`, `recipient_UUID`, `recipient_role`) 
);

ALTER TABLE `wrestlers` ADD FOREIGN KEY (`wrestler_UUID`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `wrestlers` ADD FOREIGN KEY (`coach_UUID`) REFERENCES `coaches` (`coach_UUID`);

ALTER TABLE `coaches` ADD FOREIGN KEY (`coach_UUID`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `coaches` ADD FOREIGN KEY (`wrestling_club_UUID`) REFERENCES `wrestling_club` (`wrestling_club_UUID`);

ALTER TABLE `wrestling_club` ADD FOREIGN KEY (`wrestling_club_UUID`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `referees` ADD FOREIGN KEY (`referee_UUID`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competitions_invitations` ADD FOREIGN KEY (`competition_UUID`) REFERENCES `competitions` (`competition_UUID`);

ALTER TABLE `competitions_invitations` ADD FOREIGN KEY (`recipient_UUID`) REFERENCES `users` (`user_UUID`);
