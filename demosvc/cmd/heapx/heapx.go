package main

import (
	"fmt"
)

type MinHeap struct {
	data []int
}

// 插入元素
func (h *MinHeap) Insert(value int) {
	h.data = append(h.data, value)
	h.bubbleUp(len(h.data) - 1)
}

// 上浮操作
func (h *MinHeap) bubbleUp(index int) {
	for index > 0 && h.data[parent(index)] > h.data[index] {
		h.swap(parent(index), index)
		index = parent(index)
	}
}

// 删除最小元素
func (h *MinHeap) ExtractMin() int {
	if len(h.data) == 0 {
		panic("Heap is empty")
	}
	min := h.data[0]
	lastIndex := len(h.data) - 1
	h.data[0] = h.data[lastIndex]
	h.data = h.data[:lastIndex]
	h.bubbleDown(0)
	return min
}

// 下沉操作
func (h *MinHeap) bubbleDown(index int) {
	n := len(h.data)
	for {
		left, right := leftChild(index), rightChild(index)
		smallest := index
		if left < n && h.data[left] < h.data[smallest] {
			smallest = left
		}
		if right < n && h.data[right] < h.data[smallest] {
			smallest = right
		}
		if smallest == index {
			break
		}
		h.swap(index, smallest)
		index = smallest
	}
}

// 交换两个元素
func (h *MinHeap) swap(i, j int) {
	h.data[i], h.data[j] = h.data[j], h.data[i]
}

// 获取父节点索引
func parent(i int) int {
	return (i - 1) / 2
}

// 获取左子节点索引
func leftChild(i int) int {
	return 2*i + 1
}

// 获取右子节点索引
func rightChild(i int) int {
	return 2*i + 2
}

func main() {
	heap := &MinHeap{}
	heap.Insert(3)
	heap.Insert(1)
	heap.Insert(4)
	heap.Insert(1)
	heap.Insert(5)
	heap.Insert(9)
	heap.Insert(2)
	heap.Insert(6)
	heap.Insert(5)
	heap.Insert(3)

	fmt.Println("Heap:", heap.data)
	fmt.Println("Extracting min:", heap.ExtractMin())
	fmt.Println("Heap after extraction:", heap.data)
}
