package usecase

import (
	"context"
	"fmt"
	"narcissus/errors"
	"os"

	vision "cloud.google.com/go/vision/apiv1"
)

// type Near struct {
// 	Id        int     `json:"id" db:"id"`
// 	Name      string  `json:"name" db:"name"`
// 	Hash      string  `json:"hash" db:"hash"`
// 	Latitude  float64 `json:"latitude" db:"latitude"`
// 	Longitude float64 `json:"longitude" db:"longitude"`
// }

// URLから植物名（日本語）のリストに変換
func GetPlantIdentify(img_path string) ([]string, error) {
	// 英語で植物の情報をwebからとってくる
	en_plant_names, err := listPlantName(img_path)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	fmt.Println("English plant names were found successfully")

	// 英語を日本語に翻訳
	plant_names, err := translatePlantName(en_plant_names)
	return plant_names, nil
}

// 画像から植物名（英語）のリストに変換
func listPlantName(img_path string) ([]string, error) {
	// 返り値
	var en_names []string
	// これなんだ？良く分からんけど呪文
	ctx := context.Background()

	// 画像をもとに様々な情報をwebからとってきてくれるクライアントを精製
	client, err := vision.NewImageAnnotatorClient(ctx)
	if err != nil {
		return nil, err
	}

	// 画像ファイルを開きましょう
	f, err := os.Open(img_path)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	// さっき開いたファイルを読み込む
	image, err := vision.NewImageFromReader(f)
	if err != nil {
		return nil, err
	}

	// 画像から必要情報を取得
	web, err := client.DetectWeb(ctx, image, nil)
	if err != nil {
		return nil, err
	}

	if len(web.WebEntities) != 0 {
		for _, entity := range web.WebEntities {
			// 返り値にEntity名を追加
			fmt.Println(entity.Description)
			en_names = append(en_names, entity.Description)
		}
	}
	fmt.Println(en_names, err)

	return en_names, nil
}

// 植物名のリスト（英語）から植物名のリスト（日本語）に変換
func translatePlantName(en_names []string) ([]string, error) {
	var err error
	translated_names, err := DbPlantTranslate.PlantTranslate(en_names)
	if translated_names == nil {
		return nil, errors.ErrorWrap(err)
	}

	print("translated_names", translated_names, err)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return translated_names, nil
}
