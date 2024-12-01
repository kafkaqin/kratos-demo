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
	defer rbd.Close()
	ctx := context.Background()
	if err := rbd.Ping(ctx).Err(); err != nil {
		panic(err)
	}
	tsKeys := "tmp:TLV"
	err := rbd.TSCreate(ctx, tsKeys).Err()
	if err != nil {
		logrus.WithField("tscreate", err).Error(err)
	}
	ktvSlice := make([][]interface {
	}, 0)
	s := make([]interface{}, 0)
	for i := 0; i < 10; i++ {
		s = append(s, i)
	}
	ktvSlice = append(ktvSlice, s)
	err = rbd.TSMAdd(ctx, ktvSlice).Err()
	if err != nil {
		logrus.WithField("TSMAdd", err).Error(err)
	}

	ts, err := rbd.TSGet(ctx, tsKeys).Result()
	if err != nil {
		logrus.WithField("tsget", err).Error(err)
	}
	logrus.WithField("tsget", ts).Info()

}
