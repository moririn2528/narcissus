package usecase

import (
	"context"
	"encoding/json"
	"log"
	"narcissus/errors"
	"net/http"
	"strconv"

	vision "cloud.google.com/go/vision/apiv1"
)

// 画像から植物名（英語）のリストに変換
func ListPlantName(img_path string) ([]string, error) {
	// 返り値
	var en_names []string
	// これなんだ？良く分からんけど呪文
	ctx := context.Background()

	// 画像をもとに様々な情報をwebからとってきてくれるクライアントを精製
	client, err := vision.NewImageAnnotatorClient(ctx)
	if err != nil {
		return nil, err
	}

	// 画像(のURL)から必要情報を取得
	image := vision.NewImageFromURI(img_path)
	web, err := client.DetectWeb(ctx, image, nil)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}

	for _, entity := range web.WebEntities {
		en_names = append(en_names, entity.Description)
		log.Println(len(en_names))
	}
	return TranslateAndJoin(en_names)
}

func TranslateAndJoin(identities []string) ([]string, error) {
	type TranslateResponse struct {
		Code int      `json:"code"`
		Text []string `json:"text"`
	}
	// urlを作成する
	url := "https://script.google.com/macros/s/AKfycby1cfY7nI4NRZuLNnjMTTdz8EXe7ThGxV5O3u27X64bH25sgQCrsjTFwhCTVqP6K0Bg/exec"
	request, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	params := request.URL.Query()
	params.Add("source", "en")
	params.Add("target", "ja")
	i := 0
	for {
		if i == 10 {
			break
		}
		if i >= len(identities) {
			params.Add("text"+strconv.Itoa(i), "empty")
		}
		params.Add("text"+strconv.Itoa(i), identities[i])
		i++
	}
	request.URL.RawQuery = params.Encode()

	// GETリクエスト
	client := &http.Client{}
	resp, err := client.Do(request)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}

	// データ読み込み
	var data TranslateResponse
	err = json.NewDecoder(resp.Body).Decode(&data)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	defer resp.Body.Close()
	var result []string
	for i, str := range identities {
		if i == 10 {
			break
		}
		if data.Code == 200 {
			result = append(result, data.Text[i])
		}
		result = append(result, str)
	}
	result, err = DbPlantTranslate.SearchPlantName(result)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	log.Print(result)
	var uniqueResult []string
	for i, str1 := range result {
		count := 0
		for _, str2 := range result[i:] {
			if str1 == str2 {
				count++
			}
		}
		if count == 1 {
			uniqueResult = append(uniqueResult, str1)
		}
	}
	log.Print(uniqueResult)
	return uniqueResult, nil
}
