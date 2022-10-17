package nosql

import (
	"context"
	"math/rand"
	"narcissus/errors"
	"narcissus/usecase"
	"strconv"

	"cloud.google.com/go/firestore"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type DatabasePlant struct {
}

type Plant struct {
	Id     int    `firestore:"id"`
	Name   string `firestore:"name"`
	Detail string `firestore:"detail"`
	Rarity int    `firestore:"rarity"`
	Hash   string `firestore:"hash"`
}

func (*DatabasePlant) ListPlant(ctx context.Context) ([]usecase.PlantHash, error) {
	var plants []usecase.PlantHash
	itr := client.Collection("plant").Documents(ctx)
	for {
		doc, err := itr.Next()
		if err != nil {
			break
		}
		var plant Plant
		doc.DataTo(&plant)
		if plant.Hash == "" {
			continue
		}
		plants = append(plants, usecase.PlantHash{
			Plant: usecase.Plant{
				Id:     plant.Id,
				Name:   plant.Name,
				Detail: plant.Detail,
			},
			Hash: plant.Hash,
		})
	}
	return plants, nil
}

type PlantTag struct {
	Id int `firestore:"id"`
}

// タグをもとに植物を検索
// tagはtag_idのsliceが渡されることを想定している
// 合計30個以上渡すとエラー
// 必須タグプラス、任意タグをどれか一つ以上含む植物：必須タグ and (任意タグ or 任意タグ or ................)
// 検索結果が 30 個以上の場合は上から 30 個選ぶ // FIXME: pagination
// FIXME: tags を plant のサブコレクションにしたい
func (*DatabasePlant) SearchPlant(ctx context.Context, necessary_tags []int, optional_tags []int) ([]usecase.PlantHash, error) {
	const MAX_TAGS int = 30
	if len(necessary_tags)+len(optional_tags) > MAX_TAGS {
		logger.Error("too many tags")
		return nil, errors.ErrorWrap(errors.NewError("too many tags"))
	}

	var plants []usecase.PlantHash
	var tags []int
	plant_tag := map[string][]int{}

	tags = append(tags, necessary_tags...)
	tags = append(tags, optional_tags...)

	// とりあえず necessary_tags と optional_tags に含まれるタグを持つ植物を取得
	itr := client.CollectionGroup("tags").Where("id", "in", tags).Documents(ctx)
	for {
		doc, err := itr.Next()
		if err != nil {
			break
		}
		var t PlantTag
		doc.DataTo(&t)
		plant := doc.Ref.Parent.Parent.ID
		plant_tag[plant] = append(plant_tag[plant], t.Id)
	}

	// 条件に合う plant_id を取得
	necessary_tag_map := map[int]int{}
	optional_tag_map := map[int]int{}
	for _, v := range necessary_tags {
		necessary_tag_map[v] = -1
	}
	for _, v := range optional_tags {
		optional_tag_map[v] = -1
	}
	var plant_ids []int
	for ks, v := range plant_tag {
		nec_count := 0
		opt_count := 0
		k, err := strconv.Atoi(ks)
		if err != nil {
			continue
		}
		for _, t := range v {
			bef, ok := necessary_tag_map[t]
			if ok && bef != k {
				necessary_tag_map[t] = k
				nec_count++
			}
			bef, ok = optional_tag_map[t]
			if ok && bef != k {
				optional_tag_map[t] = k
				opt_count++
			}
		}
		if nec_count == len(necessary_tags) && opt_count > 0 {
			plant_ids = append(plant_ids, k)
		}
	}

	// plant_id から植物を取得
	itr = client.Collection("plant").Where("id", "in", plant_ids).Documents(ctx)
	for {
		doc, err := itr.Next()
		if err != nil {
			break
		}
		var plant Plant
		doc.DataTo(&plant)
		plants = append(plants, usecase.PlantHash{
			Plant: usecase.Plant{
				Id:     plant.Id,
				Name:   plant.Name,
				Detail: plant.Detail,
			},
			Hash: plant.Hash,
		})
	}
	return plants, nil
}

// 植物データを挿入する
// 返り値は, (挿入できたか, 新ID, error)
func (*DatabasePlant) InsertPlant(ctx context.Context, name string) (int, error) {
	// 新しいデータとして挿入する
	id := rand.Int()
	plant := Plant{
		Id:     id,
		Name:   name,
		Detail: "",
		Rarity: 0,
		Hash:   "",
	}
	ref := client.Collection("plant").Doc(strconv.Itoa(id))
	err := client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		_, err := tx.Get(ref)
		if err == nil {
			return errors.NewError("failed to create id")
		} else if status.Code(err) != codes.NotFound {
			return errors.ErrorWrap(err)
		}
		err = tx.Set(ref, plant)
		if err != nil {
			return errors.ErrorWrap(err)
		}
		return nil
	})
	if err != nil {
		return -1, errors.ErrorWrap(err)
	}
	return id, nil
}

// 名前から植物が存在するかをチェックする
// 返り値: (存在するか, そのid, error)
func (*DatabasePlant) IsPlantExist(ctx context.Context, name string) (bool, int, error) {
	// 英語名から日本語名に変換する 暫定処理
	// query := "SELECT name FROM plant_names WHERE name = " + strconv.Quote(name)
	// plantテーブルにあるかチェックする

	itr := client.Collection("plant").Where("name", "==", name).Documents(ctx)
	doc, err := itr.Next()
	if err != nil {
		return false, -1, nil
	}
	var plant Plant
	doc.DataTo(&plant)
	return true, plant.Id, nil
}

// 植物idとタグ名のスライスを渡すと、該当する植物にタグを追加する
// タグ名は 30 個まで
func (*DatabasePlant) SetTagsToPlant(ctx context.Context, id int, tagNames []string) error {
	if len(tagNames) == 0 {
		return nil
	}

	var tags []usecase.Tag

	// 各タグ名に一致するタグ情報を取ってくる
	var quote_names []string
	for _, t := range tagNames {
		quote_names = append(quote_names, strconv.Quote(t))
	}
	itr := client.Collection("tag").Where("name", "in", quote_names).Documents(ctx)
	for {
		doc, err := itr.Next()
		if err != nil {
			break
		}
		var tag usecase.Tag
		doc.DataTo(&tag)
		tags = append(tags, tag)
	}

	// 植物idとタグidの結びつけを登録
	bulk := client.BulkWriter(ctx)
	for _, t := range tags {
		ref := client.Collection("plant").Doc(strconv.Itoa(id)).Collection("tags").Doc(strconv.Itoa(t.Id))
		_, err := bulk.Set(ref, PlantTag{
			Id: t.Id,
		})
		if err != nil {
			return errors.ErrorWrap(err)
		}
	}
	bulk.End()

	return nil
}
