package database

import (
	"narcissus/errors"
	"narcissus/usecase"
	"strconv"
	"strings"

	"github.com/jmoiron/sqlx"
)

var (
	db *sqlx.DB
)

type DatabasePlant struct {
}

func (*DatabasePlant) ListPlant() ([]usecase.PlantHash, error) {
	var plants []usecase.PlantHash

	query_main := AddHashToQuery("SELECT id, name, detail FROM plant")
	err := db.Select(&plants, query_main)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return plants, nil
}

// タグをもとに植物を検索
// tagはtag_idのsliceが渡されることを想定している
func (*DatabasePlant) SearchPlant(necessary_tags []int, optional_tags []int) ([]usecase.PlantHash, error) {
	var plants []usecase.PlantHash

	// sql1:必須タグプラス、任意タグをどれか一つ以上含む植物：必須タグ and (任意タグ or 任意タグ or ................)
	// sql2:必須タグだけ含み、任意タグを含まない植物：必須タグ and (not 任意タグ and not 任意タグ and ................)
	// 返却したいもの：sql1 UNION sql2

	// つまり、
	// SELECT id, name, hash
	// FROM plant NATURAL JOIN (SELECT plant_id as id, tag_id FROM plant_tag WHERE tag_id IN (SELECT * FROM plant_tag WHERE tag_id = 必須タグid INTERSECT ..... ))
	// WHERE tag_id in optional_tags
	// UNION
	// SELECT id, name, hash
	// FROM plant NATURAL JOIN (SELECT plant_id as id, tag_id FROM plant_tag WHERE tag_id IN (SELECT * FROM plant_tag WHERE tag_id = 必須タグid INTERSECT ..... ))
	// (WHERE tag_id not in optional_tags) <= これは省略します。not処理は重いので。UNIONが重複削除してくれるので大丈夫ですたぶん。

	// 懸念点：必須タグをすべて含むかつ任意タグも含むレコードがUNIONより前のSQL、必須タグだけを含むレコードがUNIONより後ろに出てくることで
	// より条件にマッチしたものがsqlの戻り値の最初に来るようにしたつもりだが、
	// UNIONの挙動が分からないので、狙い通りの順番で出力されるか不明。

	// 必須タグをすべて含むplant_tagのレコード
	var plant_with_necessary string = ""

	// 任意タグを一つ以上含むplant_tagのレコード
	var plant_with_optional string = ""

	// 最終的に実行したSQLコード
	var plant_search_sql string = ""

	if len(necessary_tags) > 0 && len(optional_tags) > 0 {
		// 任意タグも必須タグも入力された場合
		for i, v := range necessary_tags {
			if len(necessary_tags) == i+1 {
				plant_with_necessary += "SELECT plant_id FROM plant_tag WHERE tag_id = " + strconv.Itoa(v)
			} else {
				plant_with_necessary += "SELECT plant_id FROM plant_tag WHERE tag_id = " + strconv.Itoa(v) + " INTERSECT "
			}
		}

		for i, v := range optional_tags {
			if len(optional_tags) == i+1 {
				plant_with_optional += strconv.Itoa(v)
			} else {
				plant_with_optional += strconv.Itoa(v) + ","
			}
		}

		plant_search_sql = "SELECT DISTINCT id, name, detail " +
			"FROM plant NATURAL JOIN (SELECT plant_id as id, tag_id FROM plant_tag WHERE plant_id IN (" + plant_with_necessary + ")) " +
			"WHERE tag_id IN " + "(" + plant_with_optional + ")" +
			" UNION " +
			"SELECT DISTINCT id, name, detail " +
			"FROM plant NATURAL JOIN (SELECT plant_id as id, tag_id FROM plant_tag WHERE plant_id IN (" + plant_with_necessary + "))"

	} else if len(necessary_tags) > 0 && len(optional_tags) == 0 {
		// 必須タグのみの入力
		for i, v := range necessary_tags {
			if len(necessary_tags) == i+1 {
				plant_with_necessary += "SELECT plant_id FROM plant_tag WHERE tag_id = " + strconv.Itoa(v)
			} else {
				plant_with_necessary += "SELECT plant_id FROM plant_tag WHERE tag_id = " + strconv.Itoa(v) + " INTERSECT "
			}
		}

		plant_search_sql = "SELECT DISTINCT id, name, detail " +
			"FROM plant NATURAL JOIN (SELECT plant_id as id, tag_id FROM plant_tag WHERE plant_id IN (" + plant_with_necessary + "))"

	} else if len(necessary_tags) == 0 && len(optional_tags) > 0 {
		// 任意タグだけの入力

		for i, v := range optional_tags {
			if len(optional_tags) == i+1 {
				plant_with_optional += strconv.Itoa(v)
			} else {
				plant_with_optional += strconv.Itoa(v) + ","
			}
		}

		plant_search_sql = "SELECT DISTINCT id, name, detail " +
			"FROM plant NATURAL JOIN (SELECT plant_id AS id, tag_id FROM plant_tag) " +
			"WHERE tag_id in (" + plant_with_optional + ")"

	} else {
		plant_search_sql = "SELECT DISTINCT id, name, detail FROM plant"
	}
	plant_search_sql = AddHashToQuery(plant_search_sql)
	err := db.Select(&plants, plant_search_sql)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return plants, nil
}

