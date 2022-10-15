package database

import (
	"log"

	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3"
)

func Init() {
	var err error
	db, err = sqlx.Open("sqlite3", "./sqlite/narcissus.db")
	if err != nil {
		log.Fatalln(err)
	}
}

func Close() {
	db.Close()
}
