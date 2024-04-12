-- Create the tablespace
CREATE TABLESPACE hospital_tables
DATAFILE 'hospital_files_01.dbf'
SIZE 200M
AUTOEXTEND ON
NEXT 100M
MAXSIZE UNLIMITED;

-- Create the user
CREATE USER hospital IDENTIFIED BY "hospital" DEFAULT TABLESPACE hospital_tables 
QUOTA UNLIMITED ON hospital_tables;

GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE SEQUENCE TO hospital;
