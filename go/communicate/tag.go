package communicate

import (
	"net/http"

	"narcissus/errors"
	"narcissus/usecase"
)

func ListTag(w http.ResponseWriter, req *http.Request) error {
	var err error
	// DBから植物情報（tags）取得
	tags, err := usecase.ListTag(req.Context())

	if err != nil {
		return errors.ErrorWrap(err)
	}

	err = ResponseJson(w, tags)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}
