package communicate

import (
	"context"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"narcissus/errors"

	"cloud.google.com/go/storage"
)

// req.FormValue is used to get request parameters from url
// hash
func plantIdentify(w http.ResponseWriter, req *http.Request) error {
	var err error
	// plant_identity, err := usecase.PlantIdentify()
	var plant_identity string

	// ResponseWriterで値を返却
	err = ResponseJson(w, plant_identity)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil

}

func PlantIdentifyHandle(w http.ResponseWriter, req *http.Request) {
	var err error
	switch req.Method {
	case "GET":
		err = plantIdentify(w, req, file_url)
	default:
		w.WriteHeader(http.StatusNotFound)
		return
	}
	if err == nil {
		return
	}
	my_err, ok := err.(*errors.MyError)
	if !ok {
		w.WriteHeader(http.StatusInternalServerError)
		log.Print("wrap error")
		return
	}
	w.WriteHeader(my_err.GetCode())
	log.Print(my_err.Error())
}

// downloadFile downloads an object to a file.
// https://cloud.google.com/storage/docs/samples/storage-download-file?hl=ja#storage_download_file-go
// https://blog.tjun.org/entry/gaego-cloudstorage こっちもありかも？？
func downloadFile(w io.Writer, bucket, object string, destFileName string) error {
	// bucket := "bucket-name"
	// object := "object-name"
	// destFileName := "file.txt"
	ctx := context.Background()
	client, err := storage.NewClient(ctx)
	if err != nil {
		return fmt.Errorf("storage.NewClient: %v", err)
	}
	defer client.Close()

	ctx, cancel := context.WithTimeout(ctx, time.Second*50)
	defer cancel()

	f, err := os.Create(destFileName)
	if err != nil {
		return fmt.Errorf("os.Create: %v", err)
	}

	rc, err := client.Bucket(bucket).Object(object).NewReader(ctx)
	if err != nil {
		return fmt.Errorf("Object(%q).NewReader: %v", object, err)
	}
	defer rc.Close()

	if _, err := io.Copy(f, rc); err != nil {
		return fmt.Errorf("io.Copy: %v", err)
	}

	if err = f.Close(); err != nil {
		return fmt.Errorf("f.Close: %v", err)
	}

	fmt.Fprintf(w, "Blob %v downloaded to local file %v\n", object, destFileName)

	return nil

}
