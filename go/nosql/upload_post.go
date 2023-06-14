package nosql

import (
	"context"
	"math/rand"
	"narcissus/errors"
	"narcissus/usecase"
	"strconv"
	"time"

	"cloud.google.com/go/firestore"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type DatabaseUploadPost struct {
}

type UploadPost struct {
	Id         int       `firestore:"id"`
	Latitude   float64   `json:"latitude" firestore:"latitude"`
	Longitude  float64   `json:"longitude" firestore:"longitude"`
	Hash       string    `json:"hash" firestore:"hash"`
	UploadTime time.Time `json:"upload_time" firestore:"upload_time"`
}

func (*DatabaseUploadPost) InsertUploadPost(ctx context.Context, uploadPost usecase.UploadPost) error {
	// 投稿をDBに挿入
	id := rand.Int()
	ref := client.Collection("plant").Doc(strconv.Itoa(uploadPost.PlantId)).Collection("uploads").Doc(strconv.Itoa(id))
	err := client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		_, err := tx.Get(ref)
		if err == nil {
			return errors.NewError("failed to create id")
		} else if status.Code(err) != codes.NotFound {
			return errors.ErrorWrap(err)
		}
		err = tx.Set(ref, uploadPost)
		if err != nil {
			return errors.ErrorWrap(err)
		}
		err = tx.Set(client.Collection("plant").Doc(strconv.Itoa(uploadPost.PlantId)), map[string]string{
			"hash": uploadPost.Hash,
		}, firestore.MergeAll)
		if err != nil {
			return errors.ErrorWrap(err)
		}
		return nil
	})
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}
