package usecase

import "narcissus/errors"

type Near struct {
	Id        int     `json:"id" db:"id"`
	Name      string  `json:"name" db:"name"`
	Hash      string  `json:"hash" db:"hash"`
	Latitude  float64 `json:"latitude" db:"latitude"`
	Longitude float64 `json:"longitude" db:"longitude"`
}

func ListNear(latitude float64, longitude float64, length float64) ([]Near, error) {
	nears, err := DbNear.ListNear(latitude, longitude, length)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return nears, nil
}
