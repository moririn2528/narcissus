/* rarity : 植物がその土地でしか見られない「レア」なものだった場合、優先的に推薦したいために作成したカラム
いまのところ、「レアかレアじゃないか」の二択を想定（しかしSQLITEではBOOL型が提供されてないっぽいのでとりあえずINTEGER
レア度に何段階か設けることになったとしても、INTEGERであれば拡張できてなおよい（？） */
CREATE TABLE plant(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
	  detail TEXT,
    rarity INTEGER NOT NULL DEFAULT 0,
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

-- INSERT INTO tag(id,name) VALUES (1,"tag1"),(2,"tag2");

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
(1, 35.011490834291145, 135.76798684721498, "hash5"), -- 京都市役所
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

-- 植物名を英語から日本語に変換
-- CREATE TABLE plant_translate(
-- 	id INTEGER PRIMARY KEY AUTOINCREMENT,
-- 	en_name TEXT NOT NULL,
-- 	jp_name TEXT NOT NULL,
-- 	created_at TIMESTAMP DEFAULT (datetime('now','localtime'))
-- );

-- INSERT INTO plant_translate(en_name, jiop_name) VALUES
-- ("Cherry blossom", "桜");

INSERT INTO tag VALUES 
(11,"春"),
(12,"夏"),
(13,"秋"),
(14,"冬"),
(15,"梅雨");
INSERT INTO tag VALUES 
(10001,"木"),
(10002,"草"),
(10003,"花"),
(10004,"水草"),
(10005,"海藻");
INSERT INTO tag VALUES 
(20001,"コケ植物"),
(20002,"多肉植物"),
(20003,"つる植物"),
(20004,"シダ植物"),
(20005,"種子植物"),
(20006,"寄生植物"),
(20007,"観葉植物"),
(20008,"食虫植物"),
(20009,"裸子植物"),
(20010,"被子植物"),
(20011,"単子葉類"),
(20012,"双子葉類");
INSERT INTO tag VALUES 
(30001,"水辺"),
(30002,"海浜"),
(30003,"渓流"),
(30004,"高山"),
(30005,"熱帯雨林"),
(30006,"マングローブ");
INSERT INTO tag VALUES 
(40001,"野菜"),
(40002,"果物"),
(40003,"キノコ"),
(40004,"穀物"),
(40005,"農作物");
INSERT INTO tag VALUES 
(50001,"有毒"),
(50002,"美味しい"),
(50003,"不味い"),
(50004,"きれい"),
(50005,"大きい"),
(50006,"小さい");
INSERT INTO tag VALUES 
(60001,"赤"),
(60002,"青"),
(60003,"緑"),
(60004,"黄"),
(60005,"紫"),
(60006,"白"),
(60007,"黒");
INSERT INTO tag VALUES 
(70001,"アオイ科"),
(70002,"アオギリ科"),
(70003,"アカザ科"),
(70004,"アカネ科"),
(70005,"アカバナ科"),
(70006,"アケビ科"),
(70007,"アサ科"),
(70008,"アジサイ科"),
(70009,"アブラナ科"),
(70010,"アマモ科"),
(70011,"アヤメ科"),
(70012,"アリノトウグサ科"),
(70013,"アルストロメリア科"),
(70014,"アロエ科"),
(70015,"イイギリ科"),
(70016,"イキシオリリオン科"),
(70017,"イグサ科"),
(70018,"イソマツ科"),
(70019,"イチイ科"),
(70020,"イヌガヤ科"),
(70021,"イヌサフラン科"),
(70022,"イネ科"),
(70023,"イラクサ科"),
(70024,"イワウメ科"),
(70025,"イワタバコ科"),
(70026,"ウォキシア科"),
(70027,"ウキクサ科"),
(70028,"ウコギ科"),
(70029,"ウマノスズクサ科"),
(70030,"ウリ科"),
(70031,"ウルシ科"),
(70032,"エウポマティア科"),
(70033,"エゴノキ科"),
(70034,"オウムバナ科"),
(70035,"オオバコ科"),
(70036,"オシロイバナ科"),
(70037,"オトギリソウ科"),
(70038,"オミナエシ科"),
(70039,"オモダカ科"),
(70040,"カエデ科"),
(70041,"ガガイモ科"),
(70042,"カキノキ科"),
(70043,"カタバミ科"),
(70044,"カツラ科"),
(70045,"カネラ科"),
(70046,"カバノキ科"),
(70047,"ガマ科"),
(70048,"カヤツリグサ科"),
(70049,"カワゴケソウ科"),
(70050,"カンナ科"),
(70051,"キキョウ科"),
(70052,"キク科"),
(70053,"キツネノマゴ科"),
(70054,"キブシ科"),
(70055,"キョウチクトウ科"),
(70056,"ギョリュウ科"),
(70057,"キントラノオ科"),
(70058,"キンバイザサ科"),
(70059,"キンポウゲ科"),
(70060,"クサトベラ科"),
(70061,"クスノキ科"),
(70062,"クノニア科"),
(70063,"クマツヅラ科"),
(70064,"グミ科"),
(70065,"クルミ科"),
(70066,"クロウメモドキ科"),
(70067,"クロタキカズラ科"),
(70068,"クワ科"),
(70069,"グンネラ科"),
(70070,"ケシ科"),
(70071,"ケマンソウ科"),
(70072,"ゴクラクチョウカ科"),
(70073,"コショウ科"),
(70074,"ゴマノハグサ科"),
(70075,"ゴマ科"),
(70076,"サクラソウ科"),
(70077,"サトイモ科"),
(70078,"サボテン科"),
(70079,"サラセニア科"),
(70080,"サルトリイバラ科"),
(70081,"シキミ科"),
(70082,"シソ科"),
(70083,"シナノキ科"),
(70084,"シモンジア科"),
(70085,"シャクジョウソウ科"),
(70086,"ジャケツイバラ科"),
(70087,"シュウカイドウ科"),
(70088,"ショウガ科"),
(70089,"ショウブ科"),
(70090,"シレンゲ科"),
(70091,"ジンチョウゲ科"),
(70092,"スイカズラ科"),
(70093,"スイレン科"),
(70094,"スギ科"),
(70095,"スグリ科"),
(70096,"スズカケノキ科"),
(70097,"スズラン亜科"),
(70098,"スベリヒユ科"),
(70099,"スミレ科"),
(70100,"セリ科"),
(70101,"センダン科"),
(70102,"センリョウ科"),
(70103,"タコノキ科"),
(70104,"タシロイモ科"),
(70105,"タデ科"),
(70106,"タヌキアヤメ科"),
(70107,"タヌキモ科"),
(70108,"ツゲ科"),
(70109,"ツチトリモチ科"),
(70110,"ツツジ科"),
(70111,"ツヅラフジ科"),
(70112,"ツバキ科"),
(70113,"ツユクサ科"),
(70114,"ツリフネソウ科"),
(70115,"ツルボラン科"),
(70116,"ツルムラサキ科"),
(70117,"ディディエレア科"),
(70118,"テミス科"),
(70119,"トウダイグサ科"),
(70120,"ドクウツギ科"),
(70121,"ドクダミ科"),
(70122,"トケイソウ科"),
(70123,"トチカガミ科"),
(70124,"トチノキ科"),
(70125,"トベラ科"),
(70126,"ナス科"),
(70127,"ナデシコ科"),
(70128,"ナンヨウスギ科"),
(70129,"ニガキ科"),
(70130,"ニクズク科"),
(70131,"ニシキギ科"),
(70132,"ニレ科"),
(70133,"ヌマミズキ科"),
(70134,"ネギ科"),
(70135,"ネムノキ科"),
(70136,"ノウゼンカズラ科"),
(70137,"ノウゼンハレン科"),
(70138,"ノボタン科"),
(70139,"パイナップル科"),
(70140,"ハイノキ科"),
(70141,"ハエモドルム科"),
(70142,"ハゴロモモ科"),
(70143,"バショウ科"),
(70144,"ハスノハギリ科"),
(70145,"ハス科"),
(70146,"ハゼリソウ科"),
(70147,"ハナイ科"),
(70148,"ハナシノブ科"),
(70149,"パナマソウ科"),
(70150,"パパイア科"),
(70151,"ハマウツボ科"),
(70152,"ハマビシ科"),
(70153,"ハマミズナ科"),
(70154,"バラ科"),
(70155,"ハンニチバナ科"),
(70156,"パンヤ科"),
(70157,"バンレイシ科"),
(70158,"ヒガンバナ科"),
(70159,"ヒシ科"),
(70160,"ヒダテラ科"),
(70161,"ヒドロスタキス科"),
(70162,"ヒナノシャクジョウ科"),
(70163,"ヒノキ科"),
(70164,"ヒマンタンドラ科"),
(70165,"ヒメハギ科"),
(70166,"ビャクダン科"),
(70167,"ビャクブ科"),
(70168,"ヒユ科"),
(70169,"ヒルガオ科"),
(70170,"ヒルギ科"),
(70171,"ビワモドキ科"),
(70172,"フウチョウソウ科"),
(70173,"フウロソウ科"),
(70174,"フサザクラ科"),
(70175,"フジウツギ科"),
(70176,"ブドウ科"),
(70177,"フトモモ科"),
(70178,"ブナ科"),
(70179,"ベニノキ科"),
(70180,"ベンケイソウ科"),
(70181,"ホシクサ科"),
(70182,"ボタン科"),
(70183,"ホルトノキ科"),
(70184,"ボロボロノキ科"),
(70185,"マキ科"),
(70186,"マタタビ科"),
(70187,"マチン科"),
(70188,"マツブサ科"),
(70189,"マツムシソウ科"),
(70190,"マツモ科"),
(70191,"マツ科"),
(70192,"マメ科"),
(70193,"マンサク科"),
(70194,"ミカン科"),
(70195,"ミズアオイ科"),
(70196,"ミズキ科"),
(70197,"ミソハギ科"),
(70198,"ミツガシワ科"),
(70199,"ミツバウツギ科"),
(70200,"ムクロジ科"),
(70201,"ムラサキ科"),
(70202,"メギ科"),
(70203,"モウセンゴケ科"),
(70204,"モクセイ科"),
(70205,"モクレン科"),
(70206,"モチノキ科"),
(70207,"ヤマゴボウ科"),
(70208,"ヤマノイモ科"),
(70209,"ユキノシタ科"),
(70210,"ユズリハ科"),
(70211,"ユリズイセン科"),
(70212,"ユリ科"),
(70213,"ラン科"),
(70214,"リムナンテス科"),
(70215,"リュウゼツラン科"),
(70216,"リンドウ科"),
(70217,"ロウバイ科"),
(70218,"バラ目"),
(70219,"ハンニチバナ科"),
(70220,"パンヤ科"),
(70221,"バンレイシ科"),
(70222,"ヒガンバナ科"),
(70223,"ヒシ科"),
(70224,"ヒダテラ科"),
(70225,"ヒドロスタキス科"),
(70226,"ヒナノシャクジョウ科"),
(70227,"ヒノキ科"),
(70228,"ヒマンタンドラ科"),
(70229,"ヒメハギ科"),
(70230,"ヒメハギ目"),
(70231,"ビャクシン属"),
(70232,"ビャクダン科"),
(70233,"ビャクダン目"),
(70234,"ビャクブ科"),
(70235,"ヒユ科"),
(70236,"ヒルガオ科"),
(70237,"ヒルギ科"),
(70238,"ビワモドキ亜綱"),
(70239,"ビワモドキ科"),
(70240,"ビワモドキ目"),
(70241,"フウチョウソウ科"),
(70242,"フウチョウソウ目"),
(70243,"フウロソウ科"),
(70244,"フウロソウ目"),
(70245,"フサザクラ科"),
(70246,"フジウツギ科"),
(70247,"ブドウ科"),
(70248,"フトモモ科"),
(70249,"フトモモ目"),
(70250,"ブナ科"),
(70251,"ベニノキ科"),
(70252,"ベンケイソウ科"),
(70253,"ホシクサ科"),
(70254,"ボタン科"),
(70255,"ホルトノキ科"),
(70256,"ボロボロノキ科"),
(70257,"マキ科"),
(70258,"マタタビ科"),
(70259,"マチン科"),
(70260,"マツブサ科"),
(70261,"マツムシソウ科"),
(70262,"マツムシソウ目"),
(70263,"マツモ科"),
(70264,"マツ科"),
(70265,"マメ科"),
(70266,"マメ目"),
(70267,"マンサク亜綱"),
(70268,"マンサク科"),
(70269,"マンサク目"),
(70270,"ミカン科"),
(70271,"ミズアオイ科"),
(70272,"ミズキ科"),
(70273,"ミズキ目"),
(70274,"ミソハギ科"),
(70275,"ミツガシワ科"),
(70276,"ミツバウツギ科"),
(70277,"ムクロジ科"),
(70278,"ムクロジ目"),
(70279,"ムラサキ科"),
(70280,"メギ科"),
(70281,"メロン"),
(70282,"モウセンゴケ科"),
(70283,"モクセイ科"),
(70284,"モクレン亜綱"),
(70285,"モクレン科"),
(70286,"モクレン目"),
(70287,"モチノキ科"),
(70288,"モチノキ目"),
(70289,"ヤマグルマ目"),
(70290,"ヤマゴボウ科"),
(70291,"ヤマノイモ科"),
(70292,"ヤマモガシ目"),
(70293,"ユキノシタ科"),
(70294,"ユキノシタ目"),
(70295,"ユズリハ科"),
(70296,"ユリズイセン科"),
(70297,"ユリ科"),
(70298,"ユリ目"),
(70299,"ラン科"),
(70300,"ラン目"),
(70301,"リムナンテス科"),
(70302,"リュウゼツラン科"),
(70303,"リンドウ科"),
(70304,"リンドウ目"),
(70305,"ロウバイ科");
INSERT INTO tag VALUES 
(80001,"アウストロバイレヤ目"),
(80002,"アオイ目"),
(80003,"アカネ目"),
(80004,"アブラナ目"),
(80005,"アムボレラ目"),
(80006,"アリノトウグサ目"),
(80007,"アワゴケ目"),
(80008,"イグサ目"),
(80009,"イネ目"),
(80010,"イバラモ目"),
(80011,"イラクサ目"),
(80012,"ウツボカズラ目"),
(80013,"ウマノスズクサ目"),
(80014,"オオバコ目"),
(80015,"オモダカ目"),
(80016,"カキノキ目"),
(80017,"カネラ目"),
(80018,"カヤツリグサ目"),
(80019,"ガリア目"),
(80020,"キキョウ目"),
(80021,"キク目"),
(80022,"キントラノオ目"),
(80023,"キンポウゲ目"),
(80024,"キジカクシ目"),
(80025,"クスノキ目"),
(80026,"クロウメモドキ目"),
(80027,"クロッソソマ目"),
(80028,"グンネラ目"),
(80029,"ケシ目"),
(80030,"コショウ目"),
(80031,"ゴマノハグサ目"),
(80032,"サクラソウ目"),
(80033,"サトイモ目"),
(80034,"シキミ目"),
(80035,"シソ目"),
(80036,"ショウガ目"),
(80037,"ショウブ目"),
(80038,"スイレン目"),
(80039,"スミレ目"),
(80040,"セリ目"),
(80041,"タコノキ目"),
(80042,"ツツジ目"),
(80043,"ツバキ目"),
(80044,"ツユクサ目"),
(80045,"トウダイグサ目"),
(80046,"ナス目"),
(80047,"ナデシコ目"),
(80048,"ニシキギ目"),
(80049,"ハマビシ目"),
(80050,"バラ目"),
(80051,"ヒメハギ目"),
(80052,"ビャクダン目"),
(80053,"ビワモドキ目"),
(80054,"フウチョウソウ目"),
(80055,"フウロソウ目"),
(80056,"フトモモ目"),
(80057,"マツムシソウ目"),
(80058,"マメ目"),
(80059,"マンサク目"),
(80060,"ミズキ目"),
(80061,"ムクロジ目"),
(80062,"モクレン目"),
(80063,"モチノキ目"),
(80064,"ヤマグルマ目"),
(80065,"ヤマモガシ目"),
(80066,"ユキノシタ目"),
(80067,"ユリ目"),
(80068,"ラン目"),
(80069,"リンドウ目");
INSERT INTO tag VALUES 
(90001,"アサ"),
(90002,"イチゴ"),
(90003,"梅"),
(90004,"キク亜綱"),
(90005,"グネツム綱"),
(90006,"紅藻"),
(90007,"コケ植物"),
(90008,"米"),
(90009,"桜"),
(90010,"シダ類"),
(90011,"ショウガ亜綱"),
(90012,"スプリング・エフェメラル"),
(90013,"ハーブ"),
(90014,"バラ亜綱"),
(90015,"ビャクシン属"),
(90016,"ビワモドキ亜綱"),
(90017,"マンサク亜綱"),
(90018,"メロン"),
(90019,"モクレン亜綱");



-- plantテーブルに植物の情報を入れます
INSERT INTO plant (name, detail) VALUES
("もみじ","紅葉狩りの「狩り」という言葉は「草花を眺めること」の意味をさし、平安時代には実際に紅葉した木の枝を手折り（狩り）、手のひらにのせて鑑賞する、という鑑賞方法があった。実際に枝を折り取って持ち帰る行為は森林窃盗罪となる。"),
("竹","竹が草の一種か木の一種かは意見が分かれている。現在のところ、多年草の一種として扱う学説が多い。"),
("ドクダミ","ドクダミの学名である Houttuynia cordata のうち、属名の Houttuynia はオランダの博物学者であるマールテン・ホッタイン (Maarten Houttuyn, 1720–1798) への献名であり、種小名の cordata はラテン語でハート形の葉の形を示している"),
("シロツメクサ", "濃厚な蜂蜜が得られる。また、若葉は食用になる。橋本郁三によると、塩茹でして葉柄が柔らかくなったら冷水で手早く冷まし、胡麻和え・辛子和え・甘酢などでいただくのが良い。花はフライ・てんぷらにする"),
("ヒガンバナ", "通常よく見られる赤色種のラジアータに加え、アルビノ種のように稀に色素形成異常で白みがかった個体もある"),
("タンポポ", "花のつくりは非常に進化していて、植物進化の系統では、頂点に立つグループの一つ。花は朝に開き、夕方に閉じる。雨が降らなければ、花は3日連続して、規則正しく開閉する。"),
("キンモクセイ", "樹皮が動物のサイ（犀）の足に似ていることから中国で「木犀」と名付けられ、ギンモクセイの白い花色に対して、橙黄色の花を金色に見立ててキンモクセイという名で呼ばれるようになった。"),
("イチョウ", "世界で最古の現生樹種の一つ。イチョウ類はペルム紀に出現し、大半が新生代に入ると絶滅したため、現在残っていたのはイチョウ類で唯一生き残っている種である。絶滅危惧種に指定されている。"),
("エノコログサ", "夏から秋にかけてつける花穂が、犬の尾に似ていることから、犬っころ草（いぬっころくさ）が転じてエノコログサという呼称になったとされ、漢字でも「狗（犬）の尾の草」と表記する。"),
("ジャスミン", "ほとんどの種が観賞用として栽培されている。栽培の歴史は古く、古代エジプトですでに行われていたといわれている。"),
("ゲッケイジュ", "庭木、公園樹としての利用のほか、ハーブとして、葉は香辛料（スパイス）として煮込み料理の香味づけに、葉や実は薬用として利用される。"),
("ラベンダー", "伝統的にハーブとして古代エジプト、ギリシャ、ローマ、アラビア、ヨーロッパなどで薬や調理に利用され、芳香植物としてその香りが活用されてきた。"),
("ミント", "変種が出来やすく600種を超えると言われるほど多種多様な種がある。"),
("ヨモギ", "ヨモギが持っている独特の香りは、害虫や雑菌から身を守るために抗菌化物質などの化学物質を発展させてきたものに由来する。多くの薬効があることからハーブの女王の異名がある。"),
("スイセン", "英語名はnarcissus。スイセンは日本の気候と相性が良いので、植え放しでも勝手に増える。"),
("ススキ", "枯れすすき（枯薄、花も穂も枯れたススキ）には枯れ尾花/枯尾花（かれおばな）という呼称（古名）もあり、現代でも「幽霊の正体見たり枯尾花」という諺はよく知られている。"),
("パンジー", "花が人間の顔に似て、8月には深く思索にふけるかのように前に傾くところからフランス語の「思想」を意味する単語パンセ（pensée）にちなんでパンジーと名づけられた。このその由来のために、パンジーは長い間自由思想のシンボルだった。"),
("プラタナス", "ニレ、ボダイジュ、マロニエとともに世界四大街路樹の一つに数えられる。樹皮が剥がれるとまるで迷彩柄のような見た目になる。"),
("梅", "日本では6月6日が「梅の日」とされている。天文14年4月17日（旧暦、1545年6月6日）、賀茂神社の例祭に梅が献上された故事に由来する。"),
("バラ", "近代以前、日本はバラの自生地として世界的に知られており、品種改良に使用された原種のうち3種類（ノイバラ、テリハノイバラ、ハマナス）は日本原産である。ちなみに、南半球にはバラは自生しない。"),
("チューリップ", "食用に適する一部の品種は、球根の糖度が極めて高くでん粉に富むため、オランダでは食用としての栽培も盛んで、主に製菓材料として用いられる。日本でもシロップ漬にした球根を使った和菓子やパイが富山県砺波市で販売されている"),
("スミレ", "2021年（令和3年）4月13日発売の94円普通切手の意匠である。"),
("フジ", "種子散布に関しては、乾燥すると鞘が二つに裂開し、それぞれがよじれることで種子を飛ばすが、この際の種子の飛ぶ力は大変なもので、当たって怪我をした人が実在するという。");





