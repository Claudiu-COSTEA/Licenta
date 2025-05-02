/* ───────────────────────── USERS (40) ───────────────────────── */
INSERT INTO users
        (user_UUID, user_email,                   user_full_name,           user_type,        fcm_token)
VALUES
/* 1-18  Wrestlers */
( 1,'ion.popescu@example.ro'        ,'Ion Popescu'         ,'Wrestler',NULL),
( 2,'andrei.ionescu@example.ro'     ,'Andrei Ionescu'      ,'Wrestler',NULL),
( 3,'mihai.georgescu@example.ro'    ,'Mihai Georgescu'     ,'Wrestler',NULL),
( 4,'alexandru.stan@example.ro'     ,'Alexandru Stan'      ,'Wrestler',NULL),
( 5,'vasile.dumitru@example.ro'     ,'Vasile Dumitru'      ,'Wrestler',NULL),
( 6,'cristina.marinescu@example.ro' ,'Cristina Marinescu'  ,'Wrestler',NULL),
( 7,'sorina.radu@example.ro'        ,'Sorina Radu'         ,'Wrestler',NULL),
( 8,'florina.paun@example.ro'       ,'Florina Păun'        ,'Wrestler',NULL),
( 9,'gabriela.munteanu@example.ro'  ,'Gabriela Munteanu'   ,'Wrestler',NULL),
(10,'vlad.popa@example.ro'          ,'Vlad Popa'           ,'Wrestler',NULL),
(11,'ionel.marin@example.ro'        ,'Ionel Marin'         ,'Wrestler',NULL),
(12,'radu.ilie@example.ro'          ,'Radu Ilie'           ,'Wrestler',NULL),
(13,'alin.dobrescu@example.ro'      ,'Alin Dobrescu'       ,'Wrestler',NULL),
(14,'cosmin.draghici@example.ro'    ,'Cosmin Drăghici'     ,'Wrestler',NULL),
(15,'tudor.opris@example.ro'        ,'Tudor Opriș'         ,'Wrestler',NULL),
(16,'florin.vasilescu@example.ro'   ,'Florin Vasilescu'    ,'Wrestler',NULL),
(17,'mihail.lazar@example.ro'       ,'Mihail Lăzar'        ,'Wrestler',NULL),
(18,'daniel.mitu@example.ro'        ,'Daniel Mitu'         ,'Wrestler',NULL),

/* 19-27  Coaches */
(19,'radu.moldovan@example.ro'      ,'Radu Moldovan'       ,'Coach',NULL),
(20,'constantin.petrescu@example.ro','Constantin Petrescu' ,'Coach',NULL),
(21,'nicolae.stoica@example.ro'     ,'Nicolae Stoica'      ,'Coach',NULL),
(22,'dorin.enache@example.ro'       ,'Dorin Enache'        ,'Coach',NULL),
(23,'iulian.oprea@example.ro'       ,'Iulian Oprea'        ,'Coach',NULL),
(24,'livia.dascalu@example.ro'      ,'Livia Dascălu'       ,'Coach',NULL),
(25,'traian.sandu@example.ro'       ,'Traian Sandu'        ,'Coach',NULL),
(26,'victor.balan@example.ro'       ,'Victor Bălan'        ,'Coach',NULL),
(27,'marius.neagu@example.ro'       ,'Marius Neagu'        ,'Coach',NULL),

/* 28-36  Clubs */
(28,'csm.bucuresti@example.ro'      ,'CSM București'       ,'Wrestling club',NULL),
(29,'csrapid.cluj@example.ro'       ,'CS Rapid Cluj'       ,'Wrestling club',NULL),
(30,'acs.titan.timisoara@example.ro','ACS Titan Timișoara' ,'Wrestling club',NULL),
(31,'cs.steaua.iasi@example.ro'     ,'CS Steaua Iași'      ,'Wrestling club',NULL),
(32,'lps.craiova@example.ro'        ,'LPS Craiova'         ,'Wrestling club',NULL),
(33,'css.brasov@example.ro'         ,'CSS Brașov'          ,'Wrestling club',NULL),
(34,'cs.dinamo.ploiesti@example.ro' ,'CS Dinamo Ploiești'  ,'Wrestling club',NULL),
(35,'csm.constanta@example.ro'      ,'CSM Constanța'       ,'Wrestling club',NULL),
(36,'cs.husi@example.ro'            ,'CS Huși'             ,'Wrestling club',NULL),

