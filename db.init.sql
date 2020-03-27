
-- DROP SEQUENCE commodities_id_seq;

CREATE SEQUENCE commodities_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 18;

-- DROP SEQUENCE coveraccounts_id_seq;

CREATE SEQUENCE coveraccounts_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 1;

-- DROP SEQUENCE coverpositions_id_seq;

CREATE SEQUENCE coverpositions_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 1;

-- DROP SEQUENCE ledgers_id_seq;

CREATE SEQUENCE ledgers_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 128;

-- DROP SEQUENCE notifications_id_seq;

CREATE SEQUENCE notifications_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 193;

-- DROP SEQUENCE offices_id_seq;

CREATE SEQUENCE offices_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 1;

-- DROP SEQUENCE positions_id_seq;

CREATE SEQUENCE positions_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 984;

-- DROP SEQUENCE quotes_id_seq;

CREATE SEQUENCE quotes_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 3079988;

-- DROP SEQUENCE schedules_id_seq;

CREATE SEQUENCE schedules_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 7;

-- DROP SEQUENCE users_id_seq;

CREATE SEQUENCE users_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 21;

CREATE TABLE users (
	id int4 NOT NULL DEFAULT nextval('users_id_seq'::regclass),
	username varchar NOT NULL,
	pass varchar NOT NULL,
	locked bool NOT NULL DEFAULT false,
	usertype varchar NOT NULL DEFAULT 'client'::character varying,
	phonenumber varchar NOT NULL,
	fullname varchar NOT NULL,
	email varchar NOT NULL,
	useruuid uuid NULL,
	authtags varchar NOT NULL,
	liquidate bool NOT NULL DEFAULT false,
	created timestamp NULL,
	ended timestamp NULL,
	CONSTRAINT pk_users_id PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX idx_users_username ON users (username DESC) ;
CREATE INDEX users_ended_idx ON users (ended DESC) ;

CREATE TABLE offices (
	id int4 NOT NULL DEFAULT nextval('offices_id_seq'::regclass),
	officename varchar NULL,
	officeuuid uuid NULL,
	CONSTRAINT pk_offices_id PRIMARY KEY (id),
	CONSTRAINT uc_offices_officename UNIQUE (officename)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE offices_users (
	office_id int4 NOT NULL,
	user_id int4 NOT NULL,
	CONSTRAINT pk_offices_users PRIMARY KEY (office_id,user_id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE commodities (
	id int4 NOT NULL DEFAULT nextval('commodities_id_seq'::regclass),
	commodityname varchar NULL,
	commoditytype varchar NULL,
	created date NULL,
	modified date NULL,
	lotsize numeric NULL,
	CONSTRAINT nn_commodities_commoditytype CHECK ((commoditytype IS NOT NULL)),
	CONSTRAINT pk_commodities_id PRIMARY KEY (id),
	CONSTRAINT uk_commodities_commodityname UNIQUE (commodityname)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX idx_commodities_commodityname ON commodities (commodityname DESC) ;
CREATE INDEX idx_commodities_commoditytype ON commodities (commoditytype DESC) ;

CREATE TABLE commodities_users (
	commodity_id int4 NULL,
	user_id int4 NULL,
	spread numeric NULL,
	ratio numeric NULL,
	fee numeric NOT NULL DEFAULT 15,
	commission numeric NOT NULL DEFAULT 0.02,
	minamount numeric NULL DEFAULT 0.01,
	maxamount numeric NOT NULL DEFAULT 2.0,
	CONSTRAINT commodities_users_commodities_fk FOREIGN KEY (commodity_id) REFERENCES commodities(id),
	CONSTRAINT commodities_users_users_fk FOREIGN KEY (user_id) REFERENCES users(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX commodities_users_commodity_id_idx ON commodities_users (commodity_id DESC,user_id DESC) ;


CREATE TABLE coveraccounts (
	id int4 NOT NULL DEFAULT nextval('coveraccounts_id_seq'::regclass),
	title varchar NULL,
	active bool NULL,
	created timestamp NULL,
	office_id int4 NULL,
	CONSTRAINT coveraccounts_pk PRIMARY KEY (id),
	CONSTRAINT coveraccounts_offices_fk FOREIGN KEY (office_id) REFERENCES offices(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX coveraccounts_active_idx ON coveraccounts (active DESC) ;
CREATE INDEX coveraccounts_title_idx ON coveraccounts (title DESC) ;

CREATE TABLE coverpositions (
	id int4 NOT NULL DEFAULT nextval('coverpositions_id_seq'::regclass),
	coveraccount_id int4 NULL,
	commodity varchar NULL,
	ordertype varchar NULL,
	amount numeric NULL,
	openprice numeric NULL,
	closeprice numeric NULL,
	opentime timestamp NULL,
	closetime timestamp NULL,
	openedby varchar NULL,
	closedby varchar NULL,
	currentpl numeric NULL,
	created timestamp NULL,
	endedat timestamp NULL,
	internalid uuid NULL,
	remoteid varchar NULL,
	CONSTRAINT coverposition_pk PRIMARY KEY (id),
	CONSTRAINT coverposition_coveraccounts_fk FOREIGN KEY (coveraccount_id) REFERENCES coveraccounts(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX coverposition_coveraccount_id_idx ON coverpositions (coveraccount_id DESC,commodity DESC,ordertype DESC) ;
CREATE INDEX coverpositions_coveraccount_only_id_idx ON coverpositions (coveraccount_id DESC) ;
CREATE INDEX coverpositions_internalid_idx ON coverpositions (internalid DESC) ;
CREATE INDEX coverpositions_remoteid_idx ON coverpositions (remoteid DESC) ;




CREATE TABLE ledgers (
	id int4 NOT NULL DEFAULT nextval('ledgers_id_seq'::regclass),
	user_id int4 NOT NULL,
	deposit numeric NOT NULL DEFAULT 0,
	withdrawal numeric NOT NULL DEFAULT 0,
	credit numeric NOT NULL DEFAULT 0,
	debit numeric NOT NULL DEFAULT 0,
	created timestamp NULL,
	description text NULL,
	CONSTRAINT ledgers_pk PRIMARY KEY (id),
	CONSTRAINT ledgers_users_fk FOREIGN KEY (user_id) REFERENCES users(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX ledgers_user_id_idx ON ledgers (user_id DESC) ;

CREATE TABLE notifications (
	id int4 NOT NULL DEFAULT nextval('notifications_id_seq'::regclass),
	user_id int4 NULL,
	notification text NULL,
	created timestamp NULL,
	office_id int4 NULL,
	CONSTRAINT notifications_pk PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX notifications_office_id_idx ON notifications (office_id DESC,created DESC) ;
CREATE INDEX notifications_user_id_idx ON notifications (user_id DESC,created DESC) ;



CREATE TABLE positions (
	id int4 NOT NULL DEFAULT nextval('positions_id_seq'::regclass),
	ordertype varchar NULL,
	commodity varchar NULL,
	amount numeric NULL,
	currentpl numeric NULL,
	orderid uuid NULL,
	openprice numeric NULL,
	closeprice numeric NULL,
	orderstate varchar NULL,
	createdat timestamp NULL,
	endedat timestamp NULL,
	closedat timestamp NULL,
	approvedopenat timestamp NULL,
	approvedcloseat timestamp NULL,
	friendlyorderid int8 NOT NULL DEFAULT 0,
	requoteprice numeric NULL,
	user_id int4 NOT NULL,
	CONSTRAINT pk_positions_id PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX idx_positions_endedat ON positions (endedat) ;
CREATE INDEX idx_positions_orderid ON positions (orderid) ;
CREATE INDEX positions_user_id_idx ON positions (user_id DESC) ;

CREATE TABLE quotes (
	id int4 NOT NULL DEFAULT nextval('quotes_id_seq'::regclass),
	user_id int4 NOT NULL,
	commodityname varchar NULL,
	bid numeric NULL,
	ask numeric NULL,
	created timestamp NULL,
	CONSTRAINT pk_quotes_id PRIMARY KEY (id),
	CONSTRAINT quotes_users_fk FOREIGN KEY (user_id) REFERENCES users(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX quotes_name_user_id_created_idx ON quotes (user_id DESC,commodityname DESC,created DESC) ;

CREATE TABLE savedpositions (
	user_id int4 NOT NULL,
	positiondata json NULL,
	created timestamp NULL,
	CONSTRAINT savedpositions_pk PRIMARY KEY (user_id),
	CONSTRAINT savedpositions_users_fk FOREIGN KEY (user_id) REFERENCES users(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX savedpositions_user_id_idx ON savedpositions (user_id) ;

CREATE TABLE schedules (
	id int4 NOT NULL DEFAULT nextval('schedules_id_seq'::regclass),
	dayofweek int4 NOT NULL,
	schedule text NOT NULL,
	ended timestamp NULL,
	created timestamp NULL,
	CONSTRAINT schedules_pk PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX schedules_ended_idx ON schedules (ended DESC) ;

CREATE TABLE serials (
	sname varchar NULL,
	svalue int8 NOT NULL DEFAULT 0
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX serials_sname_idx ON serials (sname DESC) ;



INSERT INTO users
(id, username, pass, locked, usertype, phonenumber, fullname, email, useruuid, authtags, liquidate, created, ended)
VALUES(11, 'guest', 'guest', false, 'service', '+00', 'guest', 'guest@guest.io', 'f9fa0398-00bd-47a7-b524-000b88ff9706', 'administrator', false, NULL, NULL);
INSERT INTO users
(id, username, pass, locked, usertype, phonenumber, fullname, email, useruuid, authtags, liquidate, created, ended)
VALUES(13, 'client', 'client', false, 'service', '+00', 'client', 'client@client.io', 'b78ba8c9-3255-4a94-aa09-d24ab2856e29', ' ', false, NULL, NULL);
INSERT INTO users
(id, username, pass, locked, usertype, phonenumber, fullname, email, useruuid, authtags, liquidate, created, ended)
VALUES(4, 'faisal', 'faisal', false, 'admin', '+111111', 'Faisal', 'faisal@yahoo.com', '6d752760-6dad-41d5-b228-2c3b7d349980', 'administrator', false, NULL, NULL);
INSERT INTO users
(id, username, pass, locked, usertype, phonenumber, fullname, email, useruuid, authtags, liquidate, created, ended)
VALUES(7, 'svc', 'svc', false, 'service', '+00', 'services', 'service@local.io', 'b5892045-f214-4c99-ba87-d89b84f457bd', 'administrator', false, NULL, NULL);
INSERT INTO users
(id, username, pass, locked, usertype, phonenumber, fullname, email, useruuid, authtags, liquidate, created, ended)
VALUES(9, 'trader', 'trader', false, 'trader', '+12345', 'trader test', 'trader@test.org', '1f177ca4-92e5-44d8-9df0-fb91e58096cf', ' ', true, NULL, NULL);
INSERT INTO users
(id, username, pass, locked, usertype, phonenumber, fullname, email, useruuid, authtags, liquidate, created, ended)
VALUES(10, 'dealer', 'dealer', false, 'dealer', '+12345', 'Dealer', 'dealer@test.org', '88d272cf-67d7-4d70-b216-93afde91369e', ' ', false, NULL, NULL);

INSERT INTO offices
(id, officename, officeuuid)
VALUES(1, 'MM', '07e09482-7d84-4ee3-9cf7-7c65b7dad259');

INSERT INTO offices_users
(office_id, user_id)
VALUES(1, 9);
INSERT INTO offices_users
(office_id, user_id)
VALUES(1, 10);



INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(1, 'FT:141', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(2, 'FT:140', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(3, 'FT:142', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(4, 'FT:139', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(5, 'audcad', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(6, 'audchf', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(7, 'audnzd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(8, 'audjpy', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(9, 'usdsgd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(10, 'eurusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(11, 'gbpusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(12, 'usdjpy', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(13, 'usdchf', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(14, 'usdcad', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(15, 'audusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(16, 'nzdusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(17, 'eurgbp', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(18, 'eurchf', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(19, 'eurjpy', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(20, 'euraud', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(21, 'eurcad', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(22, 'gbpaud', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(23, 'gbpcad', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(24, 'gbpchf', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(25, 'gbpjpy', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(26, 'nzdcad', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(27, 'nzdchf', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(28, 'nzdjpy', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(29, 'usddkk', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(30, 'usdmxn', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(31, 'usdnok', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(32, 'usdrub', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(33, 'usdsek', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(34, 'usdtry', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(35, 'silver', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(36, 'gold', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(37, '_mmm', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(38, '_alibaba', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(39, '_aa', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(40, '_amzn', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(41, '_axp', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(42, '_aapl', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(43, '_t', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(44, '_bac', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(45, '_ba', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(46, '_cat', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(47, '_cvx', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(48, '_ko', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(49, '_csco', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(50, '_dis', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(51, '_ebay', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(52, '_xom', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(53, '_fb', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(54, '_ge', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(55, '_goog', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(56, '_ibm', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(57, '_hpq', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(58, '_intc', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(59, '_jnj', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(60, '_jpm', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(61, '_mcd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(62, '_msft', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(63, '_netflix', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(64, '_pfe', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(65, '_pg', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(66, '_sony', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(67, '_yhoo', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(68, '_tesla', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(69, '_vz', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(70, '_wmt', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(71, '_bmw', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(72, 'ng', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(73, 'ta35', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(74, 'tadawul', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(75, 'btceur', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(76, 'btcusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(77, '_gazp', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(78, '_yndx', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(79, 'uso', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(80, 'uco', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(81, 'adobe', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(82, '_nike', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(83, 'ltcusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(84, 'dshusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(85, 'ethusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(86, 'xrpusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(87, 'btcusd2', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(88, 'bchusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(89, 'etcusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(90, '_lm', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(91, '_nvidia', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(92, 'bcheur', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(93, 'etheur', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(94, 'ton2', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(95, 'dsheur', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(96, '_pm', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(97, 'btgusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(98, '_lkoh', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(99, '_rosn', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(100, 'xmrusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(101, 'xvgusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(102, 'xemusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(103, 'qtmusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(104, 'gntusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(105, 'trxusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(106, 'bist100', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(107, '_baidu', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(108, 'eursgd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(109, 'eurex', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(110, '_uber', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(111, 'pepsico', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(112, 'zs', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(113, 'ct', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(114, 'zc', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(115, 'nikkei', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(116, 'nasdaq', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(117, 'dow', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(118, 'sp500', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(119, 'dax', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(120, 'ftse', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(121, 'mib', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(122, 'asx', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(123, 'volsp500', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(124, 'jse', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(125, 'iceusd', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(126, 'kc', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(127, 'sb', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(128, 'cac40', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(129, 'ibex', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(130, 'hshares', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(131, 'hang_sen', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(132, 'brent', 'FX', NULL, NULL, 100000);
INSERT INTO commodities (id, commodityname, commoditytype, created, modified, lotsize)
VALUES(133, 'wti', 'FX', NULL, NULL, 100000);


INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(7, 9, 0.0005, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(7, 10, 0, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(8, 9, 0.0010, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(9, 9, 0.0010, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(10, 9, 0.001, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(8, 10, 0, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(9, 10, 0, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(10, 10, 0, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(11, 9, 0.001, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(12, 9, 0.001, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(14, 9, 0.001, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(17, 9, 0.001, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(18, 9, 0.001, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(16, 9, 0.001, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(11, 10, 0, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(12, 10, 0, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(14, 10, 0, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(17, 10, 0, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(18, 10, 0, 0.01, 15, 0.02, 0.01, 2.0);
INSERT INTO commodities_users
(commodity_id, user_id, spread, ratio, fee, commission, minamount, maxamount)
VALUES(16, 10, 0, 0.01, 15, 0.02, 0.01, 2.0);



INSERT INTO schedules
(id, dayofweek, schedule, ended, created)
VALUES(2, 2, '[[0,86400000]]', NULL, NULL);
INSERT INTO schedules
(id, dayofweek, schedule, ended, created)
VALUES(3, 3, '[[0,86400000]]', NULL, NULL);
INSERT INTO schedules
(id, dayofweek, schedule, ended, created)
VALUES(4, 4, '[[0,86400000]]', NULL, NULL);
INSERT INTO schedules
(id, dayofweek, schedule, ended, created)
VALUES(5, 5, '[[0,86400000]]', NULL, NULL);
INSERT INTO schedules
(id, dayofweek, schedule, ended, created)
VALUES(6, 6, '[[0,86400000]]', NULL, NULL);
INSERT INTO schedules
(id, dayofweek, schedule, ended, created)
VALUES(7, 7, '[[0,86400000]]', NULL, NULL);
INSERT INTO schedules
(id, dayofweek, schedule, ended, created)
VALUES(1, 1, '[[0,86400000]]', NULL, NULL);
