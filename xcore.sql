-- ============================================================
--  XCore Framework — Database Schema
--  Compatibile con MySQL 5.7+ / MariaDB 10.3+
--  Autore: Xarma | Framework: XCore v1.0.0
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- Tabella: players (un record per identifier univoco)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `xcore_players` (
  `id`          INT(11)      NOT NULL AUTO_INCREMENT,
  `identifier`  VARCHAR(60)  NOT NULL UNIQUE,
  `license`     VARCHAR(60)  DEFAULT NULL,
  `discord`     VARCHAR(40)  DEFAULT NULL,
  `steam`       VARCHAR(40)  DEFAULT NULL,
  `ip`          VARCHAR(45)  DEFAULT NULL,
  `group`       VARCHAR(30)  NOT NULL DEFAULT 'user',
  `banned`      TINYINT(1)   NOT NULL DEFAULT 0,
  `ban_reason`  TEXT         DEFAULT NULL,
  `ban_until`   DATETIME     DEFAULT NULL,
  `last_seen`   DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Tabella: characters (più personaggi per player)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `xcore_characters` (
  `id`            INT(11)      NOT NULL AUTO_INCREMENT,
  `player_id`     INT(11)      NOT NULL,
  `slot`          TINYINT(1)   NOT NULL DEFAULT 1,
  `firstname`     VARCHAR(50)  NOT NULL DEFAULT 'Sconosciuto',
  `lastname`      VARCHAR(50)  NOT NULL DEFAULT 'Sconosciuto',
  `dob`           DATE         DEFAULT NULL,
  `gender`        TINYINT(1)   NOT NULL DEFAULT 0,
  `nationality`   VARCHAR(50)  DEFAULT 'Italiana',
  `phone`         VARCHAR(20)  DEFAULT NULL,
  `job`           VARCHAR(50)  NOT NULL DEFAULT 'unemployed',
  `job_grade`     TINYINT(3)   NOT NULL DEFAULT 0,
  `job2`          VARCHAR(50)  DEFAULT NULL,
  `job2_grade`    TINYINT(3)   DEFAULT 0,
  `gang`          VARCHAR(50)  DEFAULT NULL,
  `gang_grade`    TINYINT(3)   DEFAULT 0,
  `cash`          INT(11)      NOT NULL DEFAULT 5000,
  `bank`          INT(11)      NOT NULL DEFAULT 10000,
  `black_money`   INT(11)      NOT NULL DEFAULT 0,
  `skin`          LONGTEXT     DEFAULT NULL,
  `position`      VARCHAR(200) NOT NULL DEFAULT '{"x":-269.4,"y":-955.3,"z":31.2,"heading":205.0}',
  `metadata`      LONGTEXT     DEFAULT NULL,
  `inventory`     LONGTEXT     DEFAULT NULL,
  `status`        LONGTEXT     DEFAULT NULL,
  `is_dead`       TINYINT(1)   NOT NULL DEFAULT 0,
  `last_seen`     DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at`    DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_player_id` (`player_id`),
  CONSTRAINT `fk_char_player` FOREIGN KEY (`player_id`) REFERENCES `xcore_players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Tabella: jobs
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `xcore_jobs` (
  `name`        VARCHAR(50)  NOT NULL,
  `label`       VARCHAR(100) NOT NULL,
  `type`        VARCHAR(30)  NOT NULL DEFAULT 'job',
  `is_whitelisted` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `xcore_job_grades` (
  `id`          INT(11)      NOT NULL AUTO_INCREMENT,
  `job_name`    VARCHAR(50)  NOT NULL,
  `grade`       TINYINT(3)   NOT NULL DEFAULT 0,
  `name`        VARCHAR(50)  NOT NULL,
  `label`       VARCHAR(100) NOT NULL,
  `salary`      INT(11)      NOT NULL DEFAULT 0,
  `is_boss`     TINYINT(1)   NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_job_name` (`job_name`),
  CONSTRAINT `fk_grade_job` FOREIGN KEY (`job_name`) REFERENCES `xcore_jobs`(`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Tabella: gangs
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `xcore_gangs` (
  `name`   VARCHAR(50)  NOT NULL,
  `label`  VARCHAR(100) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `xcore_gang_grades` (
  `id`        INT(11)      NOT NULL AUTO_INCREMENT,
  `gang_name` VARCHAR(50)  NOT NULL,
  `grade`     TINYINT(3)   NOT NULL DEFAULT 0,
  `name`      VARCHAR(50)  NOT NULL,
  `label`     VARCHAR(100) NOT NULL,
  `is_boss`   TINYINT(1)   NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_ggrade_gang` FOREIGN KEY (`gang_name`) REFERENCES `xcore_gangs`(`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Tabella: vehicles (garage)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `xcore_vehicles` (
  `id`          INT(11)      NOT NULL AUTO_INCREMENT,
  `char_id`     INT(11)      NOT NULL,
  `plate`       VARCHAR(10)  NOT NULL UNIQUE,
  `model`       VARCHAR(60)  NOT NULL,
  `label`       VARCHAR(100) DEFAULT NULL,
  `garage`      VARCHAR(60)  NOT NULL DEFAULT 'pillbox',
  `state`       TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '0=garage,1=out,2=impound',
  `fuel`        TINYINT(3)   NOT NULL DEFAULT 100,
  `body`        FLOAT        NOT NULL DEFAULT 1000.0,
  `engine`      FLOAT        NOT NULL DEFAULT 1000.0,
  `mods`        LONGTEXT     DEFAULT NULL,
  `keys`        LONGTEXT     DEFAULT NULL COMMENT 'JSON array di char_id con chiave',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_char_id` (`char_id`),
  CONSTRAINT `fk_veh_char` FOREIGN KEY (`char_id`) REFERENCES `xcore_characters`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Tabella: items (catalogo)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `xcore_items` (
  `name`        VARCHAR(60)  NOT NULL,
  `label`       VARCHAR(100) NOT NULL,
  `weight`      FLOAT        NOT NULL DEFAULT 0.0,
  `stack`       TINYINT(1)   NOT NULL DEFAULT 1,
  `usable`      TINYINT(1)   NOT NULL DEFAULT 0,
  `description` TEXT         DEFAULT NULL,
  `image`       VARCHAR(200) DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Tabella: transactions (log economia)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `xcore_transactions` (
  `id`          INT(11)      NOT NULL AUTO_INCREMENT,
  `char_id`     INT(11)      NOT NULL,
  `type`        VARCHAR(30)  NOT NULL,
  `amount`      INT(11)      NOT NULL,
  `account`     VARCHAR(20)  NOT NULL DEFAULT 'bank',
  `note`        VARCHAR(200) DEFAULT NULL,
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_char_id` (`char_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Tabella: bans
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `xcore_bans` (
  `id`          INT(11)      NOT NULL AUTO_INCREMENT,
  `identifier`  VARCHAR(60)  NOT NULL,
  `name`        VARCHAR(100) DEFAULT NULL,
  `reason`      TEXT         NOT NULL,
  `banned_by`   VARCHAR(100) DEFAULT 'Console',
  `expires_at`  DATETIME     DEFAULT NULL,
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Dati di default: lavori
-- ------------------------------------------------------------
INSERT IGNORE INTO `xcore_jobs` (`name`, `label`, `type`) VALUES
  ('unemployed',  'Disoccupato',    'job'),
  ('police',      'Polizia',        'leo'),
  ('ambulance',   'Ambulanza',      'ems'),
  ('mechanic',    'Meccanico',      'job'),
  ('taxi',        'Tassista',       'job'),
  ('realestate',  'Agente Immobiliare', 'job');

INSERT IGNORE INTO `xcore_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `is_boss`) VALUES
  ('unemployed', 0, 'unemployed', 'Disoccupato', 0, 0),
  ('police', 0, 'recruit',    'Recluta',      2500, 0),
  ('police', 1, 'officer',    'Agente',       3500, 0),
  ('police', 2, 'detective',  'Detective',    4500, 0),
  ('police', 3, 'sergeant',   'Sergente',     5500, 0),
  ('police', 4, 'lieutenant', 'Tenente',      7000, 0),
  ('police', 5, 'chief',      'Capo',         9000, 1),
  ('ambulance', 0, 'trainee',  'Tirocinante', 2500, 0),
  ('ambulance', 1, 'emt',      'Paramedico',  3500, 0),
  ('ambulance', 2, 'doctor',   'Dottore',     5000, 0),
  ('ambulance', 3, 'chief',    'Primario',    7000, 1),
  ('mechanic', 0, 'trainee',   'Apprendista', 2000, 0),
  ('mechanic', 1, 'mechanic',  'Meccanico',   3000, 0),
  ('mechanic', 2, 'senior',    'Senior',      4000, 0),
  ('mechanic', 3, 'boss',      'Titolare',    6000, 1),
  ('taxi', 0, 'driver',        'Autista',     2500, 0),
  ('taxi', 1, 'senior',        'Senior',      3500, 0),
  ('taxi', 2, 'boss',          'Titolare',    5000, 1),
  ('realestate', 0, 'agent',   'Agente',      3000, 0),
  ('realestate', 1, 'senior',  'Senior',      4500, 0),
  ('realestate', 2, 'boss',    'Direttore',   7000, 1);

-- Dati di default: gang
INSERT IGNORE INTO `xcore_gangs` (`name`, `label`) VALUES
  ('none',    'Nessuna'),
  ('vagos',   'Vagos'),
  ('ballas',  'Ballas'),
  ('marabunta','Marabunta Grande');

INSERT IGNORE INTO `xcore_gang_grades` (`gang_name`, `grade`, `name`, `label`, `is_boss`) VALUES
  ('none',   0, 'none',    'Nessuna', 0),
  ('vagos',  0, 'recruit', 'Recluta', 0),
  ('vagos',  1, 'soldier', 'Soldato', 0),
  ('vagos',  2, 'boss',    'Boss',    1),
  ('ballas', 0, 'recruit', 'Recluta', 0),
  ('ballas', 1, 'soldier', 'Soldato', 0),
  ('ballas', 2, 'boss',    'Boss',    1);

-- Dati di default: item
INSERT IGNORE INTO `xcore_items` (`name`, `label`, `weight`, `stack`, `usable`, `description`) VALUES
  ('water',        'Acqua',          0.5, 1, 1, 'Disseta la sete'),
  ('bread',        'Pane',           0.3, 1, 1, 'Soddisfa la fame'),
  ('bandage',      'Benda',          0.2, 1, 1, 'Cura ferite lievi'),
  ('medikit',      'Kit Medico',     1.0, 0, 1, 'Cura ferite gravi'),
  ('phone',        'Telefono',       0.3, 0, 1, 'Il tuo smartphone'),
  ('id_card',      'Carta d''Identità', 0.1, 0, 1, 'Documento di identità'),
  ('driver_license','Patente',       0.1, 0, 1, 'Patente di guida'),
  ('lockpick',     'Grimaldello',    0.2, 1, 1, 'Apre serrature'),
  ('weapon_pistol','Pistola',        2.0, 0, 0, 'Pistola semi-automatica'),
  ('ammo_pistol',  'Munizioni Pistola', 0.1, 1, 0, 'Caricatore per pistola'),
  ('money',        'Contanti',       0.0, 1, 0, 'Denaro contante'),
  ('dirty_money',  'Soldi Sporchi',  0.0, 1, 0, 'Denaro non tracciabile'),
  ('weed',         'Erba',           0.1, 1, 0, 'Sostanza illegale'),
  ('cocaine',      'Cocaina',        0.1, 1, 0, 'Sostanza illegale'),
  ('radio',        'Radio',          0.5, 0, 1, 'Radio per comunicazioni');

SET FOREIGN_KEY_CHECKS = 1;
