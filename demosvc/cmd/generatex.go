package main

import (
	"fmt"
	"os"
	"text/template"
)

// 定义模板
var mainTemplate = `package main

import (
	"{{.PackageName}}/routes"
	"github.com/gin-gonic/gin"
)

func main() {
	// 创建一个新的 Gin 引擎
	router := gin.Default()

	// 加载路由
	routes.LoadRoutes(router)

	// 启动服务器
	router.Run(":8080")
}
`

var userControllerTemplate = `package controllers

import (
	"net/http"
	"{{.PackageName}}/models"
	"github.com/gin-gonic/gin"
)

// GetUser 获取用户信息
func GetUser(c *gin.Context) {
	id := c.Param("id")
	user := models.User{ID: id, Name: "John Doe", Email: "john@example.com"}
	c.JSON(http.StatusOK, gin.H{"data": user})
}

// CreateUser 创建新用户
func CreateUser(c *gin.Context) {
	var user models.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"data": user})
}
`

var userModelTemplate = `package models

type User struct {
	ID    string ` + "`json:\"id\"`" + `
	Name  string ` + "`json:\"name\"`" + `
	Email string ` + "`json:\"email\"`" + `
}
`

var loggerTemplate = `package middlewares

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
`

var userRoutesTemplate = `package routes

import (
	"{{.PackageName}}/controllers"
	"{{.PackageName}}/middlewares"
	"github.com/gin-gonic/gin"
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
`

// 生成文件
func generateFile(filePath, templateStr, packageName string) error {
	tmpl, err := template.New("file").Parse(templateStr)
	if err != nil {
		return err
	}

	file, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	data := map[string]string{
		"PackageName": packageName,
	}

	err = tmpl.Execute(file, data)
	if err != nil {
		return err
	}

	return nil
}

// 主函数
func main() {
	packageName := "my-gin-app"

	// 创建项目目录
	os.MkdirAll(packageName+"/controllers", 0755)
	os.MkdirAll(packageName+"/models", 0755)
	os.MkdirAll(packageName+"/middlewares", 0755)
	os.MkdirAll(packageName+"/routes", 0755)

	// 生成 main.go
	generateFile(packageName+"/main.go", mainTemplate, packageName)

	// 生成 controllers/user_controller.go
	generateFile(packageName+"/controllers/user_controller.go", userControllerTemplate, packageName)

	// 生成 models/user_model.go
	generateFile(packageName+"/models/user_model.go", userModelTemplate, packageName)

	// 生成 middlewares/logger.go
	generateFile(packageName+"/middlewares/logger.go", loggerTemplate, packageName)

	// 生成 routes/user_routes.go
	generateFile(packageName+"/routes/user_routes.go", userRoutesTemplate, packageName)

	fmt.Println("Project generated successfully!")
}
