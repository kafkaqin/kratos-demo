package main

import (
	"context"
	"fmt"
	"github.com/redis/go-redis/v9"
	"log"
	"time"
)

// 订单操作类型
type OrderAction struct {
	Action    string // 操作类型（支付、退款等）
	OrderID   string // 订单 ID
	Timestamp int64  // 操作时间戳
	Details   string // 操作的详细信息（例如支付金额、退款金额等）
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

	// 模拟记录订单操作日志
	orderID := "order_12345"
	//recordOrderAction(ctx, rdb, orderID, "payment", "支付成功，金额 $100")
	//recordOrderAction(ctx, rdb, orderID, "refund", "退款成功，金额 $50")
	//recordOrderAction(ctx, rdb, orderID, "shipment", "订单已发货")

	// 查询订单的操作日志
	actions, err := getOrderActions(ctx, rdb, orderID)
	if err != nil {
		log.Fatalf("获取订单操作日志时出错: %v", err)
	}

	// 输出订单的操作日志
	fmt.Printf("订单 %s 的操作日志:\n", orderID)
	for _, action := range actions {
		fmt.Println(action)
	}
}

// 记录订单的操作日志
func recordOrderAction(ctx context.Context, rdb *redis.Client, orderID, action, details string) {
	actionRecord := &OrderAction{
		Action:    action,
		OrderID:   orderID,
		Timestamp: time.Now().Unix(),
		Details:   details,
	}

	// 将操作记录插入到订单操作日志的列表中，列表键为 "order:{orderID}:actions"
	logKey := fmt.Sprintf("order:%s:actions", orderID)

	// 使用 LPUSH 将新操作记录插入到列表的左侧（即最新的操作在前）
	_, err := rdb.LPush(ctx, logKey, formatAction(actionRecord)).Result()
	if err != nil {
		log.Printf("记录订单操作日志失败: %v", err)
	}
}

// 获取订单的操作日志
func getOrderActions(ctx context.Context, rdb *redis.Client, orderID string) ([]string, error) {
	// 获取订单操作日志列表的键
	logKey := fmt.Sprintf("order:%s:actions", orderID)

	// 获取操作日志列表中的所有记录，LRANGE 返回列表中的一个子集，-1 表示获取到列表的尾部
	actions, err := rdb.LRange(ctx, logKey, 0, -1).Result()
	if err != nil {
		return nil, err
	}
	return actions, nil
}

// 格式化订单操作日志为字符串（便于存储）
func formatAction(action *OrderAction) string {
	return fmt.Sprintf("%d|%s|%s|%s", action.Timestamp, action.Action, action.OrderID, action.Details)
}