// plantのidを含む結果が返ってくるクエリにhashを付け足す関数
// hashはその植物IDに関する投稿のうち、最も新しいもののhash
func AddHashToQuery(query string) string {
	var query_main string = ""
	var subquery_Id_Hash string = ""
	var subquery_Id_NewDate string = ""
	var subquery_MaxHash string = ""

	query = "(" + query + ")"
	// 植物IDと作成日ごとにhashの最大値を取得
	// 作成日が被ったときに複数返ってくるのを防ぐためのもの
	subquery_MaxHash += "SELECT plant_id, MAX(hash) AS hash, created_at" + " "
	subquery_MaxHash += "FROM upload_post" + " "
	subquery_MaxHash += "GROUP BY plant_id, created_at"
	subquery_MaxHash = "(" + subquery_MaxHash + ")"

	// 植物IDごとの最も新しい投稿日時を求める
	subquery_Id_NewDate += "SELECT plant_id, MAX(created_at) AS created_at" + " "
	subquery_Id_NewDate += "FROM upload_post" + " "
	subquery_Id_NewDate += "GROUP BY plant_id"
	subquery_Id_NewDate = "(" + subquery_Id_NewDate + ")"

	// 植物IDごとのhashを求める
	subquery_Id_Hash += "SELECT plant_id AS id, hash" + " "
	subquery_Id_Hash += "FROM " + subquery_MaxHash + " NATURAL JOIN " + subquery_Id_NewDate
	subquery_Id_Hash = "(" + subquery_Id_Hash + ")"

	// hashをくっつける
	query_main += "SELECT DISTINCT *" + " "
	query_main += "FROM " + query + " NATURAL JOIN " + subquery_Id_Hash

	return query_main
}

// 植物データを挿入する
// 返り値は, (挿入できたか, 新ID, error)
func (*DatabasePlant) InsertPlant(name string) (int, error) {
	// 新しいデータとして挿入する
	var plant usecase.Plant = usecase.Plant{
		Id:     -1,
		Name:   name,
		Detail: "",
	}
	query := "INSERT INTO plant(name, detail, rarity) VALUES (:name, :detail, 0)"
	res, err := db.NamedExec(query, &plant)
	if err != nil {
		return -1, errors.ErrorWrap(err)
	}
	newId, err := res.LastInsertId()
	if err != nil {
		return -1, errors.ErrorWrap(err)
	}

	return int(newId), nil
}

// 名前から植物が存在するかをチェックする
// 返り値: (存在するか, そのid, error)
func (*DatabasePlant) IsPlantExist(name string) (bool, int, error) {
	// 英語名から日本語名に変換する 暫定処理
	// query := "SELECT name FROM plant_names WHERE name = " + strconv.Quote(name)
	// plantテーブルにあるかチェックする
	var plants []usecase.Plant
	query := "SELECT id FROM plant WHERE name = " + strconv.Quote(name)
	err := db.Select(&plants, query)
	if err != nil {
		return false, -1, "", errors.ErrorWrap(err)
	}

	isExist := len(plants) > 0
	plantId := -1
	if isExist {
		plantId = plants[0].Id
	}
	return isExist, plantId, "", nil
}

// 植物idとタグ名のスライスを渡すと、該当する植物にタグを追加する
// isAddTagがtrueなら、その植物に無い新しいタグも追加する
func (*DatabasePlant) SetTagsToPlant(id int, tagNames []string) error {
	if len(tagNames) == 0 {
		return nil
	}

	var tags []usecase.Tag
	query_main := ""

	// 各タグ名に一致するタグ情報を取ってくる
	var quote_names []string
	for _, t := range tagNames {
		quote_names = append(quote_names, strconv.Quote(t))
	}
	query_main += "SELECT * FROM tag WHERE name IN (" + strings.Join(quote_names, ",") + ")"

	err := db.Select(&tags, query_main)
	if err != nil {
		return errors.ErrorWrap(err)
	}

	// 植物idとタグidの結びつけを登録
	type TagAndPlantID struct {
		PlantId int `db:"plant_id"`
		TagId   int `db:"tag_id"`
	}
	var values []TagAndPlantID
	query_main = "INSERT INTO plant_tag(plant_id, tag_id) VALUES (:plant_id, :tag_id)"
	query_main += " ON CONFLICT(plant_id, tag_id) DO NOTHING"
	for _, t := range tags {
		values = append(values, TagAndPlantID{
			PlantId: id,
			TagId:   t.Id})
	}
	_, err = db.NamedExec(query_main, values)
	if err != nil {
		return errors.ErrorWrap(err)
	}

	return nil
}
