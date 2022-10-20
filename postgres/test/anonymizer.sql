ALTER DATABASE foo SET session_preload_libraries = 'anon';
CREATE EXTENSION anon CASCADE;
SELECT anon.init();


CREATE EXTENSION IF NOT EXISTS anon CASCADE;
SELECT anon.start_dynamic_masking();

CREATE ROLE skynet LOGIN;
SECURITY LABEL FOR anon ON ROLE skynet IS 'MASKED';

SECURITY LABEL FOR anon ON COLUMN people.name
IS 'MASKED WITH FUNCTION anon.fake_last_name()';

SECURITY LABEL FOR anon ON COLUMN people.phone
IS 'MASKED WITH FUNCTION anon.partial(phone,2,$$******$$,2)';

psql peopledb -U skynet -c 'SELECT * FROM people;'
