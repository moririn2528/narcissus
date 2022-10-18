package usecase

import "narcissus/errors"

type UploadPost struct { //json,dbの部分いらないかも
	PlantId   int     `json:"plant_id" db:"plant_id"`
	Name      string  `json:"name" db:"name"`
	Hash      string  `json:"hash" db:"hash"`
	Latitude  float64 `json:"latitude" db:"latitude"`
	Longitude float64 `json:"longitude" db:"longitude"`
}

func InsertUploadPost(uploadPost UploadPost) error {
	err := DbUploadPost.InsertUploadPost(uploadPost)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}
