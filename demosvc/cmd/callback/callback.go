package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/callback", func(w http.ResponseWriter, r *http.Request) {
		fmt.Println("=====================================")
		code := r.URL.Query().Get("code")
		if code == "" {
			w.WriteHeader(http.StatusBadRequest)
			fmt.Fprintln(w, "No authorization code provided")
			return
		}
		fmt.Fprintf(w, "Authorization code received: %s\n", code)
	})

	fmt.Println("Callback 服务启动，监听端口 8083...")
	http.ListenAndServe(":8083", nil)
}

//func loginHandler(w http.ResponseWriter, r *http.Request) {
//	authURL := fmt.Sprintf("%s?client_id=%s&redirect_uri=%s&response_type=code&scope=openid", dexAuthURL, clientID, redirectURI)
//	http.Redirect(w, r, authURL, http.StatusFound)
//}
