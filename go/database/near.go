package database

import (
	"narcissus/errors"
	"narcissus/usecase"

	"strconv"
)

type DatabaseNear struct {
}

func (*DatabaseNear) ListNear(latitude float64, longitude float64, length float64) ([]usecase.Near, error) {
	var nears []usecase.Near

	// SQLのクエリ
	var query_main string = ""
	var subquery_uploadpost string = ""
	var subquery_plant string = ""
	var proposition string = ""
	var prop_latitude string = ""
	var prop_longitude string = ""

	// 取ってくる縦横の範囲(単位:m)を
	// 緯度経度の尺度に変換するための値
	var rate float64 = 360.0 / 40075000.0
	length *= rate / 2

	// 緯度経度の範囲
	var latitude_min float64 = latitude - length
	var latitude_max float64 = latitude + length
	var longitude_min float64 = longitude - length
	var longitude_max float64 = longitude + length

	// クエリの緯度経度の条件の部分
	prop_latitude += "latitude >= " + strconv.FormatFloat(latitude_min, 'f', -1, 64)
	prop_latitude += " AND "
	prop_latitude += "latitude <= " + strconv.FormatFloat(latitude_max, 'f', -1, 64)
	prop_longitude += "longitude >= " + strconv.FormatFloat(longitude_min, 'f', -1, 64)
	prop_longitude += " AND "
	prop_longitude += "longitude <= " + strconv.FormatFloat(longitude_max, 'f', -1, 64)
	proposition += prop_latitude + " AND " + prop_longitude

	// クエリの投稿情報の部分
	subquery_uploadpost += "SELECT plant_id AS id, hash, latitude, longitude "
	subquery_uploadpost += "FROM upload_post WHERE " + proposition
	subquery_uploadpost = "(" + subquery_uploadpost + ")"

	// クエリの植物情報の部分
	subquery_plant += "SELECT id, name FROM plant"
	subquery_plant = "(" + subquery_plant + ")"

	// 最終的なクエリ
	query_main += "SELECT id, name, hash, latitude, longitude "
	query_main += "FROM " + subquery_uploadpost + " NATURAL JOIN " + subquery_plant
	err := db.Select(&nears, query_main)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return nears, nil
}
