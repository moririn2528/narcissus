/* rarity : 植物がその土地でしか見られない「レア」なものだった場合、優先的に推薦したいために作成したカラム
いまのところ、「レアかレアじゃないか」の二択を想定（しかしSQLITEではBOOL型が提供されてないっぽいのでとりあえずINTEGER
レア度に何段階か設けることになったとしても、INTEGERであれば拡張できてなおよい（？） */
CREATE TABLE plant(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
	detail TEXT,
    rarity INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT (datetime('now','localtime')),
	updated_at TIMESTAMP DEFAULT (datetime('now','localtime')),
	UNIQUE(name)
);
CREATE TRIGGER trigger_plant_updated_at AFTER UPDATE ON plant
BEGIN
    UPDATE plant SET updated_at = DATETIME('now', 'localtime') WHERE rowid == NEW.rowid;
END;

INSERT INTO plant(name,detail,rarity) VALUES ("hoge","すごく綺麗", 0),("piyo","とてもきれい", 1);

-- タグ情報を格納するテーブル
CREATE TABLE tag(
	id INTEGER PRIMARY KEY,
	name TEXT NOT NULL
);

INSERT INTO tag(id,name) VALUES (1,"tag1"),(2,"tag2");

-- 植物とタグを結びつけるテーブル
CREATE TABLE plant_tag(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	plant_id INTEGER,
	tag_id INTEGER,
	FOREIGN KEY  (plant_id) REFERENCES plant(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY  (tag_id) REFERENCES tag(id) ON DELETE CASCADE ON UPDATE CASCADE,
	UNIQUE(plant_id, tag_id)
);

INSERT INTO plant_tag(plant_id,tag_id) VALUES (1,1),(1,2),(2,2);

-- 投稿を保存するテーブル
CREATE TABLE upload_post(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	plant_id INTEGER NOT NULL,
	latitude REAL NOT NULL,
	longitude REAL NOT NULL,
	hash TEXT NOT NULL,
	created_at TIMESTAMP DEFAULT (datetime('now','localtime')),
	FOREIGN KEY  (plant_id) REFERENCES plant(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 位置情報から近いやつを取ってくるためのテストデータ

INSERT INTO upload_post(plant_id, latitude, longitude, hash) VALUES
(1, 35.02527355160815, 135.77870285267127, "hash1"), -- 百万遍付近
(2, 35.02498254430388, 135.77890210637494, "hash2"), -- 百万遍付近
(1, 35.027641696798966, 135.7837294039685, "hash3"), -- 総合研究7号館
(2, 34.98743999181396, 135.75932937378468, "hash4"), -- 京都タワー
(1, 35.011490834291145, 135.76798684721498, "hash5"); -- 京都市役所
(1, 35.0303004, 135.7911536, "home");

-- 植物の日本語名と英語名を関連付けるテーブル
CREATE TABLE plant_names(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	english_name TEXT NOT NULL,
	UNIQUE(name, english_name)
);

-- テストデータ 本当はnameは日本語名だが今はサンプルなのでhogeとか
INSERT INTO plant_names(name,english_name) VALUES
("hoge","hoge plant"),
("piyo","piyo plant");