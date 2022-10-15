package communicate

import (
	"log"
	"net/http"

	"narcissus/errors"
	"narcissus/usecase"
)

func listTag(w http.ResponseWriter, req *http.Request) error {
	var err error
	// DBから植物情報（tags）取得
	tags, err := usecase.ListTag()

	if err != nil {
		return errors.ErrorWrap(err)
	}

	err = ResponseJson(w, tags)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}

func TagHandle(w http.ResponseWriter, req *http.Request) {
	var err error
	switch req.Method {
	case "GET":
		err = listTag(w, req)
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
