create tablespace lob_tbs
datafile 'lob_data.dbf' size 50M
AUTOEXTEND ON;

create user lob_user IDENTIFIED by password123;
grant connect, resource to lob_user;
alter user lob_user QUOTA 50M on lob_tbs;

CREATE OR REPLACE DIRECTORY LOB_DIR AS '/media';
GRANT READ ON DIRECTORY LOB_DIR TO lob_user;

DROP USER lob_user CASCADE;
DROP DIRECTORY LOB_DIR;
DROP TABLESPACE lob_tbs INCLUDING CONTENTS AND DATAFILES;