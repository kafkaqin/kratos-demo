//go:build wireinject
// +build wireinject

package main

import "github.com/google/wire"

func InitializeApp() (*Application, error) {
	wire.Build(NewDatabase, NewService, NewApplication)
	return nil, nil // wire 会生成代码替换此行
}
