package main

import (
	"fmt"
	"strconv"
)

type Flyweight interface {
	Draw(x, y int)
}

type Circle struct {
	color  string
	radius int
}

func (c *Circle) Draw(x, y int) {
	fmt.Printf("Circle Draw: x=%d, y=%d\n", x, y)
}

type CircleFactory struct {
	circles map[string]*Circle
}

func NewCircleFactory() *CircleFactory {
	return &CircleFactory{
		circles: make(map[string]*Circle),
	}
}

func (f *CircleFactory) GetCircle(color string, radius int) *Circle {
	key := color + ":" + strconv.Itoa(radius)
	if circle, ok := f.circles[key]; ok {
		return circle
	}
	circle := &Circle{
		color:  color,
		radius: radius,
	}

	f.circles[key] = circle
	return circle
}

func main() {
	factory := NewCircleFactory()
	circleRed := factory.GetCircle("red", 10)
	circleRed.Draw(10, 20)
	circleGreen := factory.GetCircle("green", 10)

	circleGreen.Draw(10, 20)

	circleRed1 := factory.GetCircle("red", 10)
	circleRed1.Draw(80, 60)

	fmt.Println(len(factory.circles))
}
