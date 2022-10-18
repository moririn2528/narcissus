package communicate

import (
	//"encoding/base64"

	"encoding/base64"
	"encoding/json"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strings"
	"time"

	//"os"

	"narcissus/errors"
	"narcissus/usecase"
)

type PostResult struct {
	IsNew bool `json:"isnew"`
	NewID int  `json:"newid"`
}

func insertPost(w http.ResponseWriter, req *http.Request) error {
	var err error

	// GETで受け取る部分(POST送信にするから全部変える)////////////////////////////////

	// 植物idを受け取る　これいらないかも
	/*var id int64 = -1
	id_str := req.FormValue("id")
	if id_str != "" {
		id, err = strconv.ParseInt(id_str, 10, 64)
		if err != nil {
			return errors.ErrorWrap(err)
		}
	}

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
	// タグをありったけ受け取る
	var index int = 1
	var tags []string
	for {
		tag := req.FormValue("tag" + strconv.Itoa(index))
		if tag == "" {
			break
		}
		tags = append(tags, tag)
		index++
	}*/
	////////////////////////////////////////////////////////////////////////

	// POSTでJSONを受け取るための構造体
	type ReceivedTag struct {
		Name string `json:"name"`
	}
	type ReceivedData struct {
		Name      string        `json:"name"`
		Latitude  float64       `json:"latitude"`
		Longitude float64       `json:"longitude"`
		Image     string        `json:"image"`
		Tags      []ReceivedTag `json:"tags"`
	}
	// 受け取ったJSONをデコード
	var data ReceivedData
	err = json.NewDecoder(req.Body).Decode(&data)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	// 各データを受け取る
	name := data.Name
	latitude := data.Latitude
	longitude := data.Longitude
	img64 := data.Image
	var tags []string
	for _, rt := range data.Tags {
		tags = append(tags, rt.Name)
	}

	// hashを決定する
	// ファイル名をかぶらないようにしたい Img+年月日時分秒ミリ秒+ランダムアルファベット10字
	hash := UniqueString()

	// 画像をアップロードする
	fileName := hash + ".png"
	file, _ := os.Create("figure/" + fileName)
	defer file.Close()
	imgData, _ := base64.StdEncoding.DecodeString(img64)
	file.Write(imgData)

	// 植物データをDBに登録する(存在していたらしない)
	plant := usecase.Plant{
		Id:   -1, // Idは不明なので負にしておく
		Name: name,
		Hash: hash}
	isNew, plantId, err := usecase.InsertPlant(plant)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	res := PostResult{IsNew: isNew, NewID: plantId}

	// タグを追加する
	// 新しい植物にのみタグを付けたければisNewの場合にすれば良い
	err = usecase.SetTagsToPlant(plantId, tags)
	if err != nil {
		return errors.ErrorWrap(err)
	}

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

	// 簡単な結果をJSONに変換して返す
	err = ResponseJson(w, res)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}

func PostHandle(w http.ResponseWriter, req *http.Request) {
	var err error
	switch req.Method {
	case "POST":
		err = insertPost(w, req)
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

func UniqueString() string {
	str := "Img"

	t := time.Now()
	layout := "2006-01-02 15:04:05"
	t_str := t.Format(layout)
	t_str = strings.Replace(t_str, "-", "", -1)
	t_str = strings.Replace(t_str, ":", "", -1)
	t_str = strings.Replace(t_str, " ", "", -1)
	str += t_str

	var letter = []rune("abcdefghijklmnopqrstuvwxyz")
	r := make([]rune, 10)
	rand.Seed(time.Now().UnixNano())
	for i := range r {
		r[i] = letter[rand.Intn(len(letter))]
	}
	str += string(r)
	return str
}
