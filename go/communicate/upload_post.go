package communicate

import (
	"encoding/json"
	"net/http"

	"narcissus/errors"
	"narcissus/usecase"
)

func CreateUploadPost(w http.ResponseWriter, req *http.Request) error {
	var err error

	// 受け取ったJSONをデコード
	var data usecase.UploadPost
	err = json.NewDecoder(req.Body).Decode(&data)
	if err != nil {
		return errors.ErrorWrap(err)
	}

	// usecase層へ渡す
	err = usecase.InsertUploadPost(req.Context(), data)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}
