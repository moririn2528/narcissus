package communicate

import (
	"context"
	"fmt"
	"log"
	"net/http"

	"narcissus/errors"

	vision "cloud.google.com/go/vision/apiv1"
)

func plantIdentify(w http.ResponseWriter, req *http.Request, file_url string) error {
	var err error
	// plant_identity, err := usecase.PlantIdentify()
	var plant_identity string

	// vision api セッティング
	ctx := context.Background()

	client, err := vision.NewImageAnnotatorClient(ctx)
	if err != nil {
		return err
	}
	// 画像が置かれているURLから画像を受け取る
	image := vision.NewImageFromURI(file_url)

	// 植物名を受け取る
	web, err := client.DetectWeb(ctx, image, nil)
	if err != nil {
		return err
	}

	// webのなかの、Entityのなかでスコアが最も高いものを返す
	if len(web.WebEntities) != 0 {
		fmt.Fprintln(w, "\tEntities:")
		fmt.Fprintln(w, "\t\tEntity\t\tScore\tDescription")
		for _, entity := range web.WebEntities {
			plant_identity = entity.Description
		}
	} else {
		plant_identity = ""
	}

	// ResponseWriterで値を返却
	err = ResponseJson(w, plant_identity)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil

}

func PlantIdentifyHandle(w http.ResponseWriter, req *http.Request, file_url string) {
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
