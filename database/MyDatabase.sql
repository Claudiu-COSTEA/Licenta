use wrestlingMobileAppDatabase;

CREATE TABLE `users` (
  `user_UUID` int AUTO_INCREMENT PRIMARY KEY,
  `user_email` varchar(50) NOT NULL,
  `user_full_name` varchar(50) NOT NULL,
  `user_type` ENUM('Wrestling club','Referee','Coach','Wrestler') NOT NULL,
  `fcm_token` varchar(255)
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
  `referee_verification` ENUM('Confirmed', 'Declined'),
  PRIMARY KEY (`competition_invitation_UUID`, `competition_UUID`, `recipient_UUID`) 
);

CREATE TABLE `competition_fights` (
  `competition_fight_UUID` INT NOT NULL AUTO_INCREMENT,
  `competition_UUID` INT NOT NULL,
  `competition_round` ENUM('Round 32', 'Round 16', 'Round 8', 'Round 4', 'Round 2') NOT NULL,
  `competition_fight_order_number` INT NOT NULL,
  `wrestling_style` ENUM('Greco Roman', 'Freestyle', 'Women') NOT NULL,
  `competition_fight_weight_category` VARCHAR(10) NOT NULL,
  `referee_UUID_1` INT NOT NULL,
  `referee_UUID_2` INT NOT NULL,
  `referee_UUID_3` INT NOT NULL,
  `wrestling_club_UUID_red` INT NOT NULL,
  `wrestling_club_UUID_blue` INT NOT NULL,
  `coach_UUID_red` INT NOT NULL,
  `coach_UUID_blue` INT NOT NULL,
  `wrestler_UUID_red` INT NOT NULL,
  `wrestler_UUID_blue` INT NOT NULL,
  `wrestler_UUID_winner` INT DEFAULT NULL,
  PRIMARY KEY (`competition_fight_UUID`, `competition_UUID`)
);

ALTER TABLE `wrestlers` ADD FOREIGN KEY (`wrestler_UUID`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `wrestlers` ADD FOREIGN KEY (`coach_UUID`) REFERENCES `coaches` (`coach_UUID`);

ALTER TABLE `coaches` ADD FOREIGN KEY (`coach_UUID`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `coaches` ADD FOREIGN KEY (`wrestling_club_UUID`) REFERENCES `wrestling_club` (`wrestling_club_UUID`);

ALTER TABLE `wrestling_club` ADD FOREIGN KEY (`wrestling_club_UUID`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `referees` ADD FOREIGN KEY (`referee_UUID`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competitions_invitations` ADD FOREIGN KEY (`competition_UUID`) REFERENCES `competitions` (`competition_UUID`);

ALTER TABLE `competitions_invitations` ADD FOREIGN KEY (`recipient_UUID`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competition_fights` ADD FOREIGN KEY (`competition_UUID`) REFERENCES `competitions` (`competition_UUID`);

ALTER TABLE `competition_fights` ADD FOREIGN KEY (`referee_UUID_1`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competition_fights` ADD FOREIGN KEY (`referee_UUID_2`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competition_fights` ADD FOREIGN KEY (`referee_UUID_3`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competition_fights` ADD FOREIGN KEY (`wrestling_club_UUID_red`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competition_fights` ADD FOREIGN KEY (`wrestling_club_UUID_blue`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competition_fights` ADD FOREIGN KEY (`coach_UUID_red`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competition_fights` ADD FOREIGN KEY (`coach_UUID_blue`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competition_fights` ADD FOREIGN KEY (`wrestler_UUID_red`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competition_fights` ADD FOREIGN KEY (`wrestler_UUID_blue`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competition_fights` ADD FOREIGN KEY (`wrestler_UUID_winner`) REFERENCES `users` (`user_UUID`);