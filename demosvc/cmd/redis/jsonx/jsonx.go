package main

import (
	"context"
	"github.com/redis/go-redis/v9"
	"github.com/sirupsen/logrus"
)

var rbd *redis.Client

func main() {
	rbd = redis.NewClient(&redis.Options{
		Addr: "localhost:16379",
	})
	ctx := context.Background()
	err := rbd.Ping(ctx).Err()
	if err != nil {
		panic(err)
	}
	setJSONData(ctx, "user:1", `{
		"user_id": 1,
		"name": "John Doe",
		"email": "john.doe@example.com",
		"preferences": {
			"notifications": true,
			"theme": "dark"
		}
	}`)

	res, err := getJSONData(ctx, "user:1")
	if err != nil {
		logrus.Error(err)
	}
	logrus.Info(res)

}
func setJSONData(ctx context.Context, key string, value interface{}) {
	_, err := rbd.JSONSet(ctx, key, ".", value).Result()
	if err != nil {
		logrus.Error(err)
	}
}

func getJSONData(ctx context.Context, key string) (string, error) {
	return rbd.JSONGet(ctx, key).Result()
}
