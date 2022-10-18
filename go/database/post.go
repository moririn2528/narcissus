package database

import (
	"narcissus/errors"
	"narcissus/usecase"
	"strconv"
)

type DatabasePost struct {
}

func (*DatabasePost) InsertPost(post usecase.Post) error {

	query := "INSERT INTO post(plant_id, latitude, longitude, hash) VALUES ("
	query += strconv.Itoa(post.PlantId) + ","
	query += strconv.FormatFloat(post.Latitude, 'f', -1, 64) + ","
	query += strconv.FormatFloat(post.Longitude, 'f', -1, 64) + ","
	query += strconv.Quote(post.Hash)
	query += ")"

	_, err := db.Exec(query)

	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}
