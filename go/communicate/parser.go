package communicate

import (
	"bytes"
	"encoding/json"
	"io"
	"narcissus/errors"
	"net/http"
)

// json 入力の POST で、入力されたものを取得する
// value: json を入れるもののアドレス
// func parserPostJson(req *http.Request, value interface{}) error {
// 	if req.Header.Get("Content-Type") != "application/json" {
// 		return errors.NewError(http.StatusBadRequest, "content type")
// 	}
// 	leng, err := strconv.Atoi(req.Header.Get("Content-Length"))
// 	if err != nil {
// 		return errors.ErrorWrap(err, http.StatusBadRequest, "content length")
// 	}
// 	body := make([]byte, leng)
// 	leng, err = req.Body.Read(body)
// 	if err != nil && err != io.EOF {
// 		return errors.ErrorWrap(err, http.StatusBadRequest, "read body error")
// 	}
// 	err = json.Unmarshal(body[:leng], value)
// 	if err != nil {
// 		return errors.ErrorWrap(err, http.StatusBadRequest, "json parse error")
// 	}
// 	return nil
// }

func ResponseJson(w http.ResponseWriter, v interface{}) error {
	res, err := json.Marshal(v)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	var buf bytes.Buffer
	err = json.Indent(&buf, res, "", "  ")
	if err != nil {
		return errors.ErrorWrap(err)
	}
	w.Header().Set("Content-type", "application/json;charset=utf-8")
	_, err = io.WriteString(w, buf.String())
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}
