package main

import (
	"fmt"
	"log"
)

type Database struct {
	ConnectionString string
}

func NewDatabase() *Database {
	return &Database{
		ConnectionString: "db://localhost:5432",
	}
}

type Service struct {
	DB *Database
}

func NewService(db *Database) *Service {
	return &Service{DB: db}
}

type Application struct {
	Service *Service
}

func NewApplication(service *Service) *Application {
	return &Application{Service: service}
}

func main() {
	app, err := InitializeApp()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("App initialized with DB connection string:", app.Service.DB.ConnectionString)
}
