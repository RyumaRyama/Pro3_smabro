-- fighterモデル
CREATE TABLE IF NOT EXISTS fighters (
    id SERIAL NOT NULL, -- 自動連番
    name TEXT NOT NULL UNIQUE, -- 重複禁止
    PRIMARY KEY (id)
);

-- usersモデル
CREATE TABLE IF NOT EXISTS users (
    id INTEGER NOT NULL,
    name TEXT NOT NULL,
    PRIMARY KEY (id)
);
