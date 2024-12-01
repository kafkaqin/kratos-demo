package main

import (
	"fmt"
	"unsafe"
)

// 定义内存池结构
type ObjectPool struct {
	freeList []unsafe.Pointer
}

// 初始化对象池
func NewObjectPool() *ObjectPool {
	return &ObjectPool{
		freeList: make([]unsafe.Pointer, 0),
	}
}

// 从池中获取对象
func (pool *ObjectPool) Get() unsafe.Pointer {
	if len(pool.freeList) > 0 {
		// 如果池中有对象，则从池中获取
		obj := pool.freeList[len(pool.freeList)-1]
		pool.freeList = pool.freeList[:len(pool.freeList)-1]
		return obj
	}
	// 如果池为空，返回 nil
	return nil
}

// 将对象放回池中
func (pool *ObjectPool) Put(obj unsafe.Pointer) {
	pool.freeList = append(pool.freeList, obj)
}

// 创建一个新的 int 类型的对象
func newInt() *int {
	x := 42
	return &x
}

// 创建一个新的 string 类型的对象
func newString() *string {
	str := "Hello, Go!"
	return &str
}

func main() {
	// 创建对象池
	pool := NewObjectPool()

	// 创建并放入一个 int 类型对象
	intPtr := newInt()
	pool.Put(unsafe.Pointer(intPtr))

	// 创建并放入一个 string 类型对象
	strPtr := newString()
	pool.Put(unsafe.Pointer(strPtr))

	// 从池中取回对象并进行类型转换
	obj1 := pool.Get()
	if obj1 != nil {
		intObj := (*string)(obj1) // 类型转换
		fmt.Printf("Got an string from pool: %s\n", *intObj)
	} else {
		fmt.Println("Got nil for string from pool!")
	}

	// 从池中取回另一个对象并进行类型转换
	obj2 := pool.Get()
	if obj2 != nil {
		strObj := (*int)(obj2) // 类型转换
		fmt.Printf("Got a int from pool: %d\n", *strObj)
	} else {
		fmt.Println("Got nil for int from pool!")
	}

	// 再次放回池中
	pool.Put(unsafe.Pointer(intPtr))
	pool.Put(unsafe.Pointer(strPtr))
}
