package database

import (
	"narcissus/errors"
	"narcissus/usecase"

)



type DatabaseTag struct {
}

func (*DatabaseTag) ListTag() ([]usecase.Tag, error) {
	var tags []usecase.Tag
	err := db.Select(&tags, "SELECT id, name FROM tag")
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return tags, nil
}
