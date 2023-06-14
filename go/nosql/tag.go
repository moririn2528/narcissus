package nosql

import (
	"context"
	"narcissus/usecase"
)

type DatabaseTag struct {
}

func (*DatabaseTag) ListTag(ctx context.Context) ([]usecase.Tag, error) {
	var tags []usecase.Tag
	itr := client.Collection("tag").Documents(ctx)
	for {
		doc, err := itr.Next()
		if err != nil {
			break
		}
		var tag usecase.Tag
		doc.DataTo(&tag)
		tags = append(tags, tag)
	}
	return tags, nil
}
