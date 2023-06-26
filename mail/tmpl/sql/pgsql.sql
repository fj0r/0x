CREATE USER {{ datasource.user }} WITH PASSWORD '{{ datasource.password }}';
CREATE DATABASE {{ datasource.dbname }};
GRANT ALL PRIVILEGES ON DATABASE {{ datasource.dbname }} TO {{ datasource.user }};
