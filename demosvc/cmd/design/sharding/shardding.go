package main

import (
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/stathat/consistent"
)

const (
	dbUser     = "user"
	dbPassword = "password"
	dbHost     = "localhost"
	dbPort     = "3306"
)

var (
	consistentHash *consistent.Consistent
	//dbPools        map[string]*sql.DB
	dbPools map[string]string
)

func init() {
	// 初始化一致性哈希实例
	consistentHash = consistent.New()

	// 初始化数据库连接池
	//dbPools = make(map[string]*sql.DB)
	dbPools = make(map[string]string)
}

func addDBPool(dbName string) {
	// 添加数据库实例到一致性哈希
	consistentHash.Add(dbName)

	// 创建数据库连接池并添加到 dbPools
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local", dbUser, dbPassword, dbHost, dbPort, dbName)
	//db, err := sql.Open("mysql", dsn)
	//if err != nil {
	//	panic(err)
	//}

	dbPools[dbName] = dsn
}

// func getDBConnectionByKey(key string) (*sql.DB, error) {
func getDBConnectionByKey(key string) (string, error) {
	dbName, err := consistentHash.Get(key)
	if err != nil {
		return "", err
	}

	db, ok := dbPools[dbName]
	if !ok {
		return "", fmt.Errorf("no db connection found for dbName: %s", dbName)
	}
	fmt.Println("key==", key, dbName)
	return db, nil
}

type User struct {
	Id    int
	Name  string
	Email string
}

func getUserById(userId string) (*User, error) {
	db, err := getDBConnectionByKey(userId)
	if err != nil {
		return nil, err
	}
	fmt.Println("db connection", db)
	user := &User{}
	//err = db.QueryRow("SELECT id, name, email FROM users WHERE id = ?", userId).Scan(&user.Id, &user.Name, &user.Email)
	//if err != nil {
	//	return nil, err
	//}

	return user, nil
}

func main() {
	addDBPool("demo-01")
	addDBPool("demo-02")
	addDBPool("demo-03")
	_, _ = getDBConnectionByKey("demo-01-user")
	_, _ = getDBConnectionByKey("demo-02-user")
	_, _ = getDBConnectionByKey("demo-03-user")
	_, _ = getDBConnectionByKey("demo-04-user")
}
