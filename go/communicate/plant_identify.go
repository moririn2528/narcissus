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
	"narcissus/usecase"

	"cloud.google.com/go/storage"
)

// req.FormValue is used to get request parameters from url
// hash
func plantIdentify(w http.ResponseWriter, req *http.Request, img_path string) error {
	var err error

	// URLをusecase/plant_identify.go > GetPlantIdentify()に入力
	plant_identity, err := usecase.GetPlantIdentify(img_path)
	if err != nil {
		return errors.ErrorWrap(err)
	}

	// ResponseWriterで値を返却
	err = ResponseJson(w, plant_identity)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil

}

func PlantIdentifyHandle(w http.ResponseWriter, req *http.Request) {
	var err error
	// 画像ファイルをダウンロード
	// 画像の保存先はgo/figure/ フォルダ
	// TODO：全ての処理が終わったら画像を削除

	// 画像が保存されているgcsのバケット名
	bucket_name := "narcissus-figure-1"
	// バケットの中で、どのファイルをロードしたいか？
	// TODO : urlパラメータの形式が分からんので指定できない助けて
	object_name := "upload-figure/" + req.FormValue("hash")
	fmt.Println(object_name)

	// TODO : object_nameがどんな感じで返ってくるのか分からん以下同文
	img_path := "./figure/" + object_name

	// download
	err = downloadFile(w, bucket_name, object_name, img_path)
	if err != nil {
		fmt.Println("Failed to download figure: ", err)
		return
	}

	switch req.Method {
	case "GET":
		err = plantIdentify(w, req, img_path)
	default:
		w.WriteHeader(http.StatusNotFound)
		return
	}
	if err == nil {
		return
	}

	// downloadした画像を削除
	os.Remove(img_path)

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
func downloadFile(w io.Writer, bucket, object string, destFileName string) error {
	// bucket := "bucket-name"
	// object := "object-name"
	// destFileName := "image.jpg"

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

	// fmt.Fprintf(w, "Blob %v downloaded to local file %v\n", object, destFileName)
	fmt.Printf("Blob %v downloaded to local file %v\n", object, destFileName)
	return nil

}
