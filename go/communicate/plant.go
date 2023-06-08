package communicate

import (
	"log"
	"net/http"

	"narcissus/errors"
	"narcissus/usecase"
)

func listPlant(w http.ResponseWriter, req *http.Request) error {
	var err error
	// DBから植物情報（plants）取得
	plants, err := usecase.ListPlant(req.Context())
	if err != nil {
		return errors.ErrorWrap(err)
	}
	// plantsは送信時にhashをurlに変換
	// メモ
	// 構造体の使い方：https://golang.hateblo.jp/entry/golang-how-to-use-struct
	// スライスの使い方：https://qiita.com/k-penguin-sato/items/daad9986d6c42bdcde90

	var plants_url []usecase.PlantUrl

	for _, v := range plants {
		url := usecase.HashToUrl(v.Hash)
		plants_url = append(plants_url, usecase.PlantUrl{
			Plant: v.Plant,
			Url:   url,
		})
	}

	// hash -> url 変換済みplantsの型
	err = ResponseJson(w, plants_url)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}

func PlantHandle(w http.ResponseWriter, req *http.Request) {
	var err error
	switch req.Method {
	case "GET":
		err = listPlant(w, req)
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
