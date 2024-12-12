package lottery

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.uber.org/zap"
)

// 彩票类型枚举
type LotteryType string

const (
	DoubleBall        LotteryType = "DOUBLE_BALL"
	ArrangeV5         LotteryType = "ARRANGE_V5"
	ArrangeV3         LotteryType = "ARRANGE_V3"
	SuperLotto        LotteryType = "SUPER_LOTTO"
	SelectNine        LotteryType = "SELECT_NINE"
	FootballLottery   LotteryType = "FOOTBALL_LOTTERY"
	BasketballLottery LotteryType = "BASKETBALL_LOTTERY"
	SingleMatch       LotteryType = "SINGLE_MATCH"
	SevenHappy        LotteryType = "SEVEN_HAPPY"
	Happy8            LotteryType = "HAPPY_8"
	Welfare3D         LotteryType = "WELFARE_3D"
)

// 投注类型
type BetType string

const (
	DirectBet   BetType = "DIRECT"
	GroupBet    BetType = "GROUP"
	CombineBet  BetType = "COMBINE"
	SingleMatch BetType = "SINGLE_MATCH"
)

// 奖项等级
type PrizeLevel string

const (
	FirstPrize  PrizeLevel = "FIRST"
	SecondPrize PrizeLevel = "SECOND"
	ThirdPrize  PrizeLevel = "THIRD"
	// 可根据不同彩票类型扩展
)

// 彩票投注记录
type LotteryTicket struct {
	ID          uuid.UUID    `bson:"_id"`
	UserID      uuid.UUID    `bson:"user_id"`
	LotteryType LotteryType  `bson:"lottery_type"`
	BetType     BetType      `bson:"bet_type"`
	Numbers     [][]int      `bson:"numbers"`
	BetAmount   float64      `bson:"bet_amount"`
	Multiple    int          `bson:"multiple"`
	IssueNumber string       `bson:"issue_number"`
	BetTime     time.Time    `bson:"bet_time"`
	Status      TicketStatus `bson:"status"`
}
type TicketStatus int

const (
	Pending TicketStatus = iota
	Winning
	Lost
	Claimed
)

// 开奖结果
type DrawResult struct {
	ID             uuid.UUID   `bson:"_id"`
	LotteryType    LotteryType `bson:"lottery_type"`
	IssueNumber    string      `bson:"issue_number"`
	DrawTime       time.Time   `bson:"draw_time"`
	WinningNumbers []int       `bson:"winning_numbers"`
	Jackpot        float64     `bson:"jackpot"`
	Prizes         []PrizeInfo `bson:"prizes"`
}

// 奖项信息
type PrizeInfo struct {
	Level       PrizeLevel `bson:"level"`
	WinnerCount int        `bson:"winner_count"`
	PrizeAmount float64    `bson:"prize_amount"`
}

// 彩票存储接口
type LotteryRepository interface {
	SaveTicket(ticket *LotteryTicket) error
	SaveDrawResult(result *DrawResult) error
	GetTicketsByUser(userID uuid.UUID) ([]LotteryTicket, error)
	GetDrawResultByIssue(lotteryType LotteryType, issueNumber string) (*DrawResult, error)
}

// MongoDB实现
type MongoLotteryRepository struct {
	client           *mongo.Client
	database         *mongo.Database
	ticketCollection *mongo.Collection
	resultCollection *mongo.Collection
	logger           *zap.Logger
}

// 创建MongoDB仓库
func NewMongoLotteryRepository(uri string, logger *zap.Logger) (*MongoLotteryRepository, error) {
	clientOptions := options.Client().ApplyURI(uri)
	client, err := mongo.Connect(context.Background(), clientOptions)
	if err != nil {
		return nil, err
	}

	database := client.Database("lottery_system")

	return &MongoLotteryRepository{
		client:           client,
		database:         database,
		ticketCollection: database.Collection("lottery_tickets"),
		resultCollection: database.Collection("lottery_results"),
		logger:           logger,
	}, nil
}

func (r *MongoLotteryRepository) SaveTicket(ticket *LotteryTicket) error {
	_, err := r.ticketCollection.InsertOne(context.Background(), ticket)
	if err != nil {
		r.logger.Error("Failed to save ticket", zap.Error(err))
	}
	return err
}

