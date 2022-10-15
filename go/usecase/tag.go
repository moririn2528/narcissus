package usecase

import "narcissus/errors"

type Tag struct {
	Id   int    `json:"id" db:"id"`
	Name string `json:"name" db:"name"`
}

func ListTag() ([]Tag, error) {
	tags, err := DbTag.ListTag()
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return tags, nil
}