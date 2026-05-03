
/* Create database and schemas */
DROP DATABASE IF EXISTS datawarehouse;

CREATE DATABASE datawarehouse;

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;