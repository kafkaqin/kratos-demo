package main

import (
	"context"
	"fmt"
	"github.com/redis/go-redis/v9"
	"github.com/sirupsen/logrus"
)

var rbd *redis.Client

var ctx = context.Background()

func main() {
	rbd = redis.NewClient(&redis.Options{
		Addr: "127.0.0.1:6379",
	})
	defer rbd.Close()
	err := rbd.Ping(ctx).Err()
	if err != nil {
		panic(err)
	}

	addPlayerScore("player1", 500)
	addPlayerScore("player2", 1500)
	addPlayerScore("player3", 1200)
	addPlayerScore("player4", 800)
	addPlayerScore("player5", 1300)
	addPlayerScore("player6", 2000)

	topPlayers := geTopPlayer(3)
	fmt.Println("Top 3 Players:")
	for i, player := range topPlayers {
		fmt.Printf("%d. %s\n", i+1, player)
	}

	// 获取某个玩家的排名
	rank, err := getPlayerRank("player3")
	if err != nil {
		logrus.Fatalf("Error getting player rank: %v", err)
	}
	fmt.Printf("Player3 Rank: %d\n", rank)
	// 更新玩家分数
	updatePlayerScore("player4", 1700)

	// 获取更新后的前 3 名玩家
	topPlayersUpdated := geTopPlayer(3)
	fmt.Println("\nUpdated Top 3 Players:")
	for i, player := range topPlayersUpdated {
		fmt.Printf("%d. %s\n", i+1, player)
	}
}

func addPlayerScore(playID string, score float64) {
	err := rbd.ZAdd(ctx, "game_leaderboard", redis.Z{Score: score, Member: playID}).Err()
	if err != nil {
		logrus.Error(err)
	}
}

func geTopPlayer(topN int) []string {
	result, err := rbd.ZRevRange(ctx, "game_leaderboard", 0, int64(topN)-1).Result()
	if err != nil {
		logrus.WithField("zrange", result).Error(err)
	}
	return result
}

func getPlayerRank(playID string) (int, error) {
	rank, err := rbd.ZRevRank(ctx, "game_leaderboard", playID).Result()
	if err != nil {
		return -1, err
	}
	return int(rank) + 1, nil
}
func updatePlayerScore(playerID string, newScore float64) {
	err := rbd.ZAdd(ctx, "game_leaderboard", redis.Z{
		Score:  newScore,
		Member: playerID,
	}).Err()
	if err != nil {
		logrus.Fatalf("Error updating player score: %v", err)
	}
}
