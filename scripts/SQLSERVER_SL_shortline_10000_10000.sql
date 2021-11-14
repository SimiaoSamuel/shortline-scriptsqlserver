IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name='shortline')
    CREATE DATABASE shortline;
GO
USE shortline
GO
	DECLARE @name VARCHAR(128)
	DECLARE @constraint VARCHAR(254)
	DECLARE @SQL VARCHAR(254)
	SELECT @name = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' ORDER BY TABLE_NAME)
	WHILE @name is not null
		BEGIN
			SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' AND TABLE_NAME = @name ORDER BY CONSTRAINT_NAME)
			WHILE @constraint IS NOT NULL
			BEGIN
				SELECT @SQL = 'ALTER TABLE [dbo].[' + RTRIM(@name) +'] DROP CONSTRAINT [' + RTRIM(@constraint) +']'
				EXEC (@SQL)
				SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' AND CONSTRAINT_NAME <> @constraint AND TABLE_NAME = @name ORDER BY CONSTRAINT_NAME)
		END
		SELECT @name = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' ORDER BY TABLE_NAME)
END
DROP TABLE IF EXISTS TBUSER;
DROP TABLE IF EXISTS TBQUEUE;
DROP TABLE IF EXISTS TBRESERVES;
DROP TABLE IF EXISTS TBCOMPANY;
DROP TABLE IF EXISTS LGRESERVES;
DROP TABLE IF EXISTS LGQUEUE;
DROP TABLE IF EXISTS TBREQUEST;
DROP TABLE IF EXISTS TBIPS;

create table TBUSER(
	ID int Identity Not Null unique,
	LOGIN varchar(10) NOT NULL UNIQUE,
	FIRST_NAME varchar(50) NOT NULL,
	LAST_NAME varchar(50) NOT NULL, 
	PASSWORD char(100) NOT NULL,
	COMPANY bit NOT NULL,
	primary key (ID)
);
create table TBQUEUE(
	ID INT IDENTITY NOT NULL UNIQUE,
	IDCOMPANY INT NOT NULL,
	DESCRIPTION_QUEUE VARCHAR(20) NULL,
	BEGIN_DATE DATETIME NULL,
	END_DATE DATETIME NULL,
	MAX_SIZE INT NULL,
	LAST_CODE INT default 0,
	WAIT_INT_LINE INT NULL,
	VACANCIES INT NULL,
	AVG_WAITING INT NULL,
	PRIMARY KEY (ID)
);
create table TBRESERVES(
	ID INT IDENTITY NOT NULL UNIQUE,
	IDUSER INT NOT NULL,
	IDQUEUE INT NOT NULL,
	REGISTER_IN DATETIME NULL,
	CHECK_IN DATETIME NULL,
	CHECK_OUT DATETIME NULL,
	CODE INT NULL,
	STATUS char(1) NULL,
	PRIMARY KEY (ID)
);
create table TBCOMPANY(
	ID INT IDENTITY NOT NULL UNIQUE,
	IDUSER INT NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	POSTAL_CODE VARCHAR(20) NOT NULL,
	ADDRESS_NUMBER INT NULL,
	LATITUDE decimal(8,5) NULL,
	LONGITUDE DECIMAL(8,5) NULL,
	PRIMARY KEY (ID)
);
create table LGRESERVES(
	ID INT IDENTITY NOT NULL UNIQUE,
	IDQUEUE INT NOT NULL,
	IDUSER INT NOT NULL,
	IDRESERVE INT NOT NULL,
	REGISTER_IN DATETIME NULL,
	CHECK_IN DATETIME NULL,
	CHECK_OUT DATETIME NULL,
	CODE INT NULL,
	STATUS char(1) NULL,
	OPERATION CHAR(1) NULL,
	INCLUDE_IN DATETIME NULL,
	PRIMARY KEY (ID)
);
create table LGQUEUE(
	ID INT IDENTITY NOT NULL UNIQUE,
	IDQUEUE INT NOT NULL,
	IDCOMPANY INT NOT NULL,
	DESCRIPTION_LOG VARCHAR(20) NULL,
	BEGIN_DATE DATETIME NULL,
	END_DATE DATETIME NULL,
	MAX_SIZE INT NULL,
	LAST_CODE INT NULL,
	WAIT_INT_LINE INT NULL,
	OPERATION CHAR(1) NULL,
	INCLUDE_IN DATETIME NULL,
	PRIMARY KEY (ID)
);
create table TBREQUEST(
	ID int Identity NOT NULL unique,
	REQUEST text NULL,
	TYPE char(1) NOT NULL,
	RESPONSE text NULL, 
	INCLUDE_IN datetime NULL default getDate(),
	primary key (ID)
);
create table TBIPS(
	ID int Identity NOT NULL unique,
	IP varchar(15) NULL,
	TYPE char(1) NULL,
	primary key (ID)
);
ALTER TABLE TBRESERVES ADD CONSTRAINT SL_RESERVES_USER FOREIGN KEY (IDUSER) REFERENCES TBUSER (ID);
ALTER TABLE TBRESERVES ADD CONSTRAINT SL_RESERVES_QUEUE FOREIGN KEY (IDQUEUE) REFERENCES TBQUEUE (ID);
ALTER TABLE TBQUEUE ADD CONSTRAINT SL_QUEUE_COMPANY FOREIGN KEY (IDCOMPANY) REFERENCES TBCOMPANY (ID);
ALTER TABLE TBCOMPANY ADD CONSTRAINT SL_COMPANY_USER FOREIGN KEY (IDUSER) REFERENCES TBUSER (ID);
ALTER TABLE TBREQUEST ADD CONSTRAINT CSHORTLINE1000_TBREQUEST CHECK (TYPE IS NULL OR (TYPE IN ('I','O')));
ALTER TABLE TBREQUEST ADD CONSTRAINT CSHORTLINE1000_TBREQUEST CHECK (TYPE IS NULL OR (TYPE IN ('H','S','A')));
ALTER TABLE TBREQUEST ADD CONSTRAINT CSHORTLINE1000_TBIPS CHECK (TYPE IS NULL OR (TYPE IN ('H','S','A')));
