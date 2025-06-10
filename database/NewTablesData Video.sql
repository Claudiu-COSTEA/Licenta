USE `wrestlingMobileAppDatabase`;

/* ───────────────────────── USERS (45) ───────────────────────── */
INSERT INTO users (user_UUID, user_email,                   user_full_name,           user_type,        fcm_token) VALUES
/* 1-17  Wrestlers */
( 1,'claudiu.Costea@frl.ro'        ,'Claudiu Costea'         ,'Wrestler',NULL),
( 2,'andrei.ionescu@frl.ro'     ,'Andrei Ionescu'      ,'Wrestler',NULL),
( 3,'mihai.georgescu@frl.ro'    ,'Mihai Georgescu'     ,'Wrestler',NULL),
( 4,'alexandru.stan@frl.ro'     ,'Alexandru Stan'      ,'Wrestler',NULL),
( 5,'vasile.dumitru@frl.ro'     ,'Vasile Dumitru'      ,'Wrestler',NULL),
( 6,'cristin.marinescu@frl.ro' ,'Cristina Marinescu'  ,'Wrestler',NULL),
( 7,'sorin.radu@frl.ro'        ,'Sorina Radu'         ,'Wrestler',NULL),
( 8,'florin.paun@frl.ro'       ,'Florina Păun'        ,'Wrestler',NULL),
( 9,'gabriel.munteanu@frl.ro'  ,'Gabriela Munteanu'   ,'Wrestler',NULL),
(10,'vladia.popa@frl.ro'        ,'Vladia Popa'         ,'Wrestler',NULL),
(11,'ioana.marin@frl.ro'        ,'Ioana Marin'         ,'Wrestler',NULL),
(12,'raluca.ilie@frl.ro'        ,'Raluca Ilie'         ,'Wrestler',NULL),
(13,'alina.dobrescu@frl.ro'     ,'Alina Dobrescu'      ,'Wrestler',NULL),
(14,'cosmina.draghici@frl.ro'   ,'Cosmina Drăghici'    ,'Wrestler',NULL),
(15,'teodora.opris@frl.ro'      ,'Teodora Opriș'       ,'Wrestler',NULL),
(16,'florina.vasilescu@frl.ro'  ,'Florina Vasilescu'   ,'Wrestler',NULL),
(17,'mihaela.lazar@frl.ro'      ,'Mihaela Lăzar'       ,'Wrestler',NULL),

/* 18-26  Coaches */
(18,'stefan.rusu@frl.ro'         ,'Ștefan Rusu'       ,'Coach',NULL),
(19,'constantin.petrescu@frl.ro' ,'Constantin Petrescu' ,'Coach',NULL),
(20,'nicolae.stoica@frl.ro'      ,'Nicolae Stoica'      ,'Coach',NULL),
(21,'dorin.enache@frl.ro'        ,'Dorin Enache'        ,'Coach',NULL),
(22,'iulian.oprea@frl.ro'        ,'Iulian Oprea'        ,'Coach',NULL),
(23,'livia.dascalu@frl.ro'       ,'Livia Dascălu'       ,'Coach',NULL),
(24,'traian.sandu@frl.ro'        ,'Traian Sandu'        ,'Coach',NULL),
(25,'victor.balan@frl.ro'        ,'Victor Bălan'        ,'Coach',NULL),
(26,'marius.neagu@frl.ro'        ,'Marius Neagu'        ,'Coach',NULL),

/* 27-42  Wrestling clubs */
(27,'css.timisoara@frl.ro'   ,      'CSS Nr. 1 Timișoara'  ,'Wrestling club',NULL),
(28,'csrapid.cluj@frl.ro'          ,'CS Rapid Cluj'        ,'Wrestling club',NULL),
(29,'csm.bucuresti@frl.ro'         ,'CSM București'       ,'Wrestling club',NULL),
(30,'cs.steaua.iasi@frl.ro'        ,'CS Steaua Iași'       ,'Wrestling club',NULL),
(31,'lps.craiova@frl.ro'           ,'LPS Craiova'          ,'Wrestling club',NULL),
(32,'css.brasov@frl.ro'            ,'CSS Brașov'           ,'Wrestling club',NULL),
(33,'cs.dinamo.ploiesti@frl.ro'    ,'CS Dinamo Ploiești'   ,'Wrestling club',NULL),
(34,'csm.constanta@frl.ro'         ,'CSM Constanța'        ,'Wrestling club',NULL),
(35,'cs.sibiu@frl.ro'              ,'CS Sibiu'             ,'Wrestling club',NULL),
(36,'cs.oradea@frl.ro'             ,'CS Oradea'            ,'Wrestling club',NULL),
(37,'cs.bacau@frl.ro'              ,'CS Bacău'             ,'Wrestling club',NULL),
(38,'cs.galati@frl.ro'             ,'CS Galați'            ,'Wrestling club',NULL),
(39,'cs.pitesti@frl.ro'            ,'CS Pitești'           ,'Wrestling club',NULL),
(40,'cs.arad@frl.ro'               ,'CS Gloria Arad'              ,'Wrestling club',NULL),
(41,'cs.targu.mures@frl.ro'        ,'CS Târgu-Mureș'       ,'Wrestling club',NULL),

