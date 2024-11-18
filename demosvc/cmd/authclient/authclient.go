package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
)

// 授权服务端配置
const (
	authServerURL    = "http://localhost:8081"
	resouceServerURL = "http://localhost:8082"
	clientID         = "client1"
	clientSecret     = "secret1"
	redirectURI      = "http://localhost:8083/callback"
)

func main() {
	// Step 1: 用户访问授权端点，获取授权码
	fmt.Println("访问以下 URL 登录并授权：")
	authURL := fmt.Sprintf("%s/authorize?client_id=%s&redirect_uri=%s&response_type=code", authServerURL, clientID, redirectURI)
	fmt.Println(authURL)

	// 模拟用户在浏览器中登录后重定向到回调地址
	fmt.Println("\n模拟重定向，请输入从重定向 URL 中截取的 code:")
	var authCode string
	fmt.Scanln(&authCode)

	// Step 2: 使用授权码请求访问令牌
	token, err := getAccessToken(authCode)
	if err != nil {
		log.Fatalf("获取访问令牌失败: %v", err)
	}

	// Step 3: 使用访问令牌访问受保护资源
	data, err := getProtectedResource(token)
	if err != nil {
		log.Fatalf("访问受保护资源失败: %v", err)
	}

	fmt.Println("\n受保护资源内容:")
	fmt.Println(data)
}

// 使用授权码获取访问令牌
func getAccessToken(authCode string) (string, error) {
	tokenURL := fmt.Sprintf("%s/token", authServerURL)
	data := url.Values{}
	data.Set("client_id", clientID)
	data.Set("client_secret", clientSecret)
	data.Set("grant_type", "authorization_code")
	data.Set("code", authCode)
	data.Set("redirect_uri", redirectURI)

	resp, err := http.PostForm(tokenURL, data)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := ioutil.ReadAll(resp.Body)
		return "", fmt.Errorf("token endpoint returned status %d: %s", resp.StatusCode, string(body))
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	// 假设服务端返回 JSON 格式的访问令牌响应
	// 示例: {"access_token":"access_token_example","token_type":"Bearer","expires_in":3600}
	var tokenResponse map[string]interface{}
	if err := json.Unmarshal(body, &tokenResponse); err != nil {
		return "", err
	}

	return tokenResponse["access_token"].(string), nil
}

// 使用访问令牌访问受保护资源
func getProtectedResource(accessToken string) (string, error) {
	resourceURL := fmt.Sprintf("%s/resource", resouceServerURL)

	req, err := http.NewRequest("GET", resourceURL, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := ioutil.ReadAll(resp.Body)
		return "", fmt.Errorf("resource endpoint returned status %d: %s", resp.StatusCode, string(body))
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	return string(body), nil
}
