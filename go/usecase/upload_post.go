package usecase

import (
	"context"
	"math/rand"
	"narcissus/errors"
	"time"
)

type UploadPost struct {
	PlantId   int      `json:"plant_id"`
	Name      string   `json:"name"`
	Latitude  float64  `json:"latitude"`
	Longitude float64  `json:"longitude"`
	Hash      string   `json:"hash"`
	Tags      []string `json:"tags"`
}

func InsertUploadPost(ctx context.Context, uploadPost UploadPost) error {
	var err error

	_, newId, err := JudgeAndInsert(ctx, uploadPost.Name)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	// タグを追加する(あれば)
	if len(uploadPost.Tags) > 0 {
		err = SetTagsToPlant(ctx, newId, uploadPost.Tags)
		if err != nil {
			return errors.ErrorWrap(err)
		}
	}
	uploadPost.PlantId = newId
	// database層に渡す
	err = DbUploadPost.InsertUploadPost(ctx, uploadPost)
	if err != nil {
		return errors.ErrorWrap(err)
	}

	return nil
}

// 被らないファイル名を生成するための関数
// Flutter側でやるのでいずれ消す
func UniqueString() string {
	str := "Img"

	t := time.Now()
	layout := "20060102150405"
	t_str := t.Format(layout)
	str += t_str

	var letter = []rune("abcdefghijklmnopqrstuvwxyz")
	r := make([]rune, 10)
	rand.Seed(time.Now().UnixNano())
	for i := range r {
		r[i] = letter[rand.Intn(len(letter))]
	}
	str += string(r)
	return str
}
