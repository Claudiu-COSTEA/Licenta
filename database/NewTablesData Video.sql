USE `wrestlingMobileAppDatabase`;

/* ───────────────────────── USERS (45) ───────────────────────── */
INSERT INTO users (user_UUID, user_email,                   user_full_name,           user_type,        fcm_token) VALUES
/* Wrestlers */
( 1,'claudiu.costea@frl.ro'        ,'Claudiu Costea'         ,'Wrestler','eSvsrp8RTZ-GPsR0UeUX2_:APA91bFUatcdFzmtD7JQQep7Y21-nerfwxfu3OLg6Gf4LKeWRtbhyymNk_4SiL9eV4KR1mxY4MZfcq_VFccypQ-1GBNo6rSgocNufuLbrEi2pyssOQgSnc0'),
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

(18,'paul.popa@frl.ro'        ,'Paul Popa'         ,'Wrestler',NULL),
(19,'tudor.marin@frl.ro'        ,'Tudor Marin'         ,'Wrestler',NULL),
(20,'raul.ilie@frl.ro'        ,'Ralu Ilie'         ,'Wrestler',NULL),
(21,'claudiu.dobrescu@frl.ro'     ,'Claudiu Dobrescu'      ,'Wrestler',NULL),
(22,'codrin.draghici@frl.ro'   ,'Codrin Drăghici'    ,'Wrestler',NULL),
(23,'marin.opris@frl.ro'      ,'Marin Opriș'       ,'Wrestler',NULL),
(24,'florin.vasilescu@frl.ro'  ,'Florin Vasilescu'   ,'Wrestler',NULL),
(25,'ionel.lazar@frl.ro'      ,'Ionel Lăzar'       ,'Wrestler',NULL),

/* Coaches */
(26,'stefan.rusu@frl.ro'         ,'Ștefan Rusu'       ,'Coach','eSvsrp8RTZ-GPsR0UeUX2_:APA91bFUatcdFzmtD7JQQep7Y21-nerfwxfu3OLg6Gf4LKeWRtbhyymNk_4SiL9eV4KR1mxY4MZfcq_VFccypQ-1GBNo6rSgocNufuLbrEi2pyssOQgSnc0'),
(27,'constantin.petrescu@frl.ro' ,'Constantin Petrescu' ,'Coach',NULL),
(28,'nicolae.stoica@frl.ro'      ,'Nicolae Stoica'      ,'Coach',NULL),
(29,'dorin.enache@frl.ro'        ,'Dorin Enache'        ,'Coach',NULL),
(30,'iulian.oprea@frl.ro'        ,'Iulian Oprea'        ,'Coach',NULL),
(31,'livia.dascalu@frl.ro'       ,'Livia Dascălu'       ,'Coach',NULL),
(32,'traian.sandu@frl.ro'        ,'Traian Sandu'        ,'Coach',NULL),
(33,'victor.balan@frl.ro'        ,'Victor Bălan'        ,'Coach',NULL),
(34,'marius.neagu@frl.ro'        ,'Marius Neagu'        ,'Coach',NULL),

(35,'elena.popescu@frl.ro'     ,'Elena Popescu'      ,'Coach',NULL),
(36,'ioana.ionescu@frl.ro'      ,'Ioana Ionescu'      ,'Coach',NULL),
(37,'andreea.stoian@frl.ro'     ,'Andreea Stoian'     ,'Coach',NULL),
(38,'gabriela.dumitrescu@frl.ro','Gabriela Dumitrescu','Coach',NULL),
(39,'alina.matei@frl.ro'        ,'Alina Matei'        ,'Coach',NULL),
(40,'carmen.ionescu@frl.ro'     ,'Carmen Ionescu'     ,'Coach',NULL),
(41,'diana.popa@frl.ro'         ,'Diana Popa'         ,'Coach',NULL),
(42,'roxana.georgiu@frl.ro'     ,'Roxana Georgiu'     ,'Coach',NULL),

(43,'marcel.popescu@frl.ro'     ,'Marcel Popescu'      ,'Coach',NULL),
(44,'valentin.ionescu@frl.ro'      ,'Valentin Ionescu'      ,'Coach',NULL),
(45,'paul.stoian@frl.ro'     ,'Paul Stoian'     ,'Coach',NULL),
(46,'tudor.dumitrescu@frl.ro','Tudoe Dumitrescu','Coach',NULL),
(47,'david.matei@frl.ro'        ,'David Matei'        ,'Coach',NULL),
(48,'aurel.ionescu@frl.ro'     ,'Aurel Ionescu'     ,'Coach',NULL),
(49,'daniel.popa@frl.ro'         ,'Daniel Popa'         ,'Coach',NULL),
(50,'raul.georgiu@frl.ro'     ,'Raul Georgiu'     ,'Coach',NULL),

