package main

import (
	"demosvc/pkg/ws"
	"github.com/go-kratos/kratos/v2"
	"github.com/go-kratos/kratos/v2/transport/http"
	"github.com/gorilla/mux"
	"log"
)

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/ws", ws.WsHandler)

	httpSrv := http.NewServer(http.Address(":8088"))
	httpSrv.HandlePrefix("/", router)

	app := kratos.New(
		kratos.Name("ws"),
		kratos.Server(
			httpSrv,
		),
	)
	if err := app.Run(); err != nil {
		log.Println(err)
	}
}
