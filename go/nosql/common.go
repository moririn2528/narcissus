package nosql

import (
	"context"
	"os"

	"narcissus/library/logging"

	"cloud.google.com/go/firestore"
)

const (
	MAX_OR_QUERY = 30
)

var (
	client *firestore.Client
	logger logging.Logger = logging.NewLogger()
)

func Init(ctx context.Context) {
	id, ok := os.LookupEnv("FIRESTORE_PROJECT_ID")
	if !ok {
		logger.Error("FIRESTORE_PROJECT_ID is not set")
		return
	}
	var err error
	client, err = firestore.NewClient(ctx, id)
	if err != nil {
		logger.Error(err)
		return
	}

	itr := client.Collection("init_finished").Documents(ctx)
	_, err = itr.Next()
	if err == nil {
		return
	}
	createInitData(ctx)
}

func Close() {
	client.Close()
}
