package main

import (
	"context"
	"fmt"
	"github.com/redis/go-redis/v9"
	"github.com/sirupsen/logrus"
)

var rbd *redis.Client

func main() {
	rbd = redis.NewClient(&redis.Options{
		Addr: "localhost:6379",
	})
	defer rbd.Close()
	ctx := context.Background()
	err := rbd.Ping(ctx).Err()
	if err != nil {
		panic(err)
	}
	members := make([]string, 0)
	for i := 11; i < 1000; i++ {
		members = append(members, fmt.Sprintf("member%d", i))
	}

	res, err := rbd.SAdd(ctx, "shello", members).Result()
	if err != nil {
		logrus.WithField("sadd", err).Error(err)
	}
	logrus.WithField("res", res).Println()
	sortList, err := rbd.SMembers(ctx, "shello").Result()
	if err != nil {
		logrus.WithField("smembers", err).Error(err)
	}
	logrus.WithField("sortList", sortList).Println()

	result := make([]string, 0)
	//for rbd.SScan(ctx, "shello", cursor, "*", 1).Iterator().Next(ctx) {
	// 执行增量扫描 SScan
	cursor := uint64(0)
	for {
		// 使用 SScan 扫描集合 members
		var members []string
		var err error
		cursor, members, err = sscan(ctx, "shello", cursor, "member808", 3)
		if err != nil {
			logrus.Fatalf("Error scanning Redis set: %v", err)
		}

		// 输出扫描的结果
		fmt.Printf("Cursor: %d\n", cursor)
		fmt.Println("Members:", members)

		// 如果 cursor 为 0，表示扫描完成，退出循环
		if cursor == 0 {
			break
		}
	}

	logrus.WithField("result", result).WithField("cursor", cursor).Println(len(result))
	//}

}
func sscan(ctx context.Context, key string, cursor uint64, match string, count int64) (uint64, []string, error) {
	// 调用 SScan 命令
	result, cursor, err := rbd.SScan(ctx, key, cursor, match, count).Result()
	if err != nil {
		return 0, nil, err
	}
	return cursor, result, nil
}
