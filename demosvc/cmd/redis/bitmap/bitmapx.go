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
	ctx := context.Background()
	defer rbd.Close()
	if err := rbd.Ping(ctx).Err(); err != nil {
		panic(err)
	}

	err := rbd.ZAdd(ctx, "key1", redis.Z{Score: float64(1), Member: "test"}, redis.Z{Score: float64(1), Member: "test1"}).Err()
	if err != nil {
		logrus.WithField("zadd", err).Error(err)
	}
	zlist, err := rbd.ZRangeStore(ctx, "", redis.ZRangeArgs{Key: "key1*", ByScore: true}).Result()
	if err != nil {
		logrus.WithField("zrange", err).Error(err)
	}

	logrus.WithField("zlist", zlist).Info("zlist")

	//rbd.BitField(ctx, "bittest", 1, 1).Err()
	//rbd.BitField(ctx, "bittest", 2, 1).Err()
	//rbd.BitField(ctx, "bittest", 3, 1).Err()
	//rbd.BitField(ctx, "bittest", 4, 1).Err()
	rbd.SetBit(ctx, "user:1001:sign_in", 1, 1).Err()
	rbd.SetBit(ctx, "user:1001:sign_in", 2, 1).Err()
	rbd.SetBit(ctx, "user:1002:sign_in", 6, 1).Err()
	rbd.SetBit(ctx, "user:1003:sign_in", 7, 1).Err()
	res, err := rbd.BitOpOr(ctx, "user:combined_sign_in", "user:1001:sign_in").Result()
	if err != nil {
		logrus.WithField("BitOpOr", res).Error(err)
	}

	logrus.WithField("BitOpOr", res).Info(err)

	bitCount, err := rbd.BitCount(ctx, "user:1002:sign_in", &redis.BitCount{
		Start: 0,
		End:   -1,
	}).Result()
	logrus.WithField("BitCount", bitCount).Info(err)
}
