CREATE DATABASE IF NOT EXISTS db;

use db;

CREATE TABLE IF NOT EXISTS users(
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    account_name VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    password_confirmation VARCHAR(255) NOT NULL,
    PRIMARY KEY(id)
);

INSERT IGNORE
    INTO users(name, account_name, password, password_confirmation)
    VALUES
        ("赤座あかり", "akari", "akari", "akari"),
        ("歳納京子", "kyoko", "kyoko", "kyoko"),
        ("船見結衣", "yui", "yui", "yui"),
        ("吉川ちなつ", "chinatsu", "chinatsu", "chinatsu")
;