/* Wrestling clubs */
(51,'css.timisoara@frl.ro'   ,      'CSS Nr. 1 Timișoara'  ,'Wrestling club','eSvsrp8RTZ-GPsR0UeUX2_:APA91bFUatcdFzmtD7JQQep7Y21-nerfwxfu3OLg6Gf4LKeWRtbhyymNk_4SiL9eV4KR1mxY4MZfcq_VFccypQ-1GBNo6rSgocNufuLbrEi2pyssOQgSnc0'),
(52,'csrapid.cluj@frl.ro'          ,'CS Rapid Cluj'        ,'Wrestling club',NULL),
(53,'csm.bucuresti@frl.ro'         ,'CSM București'       ,'Wrestling club',NULL),
(54,'cs.steaua.iasi@frl.ro'        ,'CS Steaua Iași'       ,'Wrestling club',NULL),
(55,'lps.craiova@frl.ro'           ,'LPS Craiova'          ,'Wrestling club',NULL),
(56,'css.brasov@frl.ro'            ,'CSS Brașov'           ,'Wrestling club',NULL),
(57,'cs.dinamo.ploiesti@frl.ro'    ,'CS Dinamo Ploiești'   ,'Wrestling club',NULL),
(58,'csm.constanta@frl.ro'         ,'CSM Constanța'        ,'Wrestling club',NULL),
(59,'cs.sibiu@frl.ro'              ,'CS Sibiu'             ,'Wrestling club',NULL),
(60,'cs.oradea@frl.ro'             ,'CS OrSadea'            ,'Wrestling club',NULL),
(61,'cs.bacau@frl.ro'              ,'CS Bacău'             ,'Wrestling club',NULL),
(62,'cs.galati@frl.ro'             ,'CS Galați'            ,'Wrestling club',NULL),
(63,'cs.pitesti@frl.ro'            ,'CS Pitești'           ,'Wrestling club',NULL),
(64,'cs.arad@frl.ro'               ,'CS Gloria Arad'              ,'Wrestling club',NULL),
(65,'cs.targu.mures@frl.ro'        ,'CS Târgu-Mureș'       ,'Wrestling club',NULL),

/* Referees & Admin */
(66,'daniel.tudor@frl.ro'         ,'Daniel Tudor'        ,'Referee','eSvsrp8RTZ-GPsR0UeUX2_:APA91bFUatcdFzmtD7JQQep7Y21-nerfwxfu3OLg6Gf4LKeWRtbhyymNk_4SiL9eV4KR1mxY4MZfcq_VFccypQ-1GBNo6rSgocNufuLbrEi2pyssOQgSnc0'),
(67,'ionel.toma@frl.ro'         ,'Ionel Toma'        ,'Referee',NULL),
(68,'raul.pota@frl.ro'         ,'Raul Pota'        ,'Referee',NULL),

(69,'bogdan.pavel@frl.ro'         ,'Bogdan Pavel'        ,'Referee',NULL),
(70,'claudiu.pop@frl.ro'          ,'Claudiu Pop'         ,'Referee',NULL),
(71,'andrei.stoia@frl.ro'         ,'Andrei Stoia'        ,'Referee',NULL),

(72,'ana.dumap@frl.ro'         ,'Ana Duma'        ,'Referee',NULL),
(73,'vanesa.popovici@frl.ro'          ,'Vanesa Popovici'         ,'Referee',NULL),
(74,'andreea.marinescu@frl.ro'         ,'Andreea Marinescu'        ,'Referee',NULL),

(75,'admin@frl.ro'                ,'Admin FRL'           ,'Admin',NULL);


/* ────────────────── WRESTLING_CLUB (28-36) ─────────────────── */
-- INSERT-uri cu coordonate
INSERT INTO wrestling_club (wrestling_club_UUID, wrestling_club_city, wrestling_club_latitude, wrestling_club_longitude) VALUES
(51, 'Timișoara',     45.74394669880278, 21.250018164654346),
(52, 'Cluj-Napoca',   46.767327548249085, 23.57025736841228),
(53, 'București',     44.743947, 26.250018),
(54, 'Iași',          47.15444858863968, 27.588338310759926),
(55, 'Craiova',       44.31330746833883, 23.78619936154276),
(56, 'Brașov',        45.66007521695732, 25.617954295339057),
(57, 'Ploiești',      44.932148065677865, 26.011765325991522),
(58, 'Constanța',     44.182382649477205, 28.64873335293767),
(59, 'Sibiu',         45.783394713422524, 24.145779674391047),
(60, 'Oradea',        47.066844779009095, 21.90969236631408),
(61, 'Bacău',         46.55715618184789, 26.91782257032417),
(62, 'Galați',        45.419451618606885, 28.021961265669482),
(63, 'Pitești',       44.84604614569999, 24.868648741331786),
(64, 'Arad',          46.179555258223004, 21.334720651184732),
(65, 'Târgu-Mureș',   46.550212182717225, 24.551788568401175);



