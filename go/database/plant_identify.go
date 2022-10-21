package database

import (
	"fmt"
	"narcissus/errors"
	"strings"
)

type DatabasePlantTranslate struct {
}

func (*DatabasePlantTranslate) SearchPlantName(identities []string) ([]string, error) {
	var err error

	query := ""
	query += "SELECT name FROM plant WHERE name IN (\""
	query += strings.Join(identities, "\",\"")
	query += "\")"

	type ExistPlant struct {
		Name string `db:"name"`
	}
	var exists []ExistPlant
	var noexists []string
	var result []string
	err = db.Select(&exists, query)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}

	for _, str := range identities {
		isExist := false
		for _, ex := range exists {
			if str == ex.Name {
				isExist = true
				break
			}
		}
		if isExist {
			result = append(result, str)
		} else {
			noexists = append(noexists, str)
		}
	}
	result = append(result, noexists...)

	return result, nil
}

func (*DatabasePlantTranslate) PlantTranslate(en_names []string) ([]string, error) {
	var jp_names []string

	// en_namesからsqlを作成
	sql := "("
	for id, name := range en_names {
		if id < len(en_names)-1 {
			sql = sql + "\"" + name + "\", "
		} else {
			sql = sql + "\"" + name + "\");"
		}
	}

	err := db.Select(&jp_names, "SELECT jp_name FROM plant_translate WHERE en_name in "+sql)
	if err != nil {
		fmt.Println(err)
		return nil, errors.ErrorWrap(err)
	}
	return jp_names, nil
}
