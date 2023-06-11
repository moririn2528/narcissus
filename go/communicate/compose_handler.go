package communicate

import (
	"net/http"
	"net/url"

	"narcissus/errors"
)

type HttpHandler struct {
	Get  func(http.ResponseWriter, *http.Request) error
	Post func(http.ResponseWriter, *http.Request) error
}

func (h HttpHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	var err error
	origin := req.Header.Get("Origin")
	if origin != "" {
		url, err := url.Parse(origin)
		if err == nil && url.Hostname() == "localhost" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
		}
	}
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")

	switch req.Method {
	case "GET":
		if h.Get == nil {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		err = h.Get(w, req)
	case "POST":
		if h.Post == nil {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		err = h.Post(w, req)
	case "OPTIONS":
		w.WriteHeader(http.StatusOK)
		return
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
		return
	}
	w.WriteHeader(my_err.GetCode())
}