/* 43-45  Referees & 46 Admin */
(42,'daniel.tudor@frl.ro'         ,'Daniel Tudor'        ,'Referee',NULL),
(43,'bogdan.pavel@frl.ro'         ,'Bogdan Pavel'        ,'Referee',NULL),
(44,'claudiu.pop@frl.ro'          ,'Claudiu Pop'         ,'Referee',NULL),

(45,'admin@frl.ro'                ,'Admin FRL'           ,'Admin',NULL);


/* ────────────────── WRESTLING_CLUB (28-36) ─────────────────── */
-- INSERT-uri cu coordonate
INSERT INTO wrestling_club (wrestling_club_UUID, wrestling_club_city, wrestling_club_latitude, wrestling_club_longitude) VALUES
(27, 'București',     44.40576270746426, 26.110756227152596),
(28, 'Cluj-Napoca',   46.767327548249085, 23.57025736841228),
(29, 'Timișoara',     45.74394669880278, 21.250018164654346),
(30, 'Iași',          47.15444858863968, 27.588338310759926),
(31, 'Craiova',       44.31330746833883, 23.78619936154276),
(32, 'Brașov',        45.66007521695732, 25.617954295339057),
(33, 'Ploiești',      44.932148065677865, 26.011765325991522),
(34, 'Constanța',     44.182382649477205, 28.64873335293767),
(35, 'Sibiu',         45.783394713422524, 24.145779674391047),
(36, 'Oradea',        47.066844779009095, 21.90969236631408),
(37, 'Bacău',         46.55715618184789, 26.91782257032417),
(38, 'Galați',        45.419451618606885, 28.021961265669482),
(39, 'Pitești',       44.84604614569999, 24.868648741331786),
(40, 'Arad',          46.179555258223004, 21.334720651184732),
(41, 'Târgu-Mureș',   46.550212182717225, 24.551788568401175);



/* ─────────── COACHES (19-27) – stil Greco Roman ─────────── */
INSERT INTO coaches (coach_UUID, wrestling_club_UUID, wrestling_style) VALUES
(18,27,'Greco Roman'),
(19,28,'Greco Roman'),
(20,29,'Greco Roman'),
(21,30,'Greco Roman'),
(22,31,'Greco Roman'),
(23,32,'Greco Roman'),
(24,33,'Greco Roman'),
(25,34,'Greco Roman'),
(26,35,'Greco Roman');

/* ─────────── WRESTLERS (1-18) – alocaţi antrenorilor 19-27 ─────────── */
INSERT INTO wrestlers
  (wrestler_UUID, coach_UUID, date_of_registration, wrestling_style,
   medical_document, license_document)
VALUES
( 1,18,'2019-11-05 10:00:00','Greco Roman',NULL,NULL),
( 2,19,'2011-09-12 10:00:00','Greco Roman',NULL,NULL),
( 3,20,'2018-02-03 10:00:00','Greco Roman',NULL,NULL),
( 4,21,'2012-06-24 10:00:00','Greco Roman',NULL,NULL),
( 5,22,'2019-07-27 10:00:00','Greco Roman',NULL,NULL),
( 6,23,'2016-02-06 10:00:00','Greco Roman',NULL,NULL),
( 7,24,'2008-01-15 10:00:00','Greco Roman',NULL,NULL),
( 8,25,'2013-05-08 10:00:00','Greco Roman',NULL,NULL),
( 9,26,'2016-04-11 10:00:00','Greco Roman',NULL,NULL),
(10,18,'2020-03-10 10:00:00','Women',NULL,NULL),
(11,19,'2018-05-22 10:00:00','Women',NULL,NULL),
(12,20,'2011-10-12 10:00:00','Women',NULL,NULL),
(13,21,'2012-12-13 10:00:00','Women',NULL,NULL),
(14,22,'2015-11-04 10:00:00','Women',NULL,NULL),
(15,23,'2020-07-15 10:00:00','Women',NULL,NULL),
(16,24,'2014-06-01 10:00:00','Women',NULL,NULL),
(17,25,'2021-01-05 10:00:00','Women',NULL,NULL);

/* ─────────── REFEREES (37-39) ─────────── */
INSERT INTO referees (referee_UUID, wrestling_style) VALUES
(42,'Greco Roman'),
(43,'Women'),
(44,'Women');

/* ─────────── COMPETITIONS (3) ─────────── */
INSERT INTO competitions
  (competition_UUID, competition_name, competition_start_date,
   competition_end_date, competition_location, competition_status)
VALUES
  (1, 'Cupa României Seniori 2025', '2025-07-21 09:00:00', '2025-07-21 18:00:00', '45.7465227, 21.2415431'  , 'Pending'),
  (2, 'Campionatul Național Seniori 2025', '2025-09-20 09:00:00', '2025-09-20 18:00:00', '45.74394669880278, 21.250018164654346', 'Confirmed'),
  (3, 'Cupa României Juniori 2025', '2025-11-08 09:00:00', '2025-11-08 18:00:00', '46.550212182717225, 24.551788568401175', 'Confirmed');

