package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"math/rand"
	"net/http"
	"net/url"
	"sync"
)

var (
	clientID     = "client1"
	clientSecret = "secret1"
	redirectURI  = "http://localhost:8083/callback"
	authCodes    = make(map[string]string) // 存储授权码
	tokens       = make(map[string]string) // 存储访问令牌
	mutex        sync.Mutex
)

func main() {
	r := gin.Default()

	// 路由定义
	r.GET("/authorize", authorizeHandler) // 授权端点
	r.POST("/token", tokenHandler)        // 令牌端点

	// 启动服务
	fmt.Println("OAuth2 服务启动，监听端口 8081...")
	r.Run(":8081")
}

// 授权端点
func authorizeHandler(c *gin.Context) {
	clientIDReq := c.Query("client_id")
	redirectURIReq := c.Query("redirect_uri")
	responseType := c.Query("response_type")

	// 验证客户端 ID 和回调地址
	if clientIDReq != clientID || redirectURIReq != redirectURI {
		c.JSON(400, gin.H{"error": "Invalid client_id or redirect_uri"})
		return
	}

	// 验证 response_type
	if responseType != "code" {
		c.JSON(400, gin.H{"error": "Invalid response_type"})
		return
	}

	// 生成授权码
	authCode := generateAuthCode()
	mutex.Lock()
	authCodes[authCode] = clientID
	mutex.Unlock()

	// 构造重定向 URL
	redirectURL, err := url.Parse(redirectURI)
	if err != nil {
		c.JSON(500, gin.H{"error": "Invalid redirect URI"})
		return
	}
	query := redirectURL.Query()
	query.Set("code", authCode)
	redirectURL.RawQuery = query.Encode()

	// 重定向到客户端回调地址
	c.Redirect(302, redirectURL.String())
}

// 令牌端点
func tokenHandler(c *gin.Context) {
	grantType := c.PostForm("grant_type")
	code := c.PostForm("code")
	clientIDReq := c.PostForm("client_id")
	clientSecretReq := c.PostForm("client_secret")

	// 验证 grant_type
	if grantType != "authorization_code" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid grant_type"})
		return
	}

	// 验证客户端 ID 和密钥
	if clientIDReq != clientID || clientSecretReq != clientSecret {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid client credentials"})
		return
	}

	// 验证授权码
	mutex.Lock()
	storedClientID, exists := authCodes[code]
	if exists {
		delete(authCodes, code) // 授权码使用后删除
	}
	mutex.Unlock()

	if !exists || storedClientID != clientID {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid or expired authorization code"})
		return
	}

	// 生成访问令牌
	accessToken := generateToken()
	mutex.Lock()
	tokens[accessToken] = clientID
	mutex.Unlock()

	// 返回访问令牌
	c.JSON(http.StatusOK, gin.H{
		"access_token": accessToken,
		"token_type":   "bearer",
		"expires_in":   3600, // 令牌过期时间（秒）
	})
}

// 生成授权码
func generateAuthCode() string {
	return fmt.Sprintf("%06d", rand.Intn(1000000))
}

// 生成访问令牌
func generateToken() string {
	return fmt.Sprintf("%x", rand.Int63())
}
