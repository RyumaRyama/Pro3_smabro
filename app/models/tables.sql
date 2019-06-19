-- fighterモデル
-- 初期化
-- DROP TABLE IF EXISTS fighters;
CREATE TABLE IF NOT EXISTS fighters (
    id INTEGER NOT NULL UNIQUE, -- 自動連番
    name TEXT NOT NULL UNIQUE, -- 重複禁止
    PRIMARY KEY (id)
);

-- usersモデル
CREATE TABLE IF NOT EXISTS users (
    id INTEGER NOT NULL UNIQUE,
    name TEXT NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS notes (
    id SERIAL UNIQUE,
    fighter_id INTEGER REFERENCES fighters (id), --fighters_tableと紐付ける
    memo TEXT NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS players (
  id INTEGER NOT NULL UNIQUE,
  name TEXT NOT NULL UNIQUE,
  lineid TEXT NOT NULL,
  password TEXT NOT NULL,
  PRIMARY KEY (id)
)
