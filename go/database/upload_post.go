package database

import (
	"narcissus/errors"
	"narcissus/usecase"
)

type DatabaseUploadPost struct {
}

func (*DatabaseUploadPost) InsertUploadPost(uploadPost usecase.UploadPost) error {
	// 投稿をDBに挿入
	query := "INSERT INTO upload_post(plant_id, latitude, longitude, hash) VALUES (:plant_id,:latitude,:longitude,:hash)"
	_, err := db.NamedExec(query, &uploadPost)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}
