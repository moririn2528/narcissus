package nosql

import (
	"context"
	"narcissus/usecase"
	"strconv"
)

type DatabaseNear struct {
}

func (*DatabaseNear) ListNear(ctx context.Context, latitude float64, longitude float64, length float64) ([]usecase.Near, error) {
	var nears []usecase.Near
	// 取ってくる縦横の範囲(単位:m)を
	// 緯度経度の尺度に変換するための値
	var rate float64 = 360.0 / 40075000.0
	length *= rate / 2

	// 緯度経度の範囲
	var latitude_min float64 = latitude - length
	var latitude_max float64 = latitude + length
	var longitude_min float64 = longitude - length
	var longitude_max float64 = longitude + length

	logger.Debugf("latitude_min: %v, latitude_max: %v, longitude_min: %v, longitude_max: %v", latitude_min, latitude_max, longitude_min, longitude_max)
	itr := client.CollectionGroup("uploads").Where("longitude", ">=", longitude_min).Where("longitude", "<=", longitude_max).Documents(ctx)
	used := map[int]int{}
	cnt := 0
	for {
		doc, err := itr.Next()
		if err != nil {
			break
		}
		cnt++
		var uploadPost UploadPost
		err = doc.DataTo(&uploadPost)
		if err != nil {
			logger.Warning(err)
			continue
		}
		if uploadPost.Latitude < latitude_min || latitude_max < uploadPost.Latitude {
			continue
		}
		ref := doc.Ref.Parent.Parent
		id, err := strconv.Atoi(ref.ID)
		if err != nil {
			logger.Warning(err)
			continue
		}
		_, ok := used[id]
		if ok {
			continue
		}
		used[id] = len(nears)
		nears = append(nears, usecase.Near{
			Id:        id,
			Latitude:  uploadPost.Latitude,
			Longitude: uploadPost.Longitude,
			TimeStamp: uploadPost.UploadTime,
		})
	}
	logger.Debugf("nears: %v, count: %v", nears, cnt)
	min := func(a, b int) int {
		if a < b {
			return a
		}
		return b
	}
	for i := 0; i < len(nears); i += MAX_OR_QUERY {
		a := min(i+MAX_OR_QUERY, len(nears))
		var ids []int
		for j := i; j < a; j++ {
			ids = append(ids, nears[j].Id)
		}
		itr := client.Collection("plant").Where("id", "in", ids).Documents(ctx)
		for {
			doc, err := itr.Next()
			if err != nil {
				break
			}
			var plant Plant
			doc.DataTo(&plant)
			idx := used[plant.Id]
			nears[idx].Name = plant.Name
			nears[idx].Hash = plant.Hash
			nears[idx].Detail = plant.Detail
		}
	}
	return nears, nil
}
