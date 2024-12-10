package controllers

import (
	"github.com/gin-gonic/gin"
	"my-gin-app/models"
	"net/http"
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
