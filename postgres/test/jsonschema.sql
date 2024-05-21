create extension pg_jsonschema;

create table customer(
    id serial primary key,
    metadata json,

    check (
        json_matches_schema(
            '{
                "type": "object",
                "properties": {
                    "tags": {
                        "type": "array",
                        "items": {
                            "type": "string",
                            "maxLength": 16
                        }
                    }
                }
            }'::json,
            metadata
        )
    )
);

-- Example: Valid Payload
insert into customer(metadata)
values ('{"tags": ["vip", "darkmode-ui"]}');
-- Result:
--   INSERT 0 1

-- Example: Invalid Payload
insert into customer(metadata)
values ('{"tags": [1, 3]}');
-- Result:
--   ERROR:  new row for relation "customer" violates check constraint "customer_metadata_check"
--   DETAIL:  Failing row contains (2, {"tags": [1, 3]}).
