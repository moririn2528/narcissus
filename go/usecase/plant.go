package usecase

import (
	"context"
	"narcissus/errors"
)

type Plant struct {
	Id     int    `json:"id" firestore:"id"`
	Name   string `json:"name" firestore:"name"`
	Detail string `json:"detail" firestore:"detail"`
}
type PlantHash struct {
	Plant
	Hash string `firestore:"hash"`
}
type PlantUrl struct {
	Plant
	Url string `json:"url"`
}

func ListPlant(ctx context.Context) ([]PlantHash, error) {
	plants, err := DbPlant.ListPlant(ctx)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}

	return plants, nil
}

// tagを指定すると、該当する植物を返してくれる関数
// tagは必須で含むべきものと、任意で含むべきものの2種類で指定できる
func SearchPlant(ctx context.Context, necessary_tags []int, optional_tags []int) ([]PlantHash, error) {
	plants, err := DbPlant.SearchPlant(ctx, necessary_tags, optional_tags)
	if err != nil {
		return nil, errors.ErrorWrap(err)
	}
	return plants, nil
}

func JudgeAndInsert(ctx context.Context, name string) (bool, int, error) {
	isExist, id, err := IsPlantExist(ctx, name)
	if err != nil {
		return false, -1, errors.ErrorWrap(err)
	}
	if isExist {
		return false, id, nil
	}
	newId, err := InsertPlant(ctx, name)
	if err != nil {
		return false, -1, errors.ErrorWrap(err)
	}
	return true, newId, nil
}

// 植物名を渡すと新たに追加してくれる
// 返り値は (登録後のid, error)
func InsertPlant(ctx context.Context, name string) (int, error) {
	newId, err := DbPlant.InsertPlant(ctx, name)
	if err != nil {
		return -1, errors.ErrorWrap(err)
	}
	return newId, nil
}

// 植物名を渡すと存在するかどうかを返す
// 返り値は (存在するかどうか, するならそのid, error)
func IsPlantExist(ctx context.Context, name string) (bool, int, error) {
	isExist, id, err := DbPlant.IsPlantExist(ctx, name)
	if err != nil {
		return false, -1, errors.ErrorWrap(err)
	}
	return isExist, id, nil
}

// 植物idとタグ名のスライスを渡すと、該当する植物にタグを追加する
// isAddTagがtrueなら、存在しないタグを新たにtagテーブルに追加する
func SetTagsToPlant(ctx context.Context, id int, tags []string) error {
	err := DbPlant.SetTagsToPlant(ctx, id, tags)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}

func HashToUrl(hash string) string {
	//TODO 画像の保存先とか拡張子が決まったら変更する
	return "https://storage.googleapis.com/narcissus-364913.appspot.com/upload-figure/" + hash + ".jpg"
}
