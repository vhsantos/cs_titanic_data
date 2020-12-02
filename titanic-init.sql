-- Connect to DATABASE titanicdb; 
\c titanicdb 



-- Add a extension to create uuid
-- https://www.postgresql.org/docs/current/uuid-ossp.html
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- BUG changed age from integer to numeric because a bug in titanic.csv at line 58.
-- Create a table people with a uuid primary key generate automaticly
CREATE TABLE IF NOT EXISTS people (
	uuid uuid DEFAULT uuid_generate_v4 (),
	"survived" boolean,
	"passengerClass" integer NOT NULL,
    "name" VARCHAR NOT NULL,
    "sex" VARCHAR NOT NULL,
	"age" numeric,
	"siblingsOrSpousesAboard" integer,
	"parentsOrChildrenAboard" integer,
	"fare" numeric,
    PRIMARY KEY (uuid)
);


-- Create some roles (read-only and read-write)
CREATE ROLE api_ro NOLOGIN;
grant usage on schema public to api_ro;
grant select on public.people to api_ro;

CREATE ROLE api_rw NOLOGIN;
grant usage on schema public to api_rw;
grant all on public.people to api_rw;

-- Associate the previous roles with an authenticator.
CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'SDldYw7G2FxnzKCeoM3TPhGSGW1l9bEz';
grant api_ro to authenticator;
grant api_rw to authenticator;


-- Copy data from CSV file cloned from repository in InitContainer
COPY people ("survived","passengerClass","name","sex","age","siblingsOrSpousesAboard","parentsOrChildrenAboard","fare") FROM '/docker-entrypoint-initdb.d/titanic.csv' DELIMITER ',' CSV HEADER;

-- Data sample:
-- Survived,Pclass,Name,Sex,Age,Siblings/Spouses Aboard,Parents/Children Aboard,Fare
-- --------------------------------------------------------------------------------
-- 0,3,Mr. Owen Harris Braund,male,22,1,0,7.25
-- 1,1,Mrs. John Bradley (Florence Briggs Thayer) Cumings,female,38,1,0,71.2833
-- 1,3,Miss. Laina Heikkinen,female,26,0,0,7.925
-- 1,1,Mrs. Jacques Heath (Lily May Peel) Futrelle,female,35,1,0,53.1

