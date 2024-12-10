package middlewares

import (
	"fmt"
	"time"

	"github.com/gin-gonic/gin"
)

// Logger 记录请求的日志
func Logger() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path
		raw := c.Request.URL.RawQuery

		// 处理请求
		c.Next()

		end := time.Since(start)
		status := c.Writer.Status()

		// 打印日志
		fmt.Printf("%s %d %s %s\n", end, status, path, raw)
	}
}
