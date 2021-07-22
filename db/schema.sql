CREATE TABLE users (
  id SERIAL,

  first_name VARCHAR(64) NOT NULL,
  last_name VARCHAR(64) NOT NULL,
  email VARCHAR(255) NOT NULL,
  credit_card VARCHAR(255) NOT NULL,

  created_at timestamp  NOT NULL  DEFAULT current_timestamp,
  updated_at timestamp  NOT NULL  DEFAULT current_timestamp,
  deleted_at timestamp,

  PRIMARY KEY(id)
);