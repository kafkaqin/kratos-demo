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

	// 模拟插入一百万个订单
	//for i := 1; i <= 1000000; i++ { // 这里模拟插入 100 万个订单
	//	order := generateOrder(i)
	//
	//	// 将订单信息存储到 Redis 集合中
	//	// 1. 将订单ID加入到与客户ID相关的集合中
	//	err := storeOrderInCustomerSet(ctx, rdb, order)
	//	if err != nil {
	//		log.Printf("存储订单 %s 时出错: %v", order.OrderID, err)
	//	}
	//
	//	// 2. 将订单ID加入到与产品ID相关的集合中
	//	err = storeOrderInProductSet(ctx, rdb, order)
	//	if err != nil {
	//		log.Printf("存储订单 %s 时出错: %v", order.OrderID, err)
	//	}
	//
	//	// 每 1000 个订单打印一次进度
	//	if i%1000 == 0 {
	//		fmt.Printf("已存储 %d 个订单\n", i)
	//	}
	//}

	// 测试查询某个客户的所有订单
	testCustomerID := 1015
	customerOrders, err := getOrdersByCustomer(ctx, rdb, testCustomerID)
	if err != nil {
		log.Printf("获取客户 %d 的订单时出错: %v", testCustomerID, err)
	} else {
		fmt.Printf("客户 %d 的所有订单:\n", testCustomerID)
		for _, orderID := range customerOrders {
			fmt.Println(orderID)
		}
	}

	// 查询某个产品的所有订单
	testProductID := 107
	productOrders, err := getOrdersByProduct(ctx, rdb, testProductID)
	if err != nil {
		log.Printf("获取产品 %d 的订单时出错: %v", testProductID, err)
	} else {
		fmt.Printf("产品 %d 的所有订单:\n", testProductID)
		for _, orderID := range productOrders {
			fmt.Println(orderID)
		}
	}

	// 查询两个集合的交集（即，既是客户 12345 的订单又是产品 6789 的订单）
	ordersIntersection, err := getOrdersIntersectionByCustomerAndProduct(ctx, rdb, testCustomerID, testProductID)
	if err != nil {
		log.Printf("获取客户 %d 和产品 %d 的交集订单时出错: %v", testCustomerID, testProductID, err)
	} else {
		fmt.Printf("客户 %d 和产品 %d 的交集订单:\n", testCustomerID, testProductID)
		for _, orderID := range ordersIntersection {
			fmt.Println(orderID)
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

// 将订单存储到 Redis 客户ID的集合中
func storeOrderInCustomerSet(ctx context.Context, rdb *redis.Client, order *Order) error {
	// 使用客户ID作为集合的键，将订单ID作为成员
	customerSetKey := fmt.Sprintf("customer:%d:orders", order.CustomerID)
	_, err := rdb.SAdd(ctx, customerSetKey, order.OrderID).Result()
	return err
}

// 将订单存储到 Redis 产品ID的集合中
func storeOrderInProductSet(ctx context.Context, rdb *redis.Client, order *Order) error {
	// 使用产品ID作为集合的键，将订单ID作为成员
	productSetKey := fmt.Sprintf("product:%d:orders", order.ProductID)
	_, err := rdb.SAdd(ctx, productSetKey, order.OrderID).Result()
	return err
}

// 查询某个客户的所有订单
func getOrdersByCustomer(ctx context.Context, rdb *redis.Client, customerID int) ([]string, error) {
	// 获取客户相关的集合
	customerSetKey := fmt.Sprintf("customer:%d:orders", customerID)
	orderIDs, err := rdb.SMembers(ctx, customerSetKey).Result()
	if err != nil {
		return nil, err
	}
	return orderIDs, nil
}

// 查询某个产品的所有订单
func getOrdersByProduct(ctx context.Context, rdb *redis.Client, productID int) ([]string, error) {
	// 获取产品相关的集合
	productSetKey := fmt.Sprintf("product:%d:orders", productID)
	orderIDs, err := rdb.SMembers(ctx, productSetKey).Result()
	if err != nil {
		return nil, err
	}
	return orderIDs, nil
}

// 获取客户和产品的交集订单（即既是客户的订单又是产品的订单）
func getOrdersIntersectionByCustomerAndProduct(ctx context.Context, rdb *redis.Client, customerID, productID int) ([]string, error) {
	// 获取客户和产品相关的集合
	customerSetKey := fmt.Sprintf("customer:%d:orders", customerID)
	productSetKey := fmt.Sprintf("product:%d:orders", productID)

	// 获取客户和产品的交集
	orderIDs, err := rdb.SInter(ctx, customerSetKey, productSetKey).Result()
	if err != nil {
		return nil, err
	}
	return orderIDs, nil
}
