package database

import (
	"narcissus/errors"
	"narcissus/usecase"
	"strconv"
)

type DatabaseUploadPost struct {
}

func (*DatabaseUploadPost) InsertUploadPost(uploadPost usecase.UploadPost) error {

	query := "INSERT INTO upload_post(plant_id, latitude, longitude, hash) VALUES ("
	query += strconv.Itoa(uploadPost.PlantId) + ","
	query += strconv.FormatFloat(uploadPost.Latitude, 'f', -1, 64) + ","
	query += strconv.FormatFloat(uploadPost.Longitude, 'f', -1, 64) + ","
	query += strconv.Quote(uploadPost.Hash)
	query += ")"

	_, err := db.Exec(query)

	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}
