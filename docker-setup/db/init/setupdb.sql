-- Setup for demo db
CREATE USER walle WITH PASSWORD 'walle';
CREATE DATABASE mydoctordemo WITH OWNER walle;
GRANT ALL PRIVILEGES ON DATABASE mydoctordemo TO walle;
CREATE DATABASE myhealthdemo WITH OWNER walle;
GRANT ALL PRIVILEGES ON DATABASE myhealthdemo TO walle;
CREATE DATABASE mypharmacydemo WITH OWNER walle;
GRANT ALL PRIVILEGES ON DATABASE mypharmacydemo TO walle;
