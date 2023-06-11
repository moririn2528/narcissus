package communicate

import (
	"net/http"
	"strconv"
	"strings"

	"narcissus/errors"
	"narcissus/usecase"
)

func getIdsFromForm(req *http.Request, key string) ([]int, error) {
	var list []int
	for _, s := range req.Form[key] {
		arr := strings.Split(s, ",")
		for _, v := range arr {
			id, err := strconv.Atoi(v)
			if err != nil {
				return nil, errors.NewError(http.StatusBadRequest, "invalid id in "+key+" : "+v)
			}
			list = append(list, id)
		}
	}
	return list, nil
}

func SearchPlant(w http.ResponseWriter, req *http.Request) error {
	var err error
	req.ParseForm()
	necessary_tags, err := getIdsFromForm(req, "necessary_tags")
	if err != nil {
		return errors.ErrorWrap(err)
	}
	optional_tags, err := getIdsFromForm(req, "optional_tags")
	if err != nil {
		return errors.ErrorWrap(err)
	}

	if err != nil {
		return errors.ErrorWrap(err)
	}
	// DBから植物情報（plants）取得
	plants, err := usecase.SearchPlant(req.Context(), necessary_tags, optional_tags)
	if err != nil {
		return errors.ErrorWrap(err)
	}

	var plants_url []usecase.PlantUrl

	for _, v := range plants {
		url := usecase.HashToUrl(v.Hash)
		plants_url = append(plants_url, usecase.PlantUrl{Plant: v.Plant, Url: url})
	}

	// hash -> url 変換済みplantsの型
	err = ResponseJson(w, plants_url)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}
