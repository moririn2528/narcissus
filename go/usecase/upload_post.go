package usecase

import (
	"encoding/base64"
	"math/rand"
	"narcissus/errors"
	"os"
	"time"
)

type UploadPostRequest struct {
	Name      string   `json:"name"`
	Latitude  float64  `json:"latitude"`
	Longitude float64  `json:"longitude"`
	Image     string   `json:"image"`
	Tags      []string `json:"tags"`
}

type UploadPostResponse struct {
	IsNewPlant bool `json:"is_new_plant"`
}

type UploadPost struct { //json,dbの部分いらないかも
	PlantId   int     `json:"plant_id" db:"plant_id"`
	Name      string  `json:"name" db:"name"`
	Hash      string  `json:"hash" db:"hash"`
	Latitude  float64 `json:"latitude" db:"latitude"`
	Longitude float64 `json:"longitude" db:"longitude"`
}

func InsertUploadPost(req UploadPostRequest, uploadPost UploadPost) (UploadPostResponse, error) {
	name := uploadPost.Name
	img64 := req.Image
	tags := req.Tags

	// hashを決定する
	// ファイル名をかぶらないようにしたい Img+年月日時分秒+ランダムアルファベット10字
	hash := UniqueString()

	// 画像をアップロードする
	fileName := hash + ".png"
	file, _ := os.Create("figure/" + fileName)
	defer file.Close()
	imgData, _ := base64.StdEncoding.DecodeString(img64)
	file.Write(imgData)

	// 植物データをDBに登録する(存在していたらしない)
	plant := Plant{Id: -1, Name: name, Hash: hash}
	isNewPlant, plantId, err := InsertPlant(plant)
	if err != nil {
		return UploadPostResponse{}, errors.ErrorWrap(err)
	}

	// タグを追加する
	// 新しい植物にのみタグを付けたければisNewの場合にすれば良い
	err = SetTagsToPlant(plantId, tags)
	if err != nil {
		return UploadPostResponse{}, errors.ErrorWrap(err)
	}

	// データベースに投稿をInsertする
	uploadPost.Hash = hash
	uploadPost.PlantId = plantId
	_, err = DbUploadPost.InsertUploadPost(req, uploadPost)
	if err != nil {
		return UploadPostResponse{}, errors.ErrorWrap(err)
	}

	//結果を返す
	res := UploadPostResponse{IsNewPlant: isNewPlant}
	return res, nil
}

// 被らないファイル名を生成するための関数
// Flutter側でやるのでいずれ消す
func UniqueString() string {
	str := "Img"

	t := time.Now()
	layout := "20060102150405"
	t_str := t.Format(layout)
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
