package communicate

import (
	"encoding/json"
	"log"
	"net/http"

	"narcissus/errors"
	"narcissus/usecase"
)

func searchPlant(w http.ResponseWriter, req *http.Request) error {
	var err error
	type SearchRequest struct {
		Necessary_tags []int `json:"necessary_tags"`
		Optional_tags  []int `json:"optional_tags"`
	}

	var data SearchRequest
	err = json.NewDecoder(req.Body).Decode(&data)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	// DBから植物情報（plants）取得
	plants, err := usecase.SearchPlant(data.Necessary_tags, data.Optional_tags)
	if err != nil {
		return errors.ErrorWrap(err)
	}

	var plants_url []usecase.PlantUrl

	for _, v := range plants {
		url := usecase.HashToUrl(v.Hash)
		plants_url = append(plants_url, usecase.PlantUrl{Id: v.Id, Name: v.Name, Url: url})
	}

	// hash -> url 変換済みplantsの型
	err = ResponseJson(w, plants_url)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}

func SearchHandle(w http.ResponseWriter, req *http.Request) {
	var err error
	switch req.Method {
	case "POST":
		err = searchPlant(w, req)
	default:
		w.WriteHeader(http.StatusNotFound)
		return
	}
	if err == nil {
		return
	}
	my_err, ok := err.(*errors.MyError)
	if !ok {
		w.WriteHeader(http.StatusInternalServerError)
		log.Print("wrap error")
		return
	}
	w.WriteHeader(my_err.GetCode())
	log.Print(my_err.Error())
}
