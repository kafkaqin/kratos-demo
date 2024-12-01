package main

import (
	"context"
	"fmt"
	"github.com/redis/go-redis/v9"
	"log"
	"math/rand"
	"strconv"
)

// 订单结构体
type Order struct {
	OrderID    string
	CustomerID int
	ProductID  int
	Amount     float64
	Status     string
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

	// 模拟插入上亿个订单
	//for i := 1; i <= 10000000; i++ { // 这里模拟插入 1000 万个订单
	//	order := generateOrder(i)
	//
	//	// 将订单信息存入 Redis 哈希表
	//	orderKey := "order:" + order.OrderID
	//	err := storeOrderInRedis(ctx, rdb, orderKey, order)
	//	if err != nil {
	//		log.Printf("存储订单 %s 时出错: %v", order.OrderID, err)
	//	}
	//
	//	// 每 1000 个订单打印一次进度
	//	if i%1000 == 0 {
	//		fmt.Printf("已存储 %d 个订单\n", i)
	//	}
	//}

	// 测试查询某个订单信息
	testOrderID := "222078" // 示例订单 ID
	orderKey := "order:" + testOrderID
	order, err := getOrderFromRedis(ctx, rdb, orderKey)
	if err != nil {
		log.Printf("获取订单 %s 时出错: %v", testOrderID, err)
	} else {
		fmt.Printf("订单 %s 信息: %+v\n", testOrderID, order)
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
	}
}

// 将订单存储到 Redis
func storeOrderInRedis(ctx context.Context, rdb *redis.Client, orderKey string, order *Order) error {
	// 使用 HSET 命令存储订单信息到 Redis 哈希表
	_, err := rdb.HSet(ctx, orderKey, map[string]interface{}{
		"customer_id": order.CustomerID,
		"product_id":  order.ProductID,
		"amount":      order.Amount,
		"status":      order.Status,
	}).Result()
	return err
}

// 从 Redis 获取订单信息
func getOrderFromRedis(ctx context.Context, rdb *redis.Client, orderKey string) (*Order, error) {
	// 使用 HGETALL 获取订单的所有字段
	result, err := rdb.HGetAll(ctx, orderKey).Result()
	if err != nil {
		return nil, err
	}

	// 如果没有找到该订单，返回错误
	if len(result) == 0 {
		return nil, fmt.Errorf("订单 %s 不存在", orderKey)
	}

	// 将结果解析为 Order 结构体
	customerID, _ := strconv.Atoi(result["customer_id"])
	productID, _ := strconv.Atoi(result["product_id"])
	amount, _ := strconv.ParseFloat(result["amount"], 64)
	status := result["status"]

	order := &Order{
		OrderID:    orderKey[6:], // 去掉 "order:" 前缀
		CustomerID: customerID,
		ProductID:  productID,
		Amount:     amount,
		Status:     status,
	}
	return order, nil
}
