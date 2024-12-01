package main

import (
	"context"
	"github.com/redis/go-redis/v9"
)

var rbd *redis.Client

func main() {
	rbd = redis.NewClient(&redis.Options{
		Addr: "localhost:6379",
	})
	ctx := context.Background()
	defer rbd.Close()
	if err := rbd.Ping(ctx).Err(); err != nil {
		panic(err)
	}

	rbd.Eval()
}
