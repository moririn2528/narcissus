package database

import (
	"narcissus/errors"
)

type PlantTranslate struct {
}

func (*PlantTranslate) PlantTranslate(en_names []string) ([]string, error) {
	var jp_names []string

	// en_namesからsqlを作成
	sql := "("
	for id, name := range en_names {
		if id < len(en_names)-1 {
			sql = sql + name + ","
		} else {
			sql = sql + name + ")"
		}
	}

	err := db.Select(&jp_names, "SELECT jp_name FROM plant_translate WHERE en_name in "+sql)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return jp_names, nil
}
