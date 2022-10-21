package usecase

import (
	"context"
	"encoding/json"
	"narcissus/errors"
	"net/http"

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
	}

	return TranslateAndJoin(en_names)
}

func TranslateAndJoin(identities []string) ([]string, error) {
	type TranslateResponse struct {
		Code int    `json:"code"`
		Text string `json:"text"`
	}

	url_first := "https://script.google.com/macros/s/AKfycbwjQnBPvRXdtzhF9glaepaN11iKXWztZhUefwzuCJtRSkq031gje88P_LSCvjDnr3VM/exec?text="
	url_second := "&source=en&target=ja"

	var result []string
	for _, str := range identities {
		url := url_first + str + url_second
		resp, err := http.Get(url)
		if err != nil {
			return nil, errors.ErrorWrap(err)
		}
		defer resp.Body.Close()
		var data TranslateResponse
		err = json.NewDecoder(resp.Body).Decode(&data)
		if err != nil {
			return nil, errors.ErrorWrap(err)
		}
		if data.Code == 200 {
			result = append(result, data.Text)
		}
		result = append(result, str)
	}
	return result, nil
}
