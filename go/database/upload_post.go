package database

import (
	"narcissus/errors"
	"narcissus/usecase"
)

type DatabaseUploadPost struct {
}

func (*DatabaseUploadPost) InsertUploadPost(tags []string, uploadPost usecase.UploadPost) (usecase.UploadPostResponse, error) {

	query := "INSERT INTO upload_post(plant_id, latitude, longitude, hash) VALUES (:plant_id,:latitude,:longitude,:hash)"
	_, err := db.NamedExec(query, &uploadPost)

	if err != nil {
		return usecase.UploadPostResponse{}, errors.ErrorWrap(err)
	}
	return usecase.UploadPostResponse{}, nil
}
