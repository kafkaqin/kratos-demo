package main

import (
	"context"
	"fmt"
	"github.com/redis/go-redis/v9"
)

var rdb *redis.Client

func main() {
	rdb = redis.NewClient(&redis.Options{
		Addr: "localhost:6379",
	})
	ctx := context.Background()
	err := rdb.Ping(ctx).Err()
	if err != nil {
		panic(err)
	}

	// 订阅键空间通知事件（例如 set 和 del）
	pubsub := rdb.PSubscribe(ctx, "__keyevent@0__:*", "__keyevent@0__:*")

	// 等待事件的消息
	for msg := range pubsub.Channel() {
		fmt.Printf("Received message: %s %s\n", msg.Channel, msg.Payload)

		// 根据事件进行不同的处理
		if msg.Channel == "__keyevent@0__:set" {
			fmt.Println("A key was set:", msg.Payload, msg)
		} else if msg.Channel == "__keyevent@0__:del" {
			fmt.Println("A key was deleted:", msg.Payload)
		}
	}
}
