CREATE TABLE `users` (
  `user_UUID` int PRIMARY KEY AUTO_INCREMENT,
  `user_email` varchar(50) UNIQUE NOT NULL,
  `user_full_name` varchar(50) NOT NULL,
  `user_type` ENUM ('Wrestling club', 'Referee', 'Coach', 'Wrestler', 'Admin') NOT NULL,
  `fcm_token` varchar(255)
);

CREATE TABLE `admins` (
  `admin_UUID` int PRIMARY KEY AUTO_INCREMENT
);

CREATE TABLE `wrestlers` (
  `wrestler_UUID` int PRIMARY KEY,
  `coach_UUID` int NOT NULL,
  `date_of_registration` datetime NOT NULL,
  `wrestling_style` ENUM ('Greco Roman', 'Freestyle', 'Women') NOT NULL,
  `medical_document` varchar(255),
  `license_document` varchar(255)
);

CREATE TABLE `coaches` (
  `coach_UUID` int PRIMARY KEY,
  `wrestling_club_UUID` int NOT NULL,
  `wrestling_style` ENUM ('Greco Roman', 'Freestyle', 'Women') NOT NULL
);

CREATE TABLE `referees` (
  `referee_UUID` int PRIMARY KEY,
  `wrestling_style` ENUM ('Greco Roman', 'Freestyle', 'Women') NOT NULL
);

CREATE TABLE `wrestling_club` (
  `wrestling_club_UUID` int PRIMARY KEY,
  `wrestling_club_city` varchar(50) NOT NULL,
  `wrestling_club_latitude` decimal(9,6) NOT NULL,
  `wrestling_club_longitude` decimal(9,6) NOT NULL
);

CREATE TABLE `competitions` (
  `competition_UUID` int PRIMARY KEY AUTO_INCREMENT,
  `competition_name` varchar(100) NOT NULL,
  `competition_start_date` datetime NOT NULL,
  `competition_end_date` datetime NOT NULL,
  `competition_location` varchar(50) NOT NULL,
  `competition_status` enum('Pending','Confirmed','Postponed') NOT NULL DEFAULT 'Pending'
);


CREATE TABLE `competitions_invitations` (
  `competition_invitation_UUID` int AUTO_INCREMENT,
  `competition_UUID` int NOT NULL,
  `recipient_UUID` int NOT NULL,
  `recipient_role` ENUM ('Wrestling Club', 'Referee', 'Coach', 'Wrestler') NOT NULL,
  `weight_category` varchar(20),
  `invitation_status` varchar(20) NOT NULL,
  `invitation_date` datetime NOT NULL,
  `invitation_deadline` datetime NOT NULL,
  `invitation_response_date` datetime,
  `referee_verification` ENUM ('Confirmed', 'Declined'),
  PRIMARY KEY (`competition_invitation_UUID`, `competition_UUID`, `recipient_UUID`)
);

CREATE TABLE `competitions_fights` (
  `competition_fight_UUID` int UNIQUE NOT NULL AUTO_INCREMENT,
  `competition_UUID` int NOT NULL,
  `competition_round` ENUM ('Round 32', 'Round 16', 'Round 8', 'Round 4', 'Round 2', 'Bronze','Final') NOT NULL,
  `competition_fight_order_number` int NOT NULL,
  `wrestling_style` ENUM ('Greco Roman', 'Freestyle', 'Women') NOT NULL,
  `competition_fight_weight_category` varchar(10) NOT NULL,
  `referee_UUID_1` int NOT NULL,
  `referee_UUID_2` int NOT NULL,
  `referee_UUID_3` int NOT NULL,
  `wrestling_club_UUID_red` int NOT NULL,
  `wrestling_club_UUID_blue` int NOT NULL,
  `coach_UUID_red` int NOT NULL,
  `coach_UUID_blue` int NOT NULL,
  `wrestler_UUID_red` int NOT NULL,
  `wrestler_UUID_blue` int NOT NULL,
  `wrestler_points_red` int DEFAULT null,
  `wrestler_points_blue` int DEFAULT null,
  `wrestler_UUID_winner` int DEFAULT null,
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

ALTER TABLE `competitions_fights` ADD FOREIGN KEY (`competition_UUID`) REFERENCES `competitions` (`competition_UUID`);

ALTER TABLE `competitions_fights` ADD FOREIGN KEY (`referee_UUID_1`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competitions_fights` ADD FOREIGN KEY (`referee_UUID_2`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competitions_fights` ADD FOREIGN KEY (`referee_UUID_3`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competitions_fights` ADD FOREIGN KEY (`wrestling_club_UUID_red`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competitions_fights` ADD FOREIGN KEY (`wrestling_club_UUID_blue`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competitions_fights` ADD FOREIGN KEY (`coach_UUID_red`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competitions_fights` ADD FOREIGN KEY (`coach_UUID_blue`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competitions_fights` ADD FOREIGN KEY (`wrestler_UUID_red`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competitions_fights` ADD FOREIGN KEY (`wrestler_UUID_blue`) REFERENCES `users` (`user_UUID`);

ALTER TABLE `competitions_fights` ADD FOREIGN KEY (`wrestler_UUID_winner`) REFERENCES `users` (`user_UUID`);
