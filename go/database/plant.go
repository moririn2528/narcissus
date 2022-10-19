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

func (*DatabasePlant) ListPlant() ([]usecase.Plant, error) {
	var plants []usecase.Plant
	err := db.Select(&plants, "SELECT id, name, hash FROM plant")
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return plants, nil
}

// タグをもとに植物を検索
// tagはtag_idのsliceが渡されることを想定している
func (*DatabasePlant) SearchPlant(necessary_tags []int, optional_tags []int) ([]usecase.Plant, error) {
	var plants []usecase.Plant

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
	var plant_search_sql string = "["

	if len(necessary_tags) > 0 && len(optional_tags) > 0 {
		// 任意タグも必須タグも入力された場合
		for i, v := range necessary_tags {
			if len(necessary_tags) == i+1 {
				plant_with_necessary += "SELECT * FROM plant_tag WHERE tag_id = " + strconv.Itoa(v)
			} else {
				plant_with_necessary += "SELECT * FROM plant_tag WHERE tag_id = " + strconv.Itoa(v) + " INTERSECT "
			}
		}

		for i, v := range optional_tags {
			if len(optional_tags) == i+1 {
				plant_with_optional += "\"" + strconv.Itoa(v) + "\"]"
			} else {
				plant_with_optional += "\"" + strconv.Itoa(v) + "\", "
			}
		}

		plant_search_sql = "(SELECT id, name, hash" +
			"FROM plant NATURAL JOIN (SELECT plant_id as id, tag_id FROM plant_tag WHERE tag_id IN (" + plant_with_necessary + "))" +
			"WHERE tag_id in " + plant_with_optional + ")" +
			"UNION" +
			"(SELECT id, name, hash" +
			"FROM plant NATURAL JOIN (SELECT plant_id as id, tag_id FROM plant_tag WHERE tag_id IN (" + plant_with_necessary + "))" + ")"

	} else if len(necessary_tags) > 0 && len(optional_tags) == 0 {
		// 必須タグのみの入力
		for i, v := range necessary_tags {
			if len(necessary_tags) == i+1 {
				plant_with_necessary += "SELECT * FROM plant_tag WHERE tag_id = " + strconv.Itoa(v)
			} else {
				plant_with_necessary += "SELECT * FROM plant_tag WHERE tag_id = " + strconv.Itoa(v) + " INTERSECT "
			}
		}

		plant_search_sql = "(SELECT id, name, hash" +
			"FROM plant NATURAL JOIN (SELECT plant_id as id, tag_id FROM plant_tag WHERE tag_id IN (" + plant_with_necessary + "))" + ")"

	} else if len(necessary_tags) == 0 && len(optional_tags) > 0 {
		// 任意タグだけの入力

		for i, v := range optional_tags {
			if len(optional_tags) == i+1 {
				plant_with_optional += "\"" + strconv.Itoa(v) + "\"]"
			} else {
				plant_with_optional += "\"" + strconv.Itoa(v) + "\", "
			}
		}

		plant_search_sql = "(SELECT id, name, hash" +
			"FROM plant, plant_tag" +
			"WHERE tag_id in " + plant_with_optional + ")"

	} else {
		plant_search_sql = "SELECT id, name, hash FROM plant"
	}

	err := db.Select(&plants, plant_search_sql)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return plants, nil
}

// 植物データを挿入する
// 返り値は, (挿入できたか, 新ID, error)
func (*DatabasePlant) InsertPlant(plant usecase.Plant) (bool, int, error) {

	// nameが一致する植物が存在するかチェック
	isExist, id, err := IsPlantExist(plant.Name)
	if err != nil {
		return true, -1, errors.ErrorWrap(err)
	}

	// 存在する場合はそのidを返す
	if isExist {
		return false, id, nil
	}

	// 新しいデータとして挿入する
	query := "INSERT INTO plant(name, hash, rarity) VALUES (:name,:hash,0)"
	res, err := db.NamedExec(query, &plant)
	if err != nil {
		return true, -1, errors.ErrorWrap(err)
	}
	newId, err := res.LastInsertId()
	if err != nil {
		return true, -1, errors.ErrorWrap(err)
	}

	return true, int(newId), nil
}

// 名前から植物が存在するかをチェックする
// 返り値: (存在するか, そのid, error)
func IsPlantExist(name string) (bool, int, error) {
	var plants []usecase.Plant
	query := "SELECT id FROM plant WHERE name = " + strconv.Quote(name)
	err := db.Select(&plants, query)
	if err != nil {
		return false, -1, errors.ErrorWrap(err)
	}

	isExist := len(plants) > 0
	plantId := -1
	if isExist {
		plantId = plants[0].Id
	}
	return isExist, plantId, nil
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
