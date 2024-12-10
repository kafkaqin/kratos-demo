package main

import (
	"github.com/gin-gonic/gin"
	"my-gin-app/routes"
)

func main() {
	// 创建一个新的 Gin 引擎
	router := gin.Default()

	// 加载路由
	routes.LoadRoutes(router)

	// 启动服务器
	router.Run(":8080")
}
