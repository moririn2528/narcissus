package communicate

import (
	"encoding/json"
	"log"
	"net/http"

	"narcissus/errors"
	"narcissus/usecase"
)

func insertUploadPost(w http.ResponseWriter, req *http.Request) error {
	var err error

	// 受け取ったJSONをデコード
	var data usecase.UploadPostRequest
	err = json.NewDecoder(req.Body).Decode(&data)
	if err != nil {
		return errors.ErrorWrap(err)
	}

	upload_post := usecase.UploadPost{
		PlantId:   -1,
		Name:      data.Name,
		Hash:      data.Hash,
		Latitude:  data.Latitude,
		Longitude: data.Longitude}

	// 結果を受け取ってJSONで返す
	res, err := usecase.InsertUploadPost(data.Tags, upload_post)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	err = ResponseJson(w, res)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}

func UploadPostHandle(w http.ResponseWriter, req *http.Request) {
	var err error
	switch req.Method {
	case "POST":
		err = insertUploadPost(w, req)
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
