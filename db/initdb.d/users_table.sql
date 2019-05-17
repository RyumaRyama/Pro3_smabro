CREATE DATABASE IF NOT EXISTS db;

use db;

CREATE TABLE IF NOT EXISTS users(
    id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT IGNORE
    INTO users(name)
    VALUES
        ("Akari Akaza"),
        ("Kyoko Toshino"),
        ("Yui Funami"),
        ("Chinatsu Yoshikawa")
;


