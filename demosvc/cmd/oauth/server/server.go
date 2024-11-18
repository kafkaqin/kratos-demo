package main

import (
	"context"
	"fmt"
	"github.com/coreos/go-oidc"
	"github.com/gin-gonic/gin"
	"golang.org/x/oauth2"
	"log"
	"net/http"
)

var (
	clientID     = "my-client"
	clientSecret = "my-secret"
	redirectURI  = "http://localhost:8081/callback"
	resourceURI  = "http://localhost:8082/protected"
	provider     *oidc.Provider
	oauth2Config oauth2.Config
	dexAuthURL   = "http://127.0.0.1:5556/dex"
)

func main() {
	ctx := context.Background()

	// 设置一个内存中的OIDC Provider，生产中可对接外部服务
	var err error
	provider, err = oidc.NewProvider(ctx, dexAuthURL)
	if err != nil {
		log.Fatalf("Failed to create OIDC provider: %v", err)
	}

	// 配置 OAuth2
	oauth2Config = oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		RedirectURL:  redirectURI,
		Endpoint:     provider.Endpoint(),
		Scopes:       []string{oidc.ScopeOpenID, "profile", "email"},
	}

	router := gin.Default()
	router.Use(Cors())
	// 路由设置
	router.GET("/auth", handleAuth)
	router.GET("/login", Login)
	router.GET("/callback", handleCallback)
	router.POST("/token", handleToken)
	router.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Welcome to OAuth2 Server!",
		})
	})

	log.Println("OAuth2 server running on http://localhost:8081")
	router.Run(":8081")
}

func handleAuth(c *gin.Context) {
	// 构造授权URL
	authURL := oauth2Config.AuthCodeURL("state-xyz", oauth2.AccessTypeOffline)
	c.Redirect(http.StatusFound, authURL)
}

func Login(ctx *gin.Context) {
	authURL := fmt.Sprintf("http://127.0.0.1:5556?client_id=%s&redirect_uri=%s&response_type=code&scope=openid", clientID, redirectURI)
	ctx.Redirect(http.StatusFound, authURL)
}

func handleCallback(c *gin.Context) {
	// 获取授权码
	code := c.Query("code")
	if code == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Authorization code not provided"})
		return
	}

	// 交换访问令牌
	token, err := oauth2Config.Exchange(context.Background(), code)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to exchange token: %v", err)})
		return
	}

	// 提取用户信息
	idToken, ok := token.Extra("id_token").(string)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "ID token not found"})
		return
	}

	oidcConfig := &oidc.Config{ClientID: clientID}
	verifier := provider.Verifier(oidcConfig)
	_, err = verifier.Verify(context.Background(), idToken)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to verify ID token: %v", err)})
		return
	}

	c.Header("Authorization", fmt.Sprintf("Bearer %s", idToken))
	c.Redirect(http.StatusFound, resourceURI+"?token=Bearer "+token.AccessToken)
	//c.JSON(http.StatusOK, gin.H{
	//	"access_token":  token.AccessToken,
	//	"refresh_token": token.RefreshToken,
	//	"id_token":      idToken,
	//	"expiry":        token.Expiry,
	//})
}

func handleToken(c *gin.Context) {
	var params struct {
		GrantType string `json:"grant_type"`
		Code      string `json:"code"`
	}

	if err := c.ShouldBindJSON(&params); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	if params.GrantType != "authorization_code" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Unsupported grant type"})
		return
	}

	// 交换访问令牌
	token, err := oauth2Config.Exchange(context.Background(), params.Code)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to exchange token: %v", err)})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"access_token":  token.AccessToken,
		"refresh_token": token.RefreshToken,
		"expiry":        token.Expiry,
	})
}

//	func loginHandler(w http.ResponseWriter, r *http.Request) {
//		authURL := fmt.Sprintf("%s?client_id=%s&redirect_uri=%s&response_type=code&scope=openid", dexAuthURL, clientID, redirectURI)
//		http.Redirect(w, r, authURL, http.StatusFound)
//	}
func Cors() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")                                              // 允许所有来源，生产环境建议指定域名
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")               // 允许的 HTTP 方法
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With") // 允许的请求头
		c.Header("Access-Control-Expose-Headers", "Content-Length, Content-Type")                 // 暴露的响应头
		c.Header("Access-Control-Allow-Credentials", "true")                                      // 允许跨域携带凭证（如 cookies）

		// 如果是预检请求，直接返回状态码 204
		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}
