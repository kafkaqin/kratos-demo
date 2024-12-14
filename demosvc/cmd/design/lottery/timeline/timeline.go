package main

import (
	"github.com/gorilla/websocket"
	"log"
	"net/http"
	"sync"
)

// WebSocketServer 代表 WebSocket 服务器
type WebSocketServer struct {
	clients   map[*websocket.Conn]bool
	broadcast chan string
	mutex     sync.Mutex
}

func NewWebSocketServer() *WebSocketServer {
	return &WebSocketServer{
		clients:   make(map[*websocket.Conn]bool),
		broadcast: make(chan string),
	}
}

// HandleClient 处理每个 WebSocket 客户端连接
func (ws *WebSocketServer) HandleClient(conn *websocket.Conn) {
	defer conn.Close()

	// 新客户端加入
	ws.mutex.Lock()
	ws.clients[conn] = true
	ws.mutex.Unlock()

	// 监听消息并发送到广播频道
	for {
		var msg string
		err := conn.ReadMessage(&msg)
		if err != nil {
			log.Printf("read error: %v", err)
			break
		}
		ws.broadcast <- msg
	}
}

// Broadcast 向所有客户端广播消息
func (ws *WebSocketServer) Broadcast() {
	for {
		msg := <-ws.broadcast
		ws.mutex.Lock()
		for client := range ws.clients {
			err := client.WriteMessage(websocket.TextMessage, []byte(msg))
			if err != nil {
				log.Printf("write error: %v", err)
				client.Close()
				delete(ws.clients, client)
			}
		}
		ws.mutex.Unlock()
	}
}

func main() {
	server := NewWebSocketServer()

	// 启动广播
	go server.Broadcast()

	// 处理每个连接
	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		conn, err := websocket.Accept(w, r)
		if err != nil {
			http.Error(w, "Unable to accept connection", http.StatusInternalServerError)
			return
		}
		server.HandleClient(conn)
	})

	// 启动 WebSocket 服务器
	log.Println("WebSocket server started at ws://localhost:8080/ws")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