/* 37-39  Referees */
(37,'daniel.tudor@example.ro'       ,'Daniel Tudor'        ,'Referee',NULL),
(38,'bogdan.pavel@example.ro'       ,'Bogdan Pavel'        ,'Referee',NULL),
(39,'claudiu.pop@example.ro'        ,'Claudiu Pop'         ,'Referee',NULL),

/* 40  Admin */
(40,'admin@frl.ro'                  ,'Admin FRL'           ,'Admin',NULL);

/* ────────────────── WRESTLING_CLUB (28-36) ─────────────────── */
INSERT INTO wrestling_club (wrestling_club_UUID, wrestling_club_location) VALUES
(28,'București'),
(29,'Cluj-Napoca'),
(30,'Timișoara'),
(31,'Iași'),
(32,'Craiova'),
(33,'Brașov'),
(34,'Ploiești'),
(35,'Constanța'),
(36,'Huși');

/* ─────────── COACHES (19-27) – stil Greco Roman ─────────── */
INSERT INTO coaches (coach_UUID, wrestling_club_UUID, wrestling_style) VALUES
(19,28,'Greco Roman'),
(20,29,'Greco Roman'),
(21,30,'Greco Roman'),
(22,31,'Greco Roman'),
(23,32,'Greco Roman'),
(24,33,'Greco Roman'),
(25,34,'Greco Roman'),
(26,35,'Greco Roman'),
(27,36,'Greco Roman');

/* ─────────── WRESTLERS (1-18) – alocaţi antrenorilor 19-27 ─────────── */
INSERT INTO wrestlers
  (wrestler_UUID, coach_UUID, date_of_registration, wrestling_style,
   medical_document, license_document)
VALUES
( 1,19,'2025-02-01 10:00:00','Greco Roman',NULL,NULL),
( 2,20,'2025-02-02 10:00:00','Greco Roman',NULL,NULL),
( 3,21,'2025-02-03 10:00:00','Greco Roman',NULL,NULL),
( 4,22,'2025-02-04 10:00:00','Greco Roman',NULL,NULL),
( 5,23,'2025-02-05 10:00:00','Greco Roman',NULL,NULL),
( 6,24,'2025-02-06 10:00:00','Greco Roman',NULL,NULL),
( 7,25,'2025-02-07 10:00:00','Greco Roman',NULL,NULL),
( 8,26,'2025-02-08 10:00:00','Greco Roman',NULL,NULL),
( 9,27,'2025-02-09 10:00:00','Greco Roman',NULL,NULL),
(10,19,'2025-02-10 10:00:00','Greco Roman',NULL,NULL),
(11,20,'2025-02-11 10:00:00','Greco Roman',NULL,NULL),
(12,21,'2025-02-12 10:00:00','Greco Roman',NULL,NULL),
(13,22,'2025-02-13 10:00:00','Greco Roman',NULL,NULL),
(14,23,'2025-02-14 10:00:00','Greco Roman',NULL,NULL),
(15,24,'2025-02-15 10:00:00','Greco Roman',NULL,NULL),
(16,25,'2025-02-16 10:00:00','Greco Roman',NULL,NULL),
(17,26,'2025-02-17 10:00:00','Greco Roman',NULL,NULL),
(18,27,'2025-02-18 10:00:00','Greco Roman',NULL,NULL);

/* ─────────── REFEREES (37-39) ─────────── */
INSERT INTO referees (referee_UUID, wrestling_style) VALUES
(37,'Greco Roman'),
(38,'Greco Roman'),
(39,'Greco Roman');

/* ─────────── COMPETITIONS (3) ─────────── */
INSERT INTO competitions
  (competition_UUID, competition_name, competition_start_date,
   competition_end_date, competition_location)
VALUES
(1,'Cupa Primăverii'          ,'2025-05-10 09:00:00','2025-05-12 18:00:00','București'),
(2,'Campionatul Național U21' ,'2025-07-18 09:00:00','2025-07-20 18:00:00','Cluj-Napoca'),
(3,'Trofeul Carpați'          ,'2025-09-05 09:00:00','2025-09-07 18:00:00','Iași');
