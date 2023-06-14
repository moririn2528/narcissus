package nosql

import (
	"context"
)

type DatabasePlantTranslate struct {
}

// 植物名を検索して、存在するものを最初に持ってくる
// identities は 30 個まで
func (*DatabasePlantTranslate) SearchPlantName(ctx context.Context, identities []string) ([]string, error) {
	itr := client.Collection("plant").Where("name", "in", identities).Documents(ctx)
	var result []string
	exists := map[string]interface{}{}

	for {
		doc, err := itr.Next()
		if err != nil {
			break
		}
		var plant Plant
		doc.DataTo(&plant)
		exists[plant.Name] = nil
		result = append(result, plant.Name)
	}

	for _, identity := range identities {
		if _, ok := exists[identity]; !ok {
			result = append(result, identity)
		}
	}
	return result, nil
}