func (r *MongoLotteryRepository) SaveDrawResult(result *DrawResult) error {
	_, err := r.resultCollection.InsertOne(context.Background(), result)
	if err != nil {
		r.logger.Error("Failed to save draw result", zap.Error(err))
	}
	return err
}

func (r *MongoLotteryRepository) GetTicketsByUser(userID uuid.UUID) ([]LotteryTicket, error) {
	var tickets []LotteryTicket
	filter := bson.M{"user_id": userID}

	cursor, err := r.ticketCollection.Find(context.Background(), filter)
	if err != nil {
		r.logger.Error("Failed to find tickets", zap.Error(err))
		return nil, err
	}
	defer cursor.Close(context.Background())

	if err = cursor.All(context.Background(), &tickets); err != nil {
		r.logger.Error("Failed to decode tickets", zap.Error(err))
		return nil, err
	}

	return tickets, nil
}

func (r *MongoLotteryRepository) GetDrawResultByIssue(lotteryType LotteryType, issueNumber string) (*DrawResult, error) {
	var result DrawResult
	filter := bson.M{
		"lottery_type": lotteryType,
		"issue_number": issueNumber,
	}

	err := r.resultCollection.FindOne(context.Background(), filter).Decode(&result)
	if err != nil {
		r.logger.Error("Failed to find draw result", zap.Error(err))
		return nil, err
	}

	return &result, nil
}

// 彩票服务
type LotteryService struct {
	repository LotteryRepository
	logger     *zap.Logger
}

func NewLotteryService(repository LotteryRepository, logger *zap.Logger) *LotteryService {
	return &LotteryService{
		repository: repository,
		logger:     logger,
	}
}

func (s *LotteryService) PlaceBet(userID uuid.UUID, lotteryType LotteryType, numbers [][]int, betAmount float64) (*LotteryTicket, error) {
	ticket := &LotteryTicket{
		ID:          uuid.New(),
		UserID:      userID,
		LotteryType: lotteryType,
		Numbers:     numbers,
		BetAmount:   betAmount,
		BetTime:     time.Now(),
		IssueNumber: fmt.Sprintf("%d", time.Now().Unix()), // 简单的期号生成
		Status:      Pending,
	}

	err := s.repository.SaveTicket(ticket)
	if err != nil {
		s.logger.Error("Failed to place bet", zap.Error(err))
		return nil, err
	}

	return ticket, nil
}

func (s *LotteryService) RecordDrawResult(lotteryType LotteryType, winningNumbers []int, prizes []PrizeInfo) (*DrawResult, error) {
	result := &DrawResult{
		ID:             uuid.New(),
		LotteryType:    lotteryType,
		DrawTime:       time.Now(),
		WinningNumbers: winningNumbers,
		IssueNumber:    fmt.Sprintf("%d", time.Now().Unix()),
		Prizes:         prizes,
	}

	err := s.repository.SaveDrawResult(result)
	if err != nil {
		s.logger.Error("Failed to record draw result", zap.Error(err))
		return nil, err
	}

	return result, nil
}

func main() {
	// 初始化日志
	logger, _ := zap.NewProduction()
	defer logger.Sync()

	// 创建MongoDB仓库
	repository, err := NewMongoLotteryRepository("mongodb://localhost:27017", logger)
	if err != nil {
		logger.Fatal("Failed to create repository", zap.Error(err))
	}

	// 创建彩票服务
	lotteryService := NewLotteryService(repository, logger)

	// 用户下注示例
	userID := uuid.New()
	ticket, err := lotteryService.PlaceBet(
		userID,
		DoubleBall,
		[][]int{{1, 2, 3, 4, 5, 6}, {7}},
		100.00,
	)

	// 记录开奖结果示例
	_, err = lotteryService.RecordDrawResult(
		DoubleBall,
		[]int{1, 2, 3, 4, 5, 6},
		[]PrizeInfo{
			{
				Level:       FirstPrize,
				WinnerCount: 1,
				PrizeAmount: 5000000,
			},
		},
	)
}
