package main

import (
	"context"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"narcissus/communicate"
	"narcissus/library/logging"
	"narcissus/nosql"
	"narcissus/usecase"

	"github.com/joho/godotenv"
)

var (
	logger = logging.NewLogger()
)

func init() {
	logger.Info("init main")
	const location = "Asia/Tokyo"
	f, err := os.Create("debug.log")
	if err != nil {
		panic(err)
	}
	log.SetOutput(io.MultiWriter(f, os.Stdout))
	log.SetFlags(log.LstdFlags | log.Lshortfile)
	loc, err := time.LoadLocation(location)
	if err != nil {
		loc = time.FixedZone(location, 9*60*60)
	}
	time.Local = loc

	_, err = os.Stat(".env")
	if !os.IsNotExist(err) {
		err = godotenv.Load(".env")
		if err != nil {
			log.Fatalln(err)
		}
	}

	nosql.Init(context.Background())
}

func main() {
	defer nosql.Close()

	usecase.DbPlant = &nosql.DatabasePlant{}
	usecase.DbTag = &nosql.DatabaseTag{}
	usecase.DbNear = &nosql.DatabaseNear{}
	usecase.DbUploadPost = &nosql.DatabaseUploadPost{}
	usecase.DbPlantTranslate = &nosql.DatabasePlantTranslate{}

	http.HandleFunc("/api/plant", communicate.HttpHandler{
		Get:  communicate.ListPlant,
		Post: nil,
	}.ServeHTTP)
	http.HandleFunc("/api/tag", communicate.HttpHandler{
		Get:  communicate.ListTag,
		Post: nil,
	}.ServeHTTP)
	http.HandleFunc("/api/near", communicate.HttpHandler{
		Get:  communicate.ListNear,
		Post: nil,
	}.ServeHTTP)
	http.HandleFunc("/api/post/upload", communicate.HttpHandler{
		Get:  nil,
		Post: communicate.CreateUploadPost,
	}.ServeHTTP)
	http.HandleFunc("/api/search", communicate.HttpHandler{
		Get:  communicate.SearchPlant,
		Post: nil,
	}.ServeHTTP)
	http.HandleFunc("/api/plant_identify", communicate.HttpHandler{
		Get:  communicate.ListPlantIdentify,
		Post: nil,
	}.ServeHTTP)

	logger.Info("server start")
	port, ok := os.LookupEnv("PORT")
	if !ok {
		port = "80"
	}
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
