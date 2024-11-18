package main

import (
	"context"
	"log"
	"net/http"
	"strings"

	"github.com/coreos/go-oidc"
	"github.com/gin-gonic/gin"
	"golang.org/x/oauth2"
)

var (
	provider     *oidc.Provider
	oauth2Config oauth2.Config
	verifier     *oidc.IDTokenVerifier
)
var (
	clientID     = "my-client"
	clientSecret = "my-secret"
	redirectURI  = "http://localhost:8081/callback"
	resourceURI  = "http://localhost:8082/protected"
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

	// 初始化 Token Verifier
	verifier = provider.Verifier(&oidc.Config{
		ClientID: oauth2Config.ClientID,
	})
	// 创建 HTTP 路由
	r := gin.Default()
	r.Use(Cors())
	// 受保护的路由
	r.GET("/protected", verifyTokenMiddleware, func(c *gin.Context) {
		userInfo, _ := c.Get("userInfo")
		c.JSON(http.StatusOK, gin.H{
			"message":   "Access granted",
			"user_info": userInfo,
		})
	})

	log.Fatal(r.Run(":8082"))
}

// http://127.0.0.1:5556/dex/token/introspect
// verifyTokenMiddleware 验证 Token 的中间件
func verifyTokenMiddleware(c *gin.Context) {
	authHeader := c.Query("token")
	if !strings.HasPrefix(authHeader, "Bearer ") {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing or invalid Authorization header"})
		c.Abort()
		return
	}

	// 提取 Token
	rawToken := strings.TrimPrefix(authHeader, "Bearer ")
	//rawToken := authHeader

	// 验证 ID Token
	idToken, err := verifier.Verify(context.Background(), rawToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		c.Abort()
		return
	}
	//idToken.VerifyAccessToken()
	// 解码 Token 的 Claims
	var claims map[string]interface{}
	if err := idToken.Claims(&claims); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse token claims"})
		c.Abort()
		return
	}

	// 将用户信息存储到 Context 中
	c.Set("userInfo", claims)
	c.Next()
}
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
