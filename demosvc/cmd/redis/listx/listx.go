package main

import (
	"context"
	"github.com/redis/go-redis/v9"
	"github.com/sirupsen/logrus"
)

var rbd *redis.Client

func main() {
	rbd = redis.NewClient(&redis.Options{
		Addr: "127.0.0.1:6379",
	})
	ctx := context.Background()
	err := rbd.Ping(ctx).Err()
	if err != nil {
		panic(err)
	}

	//err = rbd.LPush(ctx, "hello", "world", "task1").Err()
	//if err != nil {
	//	logrus.Error(err)
	//	return
	//}
	//err = rbd.LPush(ctx, "hello1", "world1", "task2").Err()
	//if err != nil {
	//	logrus.Error(err)
	//	return
	//}
	////rbd.LPop()
	////rbd.LPopCount()
	result := rbd.LRange(ctx, "hello1", 0, -1).Val()
	logrus.Info(result, len(result))

	//result = rbd.LRange(ctx, "hello1", 0, -1).Val()
	//logrus.Info(result)

	//err = rbd.LPopCount(ctx, "hello", 1).Err()
	//if err != nil {
	//	logrus.Error(err)
	//	return
	//}
	result1, err := rbd.LTrim(ctx, "hello1", 0, -1).Result()
	if err != nil {
		logrus.Error(err)
		return
	}
	logrus.Info(result1)
	val := rbd.LSet(ctx, "user", 0, 1).Val()
	logrus.Info(val)
	slog, err := rbd.SlowLogGet(ctx, 10).Result()
	if err != nil {
		logrus.WithField("slowlog", err).Error(err)
	}
	logrus.Info(slog)

	lenHello, err := rbd.LLen(ctx, "hello1").Result()
	if err != nil {
		logrus.WithField("llen", err).Error(err)
	}
	logrus.Info(lenHello)

	//rbd.LCS()
}
