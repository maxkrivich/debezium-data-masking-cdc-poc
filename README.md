# Debezium data masking demo
This setup is going to demonstrate how to receive events from PostgreSQL database and stream them down to an Elasticsearch server with masking data in an event using the Devbezium + SMT.

![Untitled Diagram](https://user-images.githubusercontent.com/12199867/126694975-7a8d5aeb-fa06-4d25-92ea-7643de1d52c3.jpg)



### Setup the environment
```bash
# Start conteiners
$ docker compose up -d

# Create the `users` table
$ docker compose exec source_db bash

root@5343b18463b7:/# psql -U $POSTGRES_USER $POSTGRES_DB
psql (9.6.22)
Type "help" for help.

application=# CREATE TABLE users (
application(#   id SERIAL,
application(#   first_name VARCHAR(64) NOT NULL,
application(#   last_name VARCHAR(64) NOT NULL,
application(#   email VARCHAR(255) NOT NULL,
application(#   credit_card VARCHAR(255) NOT NULL,
application(#   created_at timestamp  NOT NULL  DEFAULT current_timestamp,
application(#   updated_at timestamp  NOT NULL  DEFAULT current_timestamp,
application(#   deleted_at timestamp,
application(#
application(#   PRIMARY KEY(id)
application(# );
CREATE TABLE
application=# \dt+;
                      List of relations
 Schema | Name  | Type  |  Owner   |    Size    | Description
--------+-------+-------+----------+------------+-------------
 public | users | table | postgres | 8192 bytes |
(1 row)

application=# \d users;
                                      Table "public.users"
   Column    |            Type             |                     Modifiers
-------------+-----------------------------+----------------------------------------------------
 id          | integer                     | not null default nextval('users_id_seq'::regclass)
 first_name  | character varying(64)       | not null
 last_name   | character varying(64)       | not null
 email       | character varying(255)      | not null
 credit_card | character varying(255)      | not null
 created_at  | timestamp without time zone | not null default now()
 updated_at  | timestamp without time zone | not null default now()
 deleted_at  | timestamp without time zone |
Indexes:
    "users_pkey" PRIMARY KEY, btree (id)

application=# \q
root@03945d5bdae0:/# exit

# Start elasticsearch sink connector
$ curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @connectors/users_sink.json

# Start PostgreSQL connector
$ curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @connectors/users_connector.json

# Setup the ES index
$ curl -X PUT localhost:9200/source_db1.public.users -H "Content-Type:application/json" -d @db/es_index.json
```

### Connectors healthcheck
```bash
$ curl localhost:8083/connectors/users-connector/status
$ curl localhost:8083/connectors/users-sink/status
```

### Demo

#### Insert / update records
```bash
$ docker compose  exec source_db bash
root@03945d5bdae0:/# psql -U $POSTGRES_USER $POSTGRES_DB

application=# INSERT INTO users (first_name, last_name, email, credit_card) VALUES ('John', 'Doe', 'john.doe@example.com', '5555-5555-5555-5555');
INSERT 0 1
application=# INSERT INTO users (first_name, last_name, email, credit_card) VALUES ('Max', 'Krivich', 'max@example.com', '2222-2222-2222-2222');
INSERT 0 1
application=# UPDATE users SET first_name='Mike', email='mike@example.com'  WHERE email='max@example.com';
UPDATE 1
application=#
```

#### Kafka topic
```bash
# Read out messages from a kafka topic
$ docker run -it --network=debezium-poc_default edenhill/kafkacat:1.6.0 -b kafka:9092 -t source_db1.public.users
^[[A% Auto-selecting Consumer mode (use -P or -C to override)
% Reached end of topic source_db1.public.users [0] at offset 0
^[[A^[[A{"schema":{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":false,"field":"first_name"},{"type":"string","optional":false,"field":"last_name"},{"type":"string","optional":false,"field":"email"},{"type":"string","optional":false,"field":"credit_card"}],"optional":false,"name":"source_db1.public.users.Value"},"payload":{"id":1,"first_name":"John","last_name":"Doe","email":"john.doe@example.com","credit_card":"5555-5555-5555-5555"}}
% Reached end of topic source_db1.public.users [0] at offset 1
{"schema":{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":false,"field":"first_name"},{"type":"string","optional":false,"field":"last_name"},{"type":"string","optional":false,"field":"email"},{"type":"string","optional":false,"field":"credit_card"}],"optional":false,"name":"source_db1.public.users.Value"},"payload":{"id":2,"first_name":"Max","last_name":"Krivich","email":"max@example.com","credit_card":"2222-2222-2222-2222"}}
% Reached end of topic source_db1.public.users [0] at offset 2
{"schema":{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":false,"field":"first_name"},{"type":"string","optional":false,"field":"last_name"},{"type":"string","optional":false,"field":"email"},{"type":"string","optional":false,"field":"credit_card"}],"optional":false,"name":"source_db1.public.users.Value"},"payload":{"id":2,"first_name":"Mike","last_name":"Krivich","email":"mike@example.com","credit_card":"2222-2222-2222-2222"}}
% Reached end of topic source_db1.public.users [0] at offset 3

% Reached end of topic source_db1.public.users [0] at offset 4
```

#### Elasticsearch index
![IMAGE 2021-07-22 21:06:12](https://user-images.githubusercontent.com/12199867/126695361-7dc1eb05-b014-4597-8d04-0cfa978e0934.jpg)

### Links

https://github.com/edenhill/kafkacat

https://debezium.io/documentation/reference/architecture.html

https://debezium.io/documentation/reference/0.9/connectors/postgresql.html

https://github.com/debezium/debezium-examples/tree/master/tutorial

https://debezium.io/documentation/reference/connectors/postgresql.html
