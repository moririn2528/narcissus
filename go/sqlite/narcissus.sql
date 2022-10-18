/* rarity : 植物がその土地でしか見られない「レア」なものだった場合、優先的に推薦したいために作成したカラム
いまのところ、「レアかレアじゃないか」の二択を想定（しかしSQLITEではBOOL型が提供されてないっぽいのでとりあえずINTEGER
レア度に何段階か設けることになったとしても、INTEGERであれば拡張できてなおよい（？） */
CREATE TABLE plant(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    hash TEXT NOT NULL,
    rarity INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT (datetime('now','localtime')),
	updated_at TIMESTAMP DEFAULT (datetime('now','localtime'))
);
CREATE TRIGGER trigger_plant_updated_at AFTER UPDATE ON plant
BEGIN
    UPDATE plant SET updated_at = DATETIME('now', 'localtime') WHERE rowid == NEW.rowid;
END;

INSERT INTO plant(id,name,hash,rarity) VALUES (0,"hoge","huga", 0),(1,"piyo","hash", 1);

-- タグ情報を格納するテーブル
CREATE TABLE tag(
	id INTEGER PRIMARY KEY,
	name TEXT NOT NULL
);

INSERT INTO tag(id,name) VALUES (0,"tag1"),(1,"tag2");

-- 植物とタグを結びつけるテーブル
CREATE TABLE plant_tag(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	plant_id INTEGER,
	tag_id INTEGER,
	FOREIGN KEY  (plant_id) REFERENCES plant(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY  (tag_id) REFERENCES tag(id) ON DELETE CASCADE ON UPDATE CASCADE,
	UNIQUE(plant_id, tag_id)
);

INSERT INTO plant_tag(plant_id,tag_id) VALUES (0,0),(0,1),(1,1);

-- 投稿を保存するテーブル
CREATE TABLE post(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	plant_id INTEGER NOT NULL,
	latitude REAL NOT NULL,
	longitude REAL NOT NULL,
	hash TEXT NOT NULL,
	created_at TIMESTAMP DEFAULT (datetime('now','localtime')),
	FOREIGN KEY  (plant_id) REFERENCES plant(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 位置情報から近いやつを取ってくるためのテストデータ
INSERT INTO post(plant_id, latitude, longitude, hash) VALUES
(0, 35.02527355160815, 135.77870285267127, "huga"), -- 百万遍付近
(1, 35.02498254430388, 135.77890210637494, "hash"), -- 百万遍付近
(0, 35.027641696798966, 135.7837294039685, "huga"), -- 総合研究7号館
(1, 34.98743999181396, 135.75932937378468, "huga"), -- 京都タワー
(0, 35.011490834291145, 135.76798684721498, "hash"); -- 京都市役所