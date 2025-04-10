CREATE EXTENSION pg_mooncake;

-- URL_STYLE: https://github.com/Mooncake-Labs/pg_mooncake/issues/118
-- SELECT mooncake.drop_secret('test');
SELECT mooncake.create_secret('test', 'S3', '<key_id>',
    '<secret>', '{"ENDPOINT": "api.minio.s", "USE_SSL": "false", "URL_STYLE": "path"}');

ALTER DATABASE foo SET mooncake.default_bucket = 's3://delta-test';

CREATE TABLE user_activity(
  user_id BIGINT,
  activity_type TEXT,
  activity_timestamp TIMESTAMP,
  duration INT
) USING columnstore;

INSERT INTO user_activity VALUES
  (1, 'login', '2024-01-01 08:00:00', 120),
  (2, 'page_view', '2024-01-01 08:05:00', 30),
  (3, 'logout', '2024-01-01 08:30:00', 60),
  (4, 'error', '2024-01-01 08:13:00', 60);

SELECT * from user_activity;
