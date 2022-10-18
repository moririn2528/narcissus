package main

import (
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"narcissus/communicate"
	"narcissus/database"
	"narcissus/usecase"

	"github.com/joho/godotenv"
)

func init() {
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

	database.Init()
}

func main() {
	defer database.Close()

	usecase.DbPlant = &database.DatabasePlant{}
	usecase.DbTag = &database.DatabaseTag{}
	usecase.DbNear = &database.DatabaseNear{}

	http.HandleFunc("/api/plant", communicate.PlantHandle)
	http.HandleFunc("/api/tag", communicate.TagHandle)
	http.HandleFunc("/api/near", communicate.NearHandle)

	// 画像を配置する静的フォルダ
	// 参考文献：https://github.com/golang/go/issues/50638
	http.Handle("/figure/", http.FileServer(http.Dir(".")))

	log.Print("start")
	port, ok := os.LookupEnv("PORT")
	if !ok {
		port = "80"
	}
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
