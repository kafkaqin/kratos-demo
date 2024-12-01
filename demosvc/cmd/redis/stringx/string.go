package main

import (
	"context"
	"github.com/redis/go-redis/v9"
	"github.com/sirupsen/logrus"
)

var rbd *redis.Client

func main() {
	rbd = redis.NewClient(&redis.Options{
		Addr: "localhost:6379",
	})

	err := rbd.Ping(context.Background()).Err()
	if err != nil {
		logrus.Error(err)
		return
	}

	err = rbd.Set(context.Background(), "user:1001", "Join", 0).Err()
	if err != nil {
		logrus.Error(err)
		return
	}

	value := rbd.Get(context.Background(), "user:1001").Val()
	logrus.Infof("%s", value)
}
