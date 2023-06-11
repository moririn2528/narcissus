package communicate

import (
	"math"
	"net/http"
	"sort"
	"strconv"

	"narcissus/errors"
	"narcissus/usecase"
)

// 加工後の構造体
type NearPlant struct {
	Id        int     `json:"id"`
	Name      string  `json:"name"`
	Url       string  `json:"url"`
	Detail    string  `json:"detail"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Distance  float64 `json:"distance"`
	TimeStamp string  `json:"timestamp"`
}
type NearPlants []NearPlant

// ソートのインタフェースを満たすためのメソッド
func (n NearPlants) Len() int {
	return len(n)
}
func (n NearPlants) Swap(i, j int) {
	n[i], n[j] = n[j], n[i]
}
func (n NearPlants) Less(i, j int) bool {
	return n[i].Distance < n[j].Distance
}

func ListNear(w http.ResponseWriter, req *http.Request) error {
	var err error

	// 緯度経度を受け取る
	latitude, err := strconv.ParseFloat(req.FormValue("latitude"), 64)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	longitude, err := strconv.ParseFloat(req.FormValue("longitude"), 64)
	if err != nil {
		return errors.ErrorWrap(err)
	}

	// 探索範囲(縦,横:メートル)を受け取る 値がなければ初期値にする
	var length float64 = 6000
	length_str := req.FormValue("length")
	if length_str != "" {
		length, err = strconv.ParseFloat(length_str, 64)
		if err != nil {
			return errors.ErrorWrap(err)
		}
	}

	// 範囲内にある投稿と植物のリストを受け取る
	nears, err := usecase.ListNear(req.Context(), latitude, longitude, length)
	if err != nil {
		return errors.ErrorWrap(err)
	}

	// hashからURLに変換、中心からの距離(単位:m)を計算、timestampをstringに
	var sorted_nears NearPlants
	var distance float64
	layout := "2006-01-02 15:04:05"
	for _, v := range nears {
		distance = math.Pow(longitude-v.Longitude, 2)
		distance += math.Pow(latitude-v.Latitude, 2)
		distance = math.Pow(distance, 0.5)
		distance *= 40075000.0 / 360.0
		sorted_nears = append(sorted_nears,
			NearPlant{
				Id:        v.Id,
				Name:      v.Name,
				Url:       usecase.HashToUrl(v.Hash),
				Detail:    v.Detail,
				Latitude:  v.Latitude,
				Longitude: v.Longitude,
				Distance:  distance,
				TimeStamp: v.TimeStamp.Format(layout)})
	}
	// 距離でソートする
	sort.Sort(sorted_nears)

	type Result struct {
		IsEmpty int        `json:"IsEmpty"`
		Datas   NearPlants `json:"Datas"`
	}
	isEmp := 0
	if len(sorted_nears) == 0 {
		isEmp = 1
	}
	res := Result{IsEmpty: isEmp, Datas: sorted_nears}

	// JSONに変換して返す
	err = ResponseJson(w, res)
	if err != nil {
		return errors.ErrorWrap(err)
	}
	return nil
}
