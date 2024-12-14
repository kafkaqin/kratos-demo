package main

import (
	"fmt"
	"log"
	"sync"
	"time"
)

// TimelineEvent 代表一个时间线事件
type TimelineEvent struct {
	ID        string    // 事件ID
	Type      string    // 事件类型 (如消息、通知等)
	Content   string    // 事件内容
	Timestamp time.Time // 事件时间
}

func NewTimelineEvent(id, eventType, content string) *TimelineEvent {
	return &TimelineEvent{
		ID:        id,
		Type:      eventType,
		Content:   content,
		Timestamp: time.Now(),
	}
}

// Timeline 代表一个用户的时间线
type Timeline struct {
	UserID string           // 用户ID
	Events []*TimelineEvent // 该用户的时间线事件
	mu     sync.Mutex       // 锁，用于并发安全
}

func main() {
	// 连接到 NATS 服务器
	nc, err := nats.Connect(nats.DefaultURL)
	if err != nil {
		log.Fatal(err)
	}
	defer nc.Close()

	// 发布事件到 "timeline" 频道
	msg := "New event in your timeline!"
	err = nc.Publish("timeline", []byte(msg))
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Published event:", msg)

	// 订阅 "timeline" 频道
	nc.Subscribe("timeline", func(msg *nats.Msg) {
		fmt.Println("Received message:", string(msg.Data))
	})

	// 保持连接
	select {}
}
