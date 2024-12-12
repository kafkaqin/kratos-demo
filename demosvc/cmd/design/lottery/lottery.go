package lottery

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/redis/go-redis/v9"
	"time"

	"github.com/go-redis/redis/v8"
	"github.com/jackc/pgx/v4/pgxpool"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// 彩票类型枚举
type LotteryType int

const (
	DoubleBall LotteryType = iota
	ArrangeV5
	ArrangeV3
	SuperLotto
	SelectNine
	FootballLottery
	BasketballLottery
	SingleMatch
	SevenHappy
	Happy8
	Welfare3D
)

// 彩票注单结构
type LotteryTicket struct {
	ID             string       `json:"id" bson:"_id"`
	UserID         string       `json:"user_id" bson:"user_id"`
	LotteryType    LotteryType  `json:"lottery_type" bson:"lottery_type"`
	Numbers        [][]int      `json:"numbers" bson:"numbers"`
	BetAmount      float64      `json:"bet_amount" bson:"bet_amount"`
	BetTime        time.Time    `json:"bet_time" bson:"bet_time"`
	Multiple       int          `json:"multiple" bson:"multiple"`
	PlayType       string       `json:"play_type" bson:"play_type"`
	Status         TicketStatus `json:"status" bson:"status"`
}

// 开奖结果结构
type LotteryDrawResult struct {
	ID             string       `json:"id" bson:"_id"`
	LotteryType    LotteryType  `json:"lottery_type" bson:"lottery_type"`
	DrawDate       time.Time    `json:"draw_date" bson:"draw_date"`
	WinningNumbers []int        `json:"winning_numbers" bson:"winning_numbers"`
	Jackpot        float64      `json:"jackpot" bson:"jackpot"`
	WinningDetails []WinDetail  `json:"winning_details" bson:"winning_details"`
}

type WinDetail struct {
	PrizeLevel   string  `json:"prize_level" bson:"prize_level"`
	WinnerCount  int     `json:"winner_count" bson:"winner_count"`
	PrizeAmount  float64 `json:"prize_amount" bson:"prize_amount"`
}

type TicketStatus int

const (
	Pending TicketStatus = iota
	Winning
	Lost
	Claimed
)

// 存储策略接口
type StorageStrategy interface {
	SaveTicket(ticket *LotteryTicket) error
	SaveDrawResult(result *LotteryDrawResult) error
	FindTicketsByUser(userID string) ([]LotteryTicket, error)
	FindDrawResultByType(lotteryType LotteryType) ([]LotteryDrawResult, error)
}

// MongoDB存储策略
type MongoDBStorageStrategy struct {
	client     *mongo.Client
	database   *mongo.Database
	ticketColl *mongo.Collection
	resultColl *mongo.Collection
}

func NewMongoDBStorageStrategy(uri string) (*MongoDBStorageStrategy, error) {
	clientOptions := options.Client().ApplyURI(uri)
	client, err := mongo.Connect(context.Background(), clientOptions)
	if err != nil {
		return nil, err
	}

	database := client.Database("lottery_db")
	return &MongoDBStorageStrategy{
		client:     client,
		database:   database,
		ticketColl: database.Collection("tickets"),
		resultColl: database.Collection("draw_results"),
	}, nil
}

func (m *MongoDBStorageStrategy) SaveTicket(ticket *LotteryTicket) error {
	_, err := m.ticketColl.InsertOne(context.Background(), ticket)
	return err
}

func (m *MongoDBStorageStrategy) SaveDrawResult(result *LotteryDrawResult) error {
	_, err := m.resultColl.InsertOne(context.Background(), result)
	return err
}

func (m *MongoDBStorageStrategy) FindTicketsByUser(userID string) ([]LotteryTicket, error) {
	var tickets []LotteryTicket
	cursor, err := m.ticketColl.Find(context.Background(), map[string]string{"user_id": userID})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(context.Background())

	err = cursor.All(context.Background(), &tickets)
	return tickets, err
}

func (m *MongoDBStorageStrategy) FindDrawResultByType(lotteryType LotteryType) ([]LotteryDrawResult, error) {
	var results []LotteryDrawResult
	cursor, err := m.resultColl.Find(context.Background(), map[string]LotteryType{"lottery_type": lotteryType})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(context.Background())

	err = cursor.All(context.Background(), &results)
	return results, err
}

// Redis缓存策略
type RedisCacheStrategy struct {
	client *redis.Client
}

func NewRedisCacheStrategy(addr string) *RedisCacheStrategy {
	return &RedisCacheStrategy{
		client: redis.NewClient(&redis.Options{
			Addr: addr,
		}),
	}
}

func (r *RedisCacheStrategy) CacheTicket(ticket *LotteryTicket) error {
	data, err := json.Marshal(ticket)
	if err != nil {
		return err
	}
	return r.client.Set(context.Background(), fmt.Sprintf("ticket:%s", ticket.ID), data, 24*time.Hour).Err()
}

// 数据仓库
type LotteryDataWarehouse struct {
	storageStrategy StorageStrategy
	cacheStrategy   *RedisCacheStrategy
	pgxPool         *pgxpool.Pool
}

func NewLotteryDataWarehouse(
	storageStrategy StorageStrategy,
	cacheStrategy *RedisCacheStrategy,
	pgxPool *pgxpool.Pool
) *LotteryDataWarehouse {
	return &LotteryDataWarehouse{
		storageStrategy: storageStrategy,
		cacheStrategy:   cacheStrategy,
		pgxPool:         pgxPool,
	}
}

// 复杂的查询和统计方法
func (ldw *LotteryDataWarehouse) GetUserLotteryStats(userID string) (map[LotteryType]int, error) {
	// 实现复杂的数据统计逻辑
	return nil, nil
}

// 工厂方法：创建不同类型的彩票
type LotteryFactory struct {
	warehouse *LotteryDataWarehouse
}

func (lf *LotteryFactory) CreateLotteryTicket(
	lotteryType LotteryType,
	userID string,
	numbers [][]int
) *LotteryTicket {
	return &LotteryTicket{
		ID:          fmt.Sprintf("%d_%s", time.Now().UnixNano(), userID),
		UserID:      userID,
		LotteryType: lotteryType,
		Numbers:     numbers,
		BetTime:     time.Now(),
		Status:      Pending,
	}
}

func main() {
	// 示例使用
	mongoStrategy, _ := NewMongoDBStorageStrategy("mongodb://localhost:27017")
	redisCache := NewRedisCacheStrategy("localhost:6379")
	pgxConfig, _ := pgxpool.ParseConfig("postgres://user:pass@localhost:5432/lottery_db")
	pgxPool, _ := pgxpool.ConnectConfig(context.Background(), pgxConfig)

	dataWarehouse := NewLotteryDataWarehouse(mongoStrategy, redisCache, pgxPool)
	lotteryFactory := &LotteryFactory{warehouse: dataWarehouse}

	// 创建双色球彩票
	ticket := lotteryFactory.CreateLotteryTicket(
		DoubleBall,
		"user123",
		[][]int{{1, 2, 3, 4, 5, 6}, {7}}
	)

	// 保存彩票
	mongoStrategy.SaveTicket(ticket)
	redisCache.CacheTicket(ticket)
}