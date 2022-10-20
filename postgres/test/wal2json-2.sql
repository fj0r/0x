-- docker exec -it pg-test psql -U postgres
CREATE TABLE table_with_pk (a SERIAL, b VARCHAR(30), c TIMESTAMP NOT NULL, PRIMARY KEY(a, c));
CREATE TABLE table_without_pk (a SERIAL, b NUMERIC(5,2), c TEXT);

BEGIN;
INSERT INTO table_with_pk (b, c) VALUES('Backup and Restore', now());
INSERT INTO table_with_pk (b, c) VALUES('Tuning', now());
INSERT INTO table_with_pk (b, c) VALUES('Replication', now());
DELETE FROM table_with_pk WHERE a < 3;

INSERT INTO table_without_pk (b, c) VALUES(2.34, 'Tapir');
-- it is not added to stream because there isn't a pk or a replica identity
UPDATE table_without_pk SET c = 'Anta' WHERE c = 'Tapir';
COMMIT;
