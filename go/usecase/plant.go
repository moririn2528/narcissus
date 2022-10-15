package usecase

import "narcissus/errors"

type Plant struct {
	Id   int    `json:"id" db:"id"`
	Name string `json:"name" db:"name"`
	Hash string `json:"hash" db:"hash"`
}

func ListPlant() ([]Plant, error) {
	plants, err := DbPlant.ListPlant()
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return plants, nil
}

// tagを指定すると、該当する植物を返してくれる関数
// tagは必須で含むべきものと、任意で含むべきものの2種類で指定できる
func SearchPlant(necessary_tags []int, optional_tags []int) ([]Plant, error) {
	plants, err := DbPlant.SearchPlant(necessary_tags, optional_tags)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return plants, nil
}
