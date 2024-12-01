package main

import (
	"context"
	"fmt"
	"github.com/redis/go-redis/v9"
	"log"
	"math/rand"
	"strconv"
	"time"
)

// 订单结构体
type Order struct {
	OrderID    string
	CustomerID int
	ProductID  int
	Amount     float64
	Status     string
	Timestamp  int64
}

func main() {
	// 初始化 Redis 客户端
	rdb := redis.NewClient(&redis.Options{
		Addr: "localhost:6379", // Redis 服务器地址
		DB:   0,                // 使用默认的数据库
	})

	// 测试 Redis 连接
	ctx := context.Background()
	_, err := rdb.Ping(ctx).Result()
	if err != nil {
		log.Fatalf("无法连接到 Redis: %v", err)
	}

	// 模拟插入一亿个订单
	//for i := 1; i <= 1000; i++ { // 这里模拟插入 1 亿个订单
	//	order := generateOrder(i)
	//
	//	// 将订单信息存入 Redis Sorted Set
	//	orderKey := "orders:sorted_by_amount" // 使用金额排序
	//	err := storeOrderInSortedSet(ctx, rdb, orderKey, order)
	//	if err != nil {
	//		log.Printf("存储订单 %s 时出错: %v", order.OrderID, err)
	//	}
	//
	//	// 每 1000 个订单打印一次进度
	//	if i%1000 == 0 {
	//		fmt.Printf("已存储 %d 个订单\n", i)
	//	}
	//}

	// 测试查询某个订单的排序情况
	testOrderID := "555" // 示例订单 ID
	orderKey := "orders:sorted_by_amount"
	orderRank, err := getOrderRankInSortedSet(ctx, rdb, orderKey, testOrderID)
	if err != nil {
		log.Printf("获取订单 %s 排名时出错: %v", testOrderID, err)
	} else {
		fmt.Printf("订单 %s 排名: %d\n", testOrderID, orderRank)
	}

	// 查询按金额排序的前 10 个订单
	topOrders, err := getTopOrdersByAmount(ctx, rdb, orderKey, 10)
	if err != nil {
		log.Printf("获取前 10 个订单时出错: %v", err)
	} else {
		fmt.Println("按金额排序的前 10 个订单：")
		for _, order := range topOrders {
			fmt.Printf("订单ID: %s, 金额: %.2f\n", order.OrderID, order.Amount)
		}
	}
}

// 生成一个订单数据
func generateOrder(i int) *Order {
	return &Order{
		OrderID:    strconv.Itoa(i),
		CustomerID: rand.Intn(10000),                  // 随机生成客户 ID
		ProductID:  rand.Intn(1000),                   // 随机生成产品 ID
		Amount:     float64(rand.Intn(10000)) / 100.0, // 随机金额
		Status:     "pending",                         // 订单状态
		Timestamp:  time.Now().Unix(),                 // 当前时间戳作为时间标记
	}
}

// 将订单存储到 Redis Sorted Set
func storeOrderInSortedSet(ctx context.Context, rdb *redis.Client, orderKey string, order *Order) error {
	// 使用订单金额作为分数，订单ID作为成员
	_, err := rdb.ZAdd(ctx, orderKey, redis.Z{
		Score:  order.Amount,  // 使用金额作为分数
		Member: order.OrderID, // 使用订单ID作为成员
	}).Result()

	// 你也可以使用时间戳来排序，如果是按时间排序，可以将以下代码修改为：
	// _, err := rdb.ZAdd(ctx, orderKey, &redis.Z{
	// 	Score:  float64(order.Timestamp), // 使用时间戳作为分数
	// 	Member: order.OrderID,            // 使用订单ID作为成员
	// }).Result()

	return err
}

// 获取订单在 Sorted Set 中的排名
func getOrderRankInSortedSet(ctx context.Context, rdb *redis.Client, orderKey, orderID string) (int64, error) {
	// ZRank 获取指定成员的排名（按分数排序，排名从 0 开始）
	rank, err := rdb.ZRank(ctx, orderKey, orderID).Result()
	if err != nil {
		return -1, err
	}
	return rank, nil
}

// 查询按金额排序的前 N 个订单
func getTopOrdersByAmount(ctx context.Context, rdb *redis.Client, orderKey string, topN int) ([]*Order, error) {
	// ZRangeByScore 获取按分数范围排序的成员
	result, err := rdb.ZRevRangeByScore(ctx, orderKey, &redis.ZRangeBy{
		Min:   "98",        // 最小分数
		Max:   "100",       // 最大分数
		Count: int64(topN), // 返回前 N 个订单
	}).Result()

	if err != nil {
		return nil, err
	}

	var orders []*Order
	for _, orderID := range result {
		// 获取每个订单的详细信息，可以从哈希表中读取订单数据
		order, err := getOrderDetails(ctx, rdb, orderID)
		if err != nil {
			log.Printf("获取订单 %s 详细信息时出错: %v", orderID, err)
			continue
		}
		orders = append(orders, order)
	}

	return orders, nil
}

// 获取订单的详细信息（例如从哈希表中获取）
func getOrderDetails(ctx context.Context, rdb *redis.Client, orderID string) (*Order, error) {
	orderKey := "order:" + orderID
	result, err := rdb.HGetAll(ctx, orderKey).Result()
	if err != nil {
		return nil, err
	}

	// 如果没有找到该订单，返回错误
	if len(result) == 0 {
		return nil, fmt.Errorf("订单 %s 不存在", orderID)
	}

	customerID, _ := strconv.Atoi(result["customer_id"])
	productID, _ := strconv.Atoi(result["product_id"])
	amount, _ := strconv.ParseFloat(result["amount"], 64)
	status := result["status"]

	order := &Order{
		OrderID:    orderID,
		CustomerID: customerID,
		ProductID:  productID,
		Amount:     amount,
		Status:     status,
	}
	return order, nil
}
