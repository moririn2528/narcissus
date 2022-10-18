package communicate

import (
	"log"
	"net/http"
	"strconv"

	"narcissus/errors"
	"narcissus/usecase"
)

type PostResult struct {
	IsNew bool `json:"isnew"`
	NewID int  `json:"newid"`
}

func postSnap(w http.ResponseWriter, req *http.Request) error {
	var err error

	// 受け取る部分(POST送信にするから全部変える)

	// 植物idを受け取る　これいる？
	/*var id int64 = -1
	id_str := req.FormValue("id")
	if id_str != "" {
		id, err = strconv.ParseInt(id_str, 10, 64)
		if err != nil {
			return errors.ErrorWrap(err)
		}
	}*/

	// 植物名と画像のhashを受け取る
	name := req.FormValue("name")
	hash := req.FormValue("hash")
	// 緯度経度を受け取る
	latitude, err := strconv.ParseFloat(req.FormValue("latitude"), 64)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	longitude, err := strconv.ParseFloat(req.FormValue("longitude"), 64)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	////////////////////////////////////////////////////////////////////////

	// 現時点では適当
	plantId := 1
	res := PostResult{IsNew: false, NewID: plantId}

	// データベースに投稿をInsertする
	post := usecase.Post{
		PlantId:   plantId,
		Name:      name,
		Hash:      hash,
		Latitude:  latitude,
		Longitude: longitude}
	err = usecase.InsertPost(post)

	if err != nil {
		return errors.ErrorWrap(err)
	}

	// JSONに変換して返す
	err = ResponseJson(w, res)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}

func PostHandle(w http.ResponseWriter, req *http.Request) {
	var err error
	switch req.Method {
	case "GET":
		err = postSnap(w, req)
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
