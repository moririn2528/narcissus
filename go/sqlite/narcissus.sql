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

INSERT INTO plant(id,name,hash) VALUES (0,"hoge","huga", 0),(1,"piyo","hash", 1);


CREATE TABLE tag(
	id INTEGER PRIMARY KEY,
	name TEXT NOT NULL
);

INSERT INTO tag(id,name) VALUES (0,"tag1"),(1,"tag2");


CREATE TABLE plant_tag(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	plant_id INTEGER,
	tag_id INTEGER,
	UNIQUE(plant_id, tag_id)
);

INSERT INTO plant_tag(plant_id,tag_id) VALUES (0,0),(0,1),(1,1);

-- 位置情報テーブル
CREATE TABLE location_info(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	latitude REAL NOT NULL,
	longitude REAL NOT NULL
);

-- 位置情報とタグを結ぶテーブル
CREATE TABLE location_info_tag(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	tag_id INTEGER NOT NULL,
	location_id INTEGER NOT NULL,
	FOREIGN KEY  (tag_id) REFERENCES tag(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (location_id) REFERENCES location_info(id)  ON DELETE CASCADE ON UPDATE CASCADE
);
