package communicate

import (
	"net/http"

	"narcissus/errors"
	"narcissus/usecase"
)

// req.FormValue is used to get request parameters from url
// hash
func ListPlantIdentify(w http.ResponseWriter, req *http.Request) error {
	var err error

	img_path := "https://storage.googleapis.com/narcissus-364913.appspot.com/upload-figure/" + req.FormValue("hash") + ".jpg"

	plant_identity, err := usecase.ListPlantName(img_path)
	if err != nil {
		return errors.ErrorWrap(err)
	}

	plant_identity, err = usecase.TranslateAndJoin(req.Context(), plant_identity)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	type IdentityResponse struct {
		IsEmpty    bool     `json:"is_empty"`
		Identities []string `json:"identities"`
	}
	response := IdentityResponse{IsEmpty: len(plant_identity) == 0, Identities: plant_identity}

	// ResponseWriterで値を返却
	err = ResponseJson(w, response)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}
