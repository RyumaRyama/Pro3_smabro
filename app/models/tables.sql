-- fighterモデル
-- 初期化
DROP TABLE IF EXISTS fighters;
CREATE TABLE fighters (
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
