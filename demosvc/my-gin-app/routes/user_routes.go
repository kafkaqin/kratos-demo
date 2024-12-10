package routes

import (
	"github.com/gin-gonic/gin"
	"my-gin-app/controllers"
	"my-gin-app/middlewares"
)

// LoadRoutes 加载所有路由
func LoadRoutes(r *gin.Engine) {
	// 注册中间件
	r.Use(middlewares.Logger())

	// 用户路由组
	userGroup := r.Group("/users")
	{
		userGroup.GET("/:id", controllers.GetUser)
		userGroup.POST("", controllers.CreateUser)
	}
}
