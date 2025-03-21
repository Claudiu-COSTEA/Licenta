use wrestlingMobileAppDatabase;

-----------------------------------------------------------------------------------------------------
----------------------------------------------- USERS -----------------------------------------------
-----------------------------------------------------------------------------------------------------

INSERT INTO users (user_email, user_full_name, user_type) VALUES
('club1@wrestling.com', 'Club Lupte București', 'Wrestling club'),
('club2@wrestling.com', 'Club Lupte Cluj', 'Wrestling club'),
('club3@wrestling.com', 'Club Lupte Iași', 'Wrestling club'),
('club4@wrestling.com', 'Club Lupte Timișoara', 'Wrestling club'),
('club5@wrestling.com', 'Club Lupte Constanța', 'Wrestling club'),
('club6@wrestling.com', 'Club Lupte Brașov', 'Wrestling club'),
('club7@wrestling.com', 'Club Lupte Sibiu', 'Wrestling club'),
('club8@wrestling.com', 'Club Lupte Craiova', 'Wrestling club'),
('club9@wrestling.com', 'Club Lupte Oradea', 'Wrestling club'),
('antrenor1@wrestling.com', 'Antrenor Alexandru', 'Coach'),
('antrenor2@wrestling.com', 'Antrenor Mihai', 'Coach'),
('antrenor3@wrestling.com', 'Antrenor George', 'Coach'),
('antrenor4@wrestling.com', 'Antrenor Radu', 'Coach'),
('antrenor5@wrestling.com', 'Antrenor Florin', 'Coach'),
('antrenor6@wrestling.com', 'Antrenor Cristian', 'Coach'),
('antrenor7@wrestling.com', 'Antrenor Valentin', 'Coach'),
('antrenor8@wrestling.com', 'Antrenor Adrian', 'Coach'),
('antrenor9@wrestling.com', 'Antrenor Daniel', 'Coach'),
('luptator1@wrestling.com', 'Luptător Andrei', 'Wrestler'),
('luptator2@wrestling.com', 'Luptător Bogdan', 'Wrestler'),
('luptator3@wrestling.com', 'Luptător Cătălin', 'Wrestler'),
('luptator4@wrestling.com', 'Luptător Dragoș', 'Wrestler'),
('luptator5@wrestling.com', 'Luptător Eugen', 'Wrestler'),
('luptator6@wrestling.com', 'Luptător Filip', 'Wrestler'),
('luptator7@wrestling.com', 'Luptător Gabriel', 'Wrestler'),
('luptator8@wrestling.com', 'Luptător Horia', 'Wrestler'),
('luptator9@wrestling.com', 'Luptător Ionuț', 'Wrestler'),
('arbitru1@wrestling.com', 'Arbitru Andrei', 'Referee'),
('arbitru2@wrestling.com', 'Arbitru Marian', 'Referee'),
('arbitru3@wrestling.com', 'Arbitru Ion', 'Referee'),
('admin@wrestling.com', 'Administrator Wrestling', 'Wrestling club');  -- Admin (Club de Lupte)


INSERT INTO wrestling_club (wrestling_club_UUID, wrestling_club_location) VALUES
(1, 'București'),
(2, 'Cluj-Napoca'),
(3, 'Iași'),
(4, 'Timișoara'),
(5, 'Constanța'),
(6, 'Brașov'),
(7, 'Sibiu'),
(8, 'Craiova'),
(9, 'Oradea');


INSERT INTO coaches (coach_UUID, wrestling_club_UUID, wrestling_style) VALUES
(10, 1, 'Greco Roman'),
(11, 2, 'Greco Roman'),
(12, 3, 'Greco Roman'),
(13, 4, 'Greco Roman'),
(14, 5, 'Greco Roman'),
(15, 6, 'Greco Roman'),
(16, 7, 'Greco Roman'),
(17, 8, 'Greco Roman'),
(18, 9, 'Greco Roman');

INSERT INTO wrestlers (wrestler_UUID, coach_UUID, wrestling_style) VALUES
(19, 10, 'Greco Roman'),
(20, 11, 'Greco Roman'),
(21, 12, 'Greco Roman'),
(22, 13, 'Greco Roman'),
(23, 14, 'Greco Roman'),
(24, 15, 'Greco Roman'),
(25, 16, 'Greco Roman'),
(26, 17, 'Greco Roman'),
(27, 18, 'Greco Roman');

INSERT INTO referees (referee_UUID, wrestling_style) VALUES
(28, 'Greco Roman'),
(29, 'Greco Roman'),
(30, 'Greco Roman');

-----------------------------------------------------------------------------------------------------
----------------------------------------- COMPETITIONS ----------------------------------------------
-----------------------------------------------------------------------------------------------------

INSERT INTO competitions (competition_name, competition_start_date, competition_end_date, competition_location) VALUES
('Campionatul Național Seniori', '2025-05-10 09:00:00', '2025-05-12 18:00:00', 'București'),
('Cupa României Seniori', '2025-06-15 10:00:00', '2025-06-17 20:00:00', 'Cluj-Napoca');
