package usecase

import (
	"context"
	"narcissus/errors"
)

type Tag struct {
	Id   int    `json:"id" firestore:"id"`
	Name string `json:"name" firestore:"name"`
}

func ListTag(ctx context.Context) ([]Tag, error) {
	tags, err := DbTag.ListTag(ctx)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return tags, nil
}
