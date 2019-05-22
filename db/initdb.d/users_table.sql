CREATE DATABASE IF NOT EXISTS db;

use db;

CREATE TABLE IF NOT EXISTS users(
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    line_id VARCHAR(255) NOT NULL,
    PRIMARY KEY(id)
);

INSERT IGNORE
    INTO users(name, line_id)
    VALUES
        ("赤座あかり", "akari"),
        ("歳納京子", "kyoko"),
        ("船見結衣", "yui"),
        ("吉川ちなつ", "chinatsu")
;

CREATE TABLE IF NOT EXISTS fighters(
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY(id)
);

LOAD DATA INFILE '/insert_data/characters'
    INTO TABLE fighters(name);

