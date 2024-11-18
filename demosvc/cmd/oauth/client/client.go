package main

import (
	"io/ioutil"
	"net/http"
)

func main() {
	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/callback", callbackHandler)
	http.HandleFunc("/user", userHandler)
	log.Fatal(http.ListenAndServe(":8090", nil))
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	http.Redirect(w, r, cfg.AuthCodeURL("state", oauth2.AccessTypeOnline), http.StatusFound)
}

func callbackHandler(w http.ResponseWriter, r *http.Request) {
	code := r.URL.Query().Get("code")
	if code == "" {
		http.Error(w, "Missing authorization code", http.StatusBadRequest)
		return
	}

	token, err := cfg.Exchange(context.Background(), code)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	http.SetCookie(w, &http.Cookie{
		Name:  "access_token",
		Value: token.AccessToken,
	})

	http.Redirect(w, r, "/", http.StatusFound)
}

func userHandler(w http.ResponseWriter, r *http.Request) {
	accessToken, err := r.Cookie("access_token")
	if err != nil {
		http.Redirect(w, r, "/login", http.StatusFound)
		return
	}

	resp, err := http.Get("http://localhost:8081/user?access_token=" + accessToken.Value)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Write(body)
}