/* ─────────── COACHES (19-27) – stil Greco Roman ─────────── */
INSERT INTO coaches (coach_UUID, wrestling_club_UUID, wrestling_style) VALUES
(26,51,'Greco Roman'),
(27,52,'Greco Roman'),
(28,53,'Greco Roman'),
(29,54,'Greco Roman'),
(30,55,'Greco Roman'),
(31,56,'Greco Roman'),
(32,57,'Greco Roman'),
(33,58,'Greco Roman'),
(34,59,'Greco Roman'),

(35,51,'Women'),
(36,52,'Women'),
(37,53,'Women'),
(38,54,'Women'),
(39,55,'Women'),
(40,56,'Women'),
(41,57,'Women'),
(42,58,'Women'),

(43,51,'Freestyle'),
(44,52,'Freestyle'),
(45,53,'Freestyle'),
(46,54,'Freestyle'),
(47,55,'Freestyle'),
(48,56,'Freestyle'),
(49,57,'Freestyle'),
(50,58,'Freestyle');

/* ─────────── WRESTLERS (1-18) – alocaţi antrenorilor 19-27 ─────────── */
INSERT INTO wrestlers
  (wrestler_UUID, coach_UUID, date_of_registration, wrestling_style,
   medical_document, license_document)
VALUES
( 1,26,'2019-11-05 10:00:00','Greco Roman','https://wrestlingdocumentsbucket.s3.us-east-1.amazonaws.com/WrestlersMedicalDocuments/1_Claudiu_Costea_Medical.pdf',NULL),
( 2,27,'2011-09-12 10:00:00','Greco Roman',NULL,NULL),
( 3,28,'2018-02-03 10:00:00','Greco Roman',NULL,NULL),
( 4,29,'2012-06-24 10:00:00','Greco Roman',NULL,NULL),
( 5,30,'2019-07-27 10:00:00','Greco Roman',NULL,NULL),
( 6,31,'2016-02-06 10:00:00','Greco Roman',NULL,NULL),
( 7,32,'2008-01-15 10:00:00','Greco Roman',NULL,NULL),
( 8,33,'2013-05-08 10:00:00','Greco Roman',NULL,NULL),
( 9,34,'2016-04-11 10:00:00','Greco Roman',NULL,NULL),
(10,35,'2020-03-10 10:00:00','Women',NULL,NULL),
(11,36,'2018-05-22 10:00:00','Women',NULL,NULL),
(12,37,'2011-10-12 10:00:00','Women',NULL,NULL),
(13,38,'2012-12-13 10:00:00','Women',NULL,NULL),
(14,39,'2015-11-04 10:00:00','Women',NULL,NULL),
(15,40,'2020-07-15 10:00:00','Women',NULL,NULL),
(16,41,'2014-06-01 10:00:00','Women',NULL,NULL),
(17,42,'2021-01-05 10:00:00','Women',NULL,NULL),
(18,43,'2020-03-10 10:00:00','Freestyle',NULL,NULL),
(19,44,'2018-05-22 10:00:00','Freestyle',NULL,NULL),
(20,45,'2011-10-12 10:00:00','Freestyle',NULL,NULL),
(21,46,'2012-12-13 10:00:00','Freestyle',NULL,NULL),
(22,47,'2015-11-04 10:00:00','Freestyle',NULL,NULL),
(23,48,'2020-07-15 10:00:00','Freestyle',NULL,NULL),
(24,49,'2014-06-01 10:00:00','Freestyle',NULL,NULL),
(25,50,'2021-01-05 10:00:00','Freestyle',NULL,NULL);

/* ─────────── REFEREES (37-39) ─────────── */
INSERT INTO referees (referee_UUID, wrestling_style) VALUES
(66,'Greco Roman'),
(67,'Greco Roman'),
(68,'Greco Roman'),
(69,'Women'),
(70,'Women'),
(71,'Women'),
(72,'Freestyle'),
(73,'Freestyle'),
(74,'Freestyle');

/* ─────────── COMPETITIONS (3) ─────────── */
INSERT INTO competitions
  (competition_UUID, competition_name, competition_start_date,
   competition_end_date, competition_location, competition_status)
VALUES
  (1, 'Cupa României Seniori 2025', '2025-07-21 09:00:00', '2025-07-21 18:00:00', '45.7465227, 21.2415431'  , 'Pending'),
  (2, 'Campionatul Național Seniori 2025', '2025-09-20 09:00:00', '2025-09-20 18:00:00', '45.74394669880278, 21.250018164654346', 'Confirmed'),
  (3, 'Cupa României Juniori 2025', '2025-11-08 09:00:00', '2025-11-08 18:00:00', '46.550212182717225, 24.551788568401175', 'Confirmed');

