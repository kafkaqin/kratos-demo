package main

import (
	"database/sql"
	"reflect"
	"testing"
)

func Test_addDBPool(t *testing.T) {
	type args struct {
		dbName string
	}
	tests := []struct {
		name string
		args args
	}{
		{
			name: "1",
			args: args{
				dbName: "test",
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			addDBPool(tt.args.dbName)
		})
	}
}

func Test_getDBConnectionByKey(t *testing.T) {
	type args struct {
		key string
	}
	tests := []struct {
		name    string
		args    args
		want    *sql.DB
		wantErr bool
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := getDBConnectionByKey(tt.args.key)
			if (err != nil) != tt.wantErr {
				t.Errorf("getDBConnectionByKey() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("getDBConnectionByKey() got = %v, want %v", got, tt.want)
			}
		})
	}
}

func Test_getUserById(t *testing.T) {
	type args struct {
		userId string
	}
	tests := []struct {
		name    string
		args    args
		want    *User
		wantErr bool
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := getUserById(tt.args.userId)
			if (err != nil) != tt.wantErr {
				t.Errorf("getUserById() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("getUserById() got = %v, want %v", got, tt.want)
			}
		})
	}
}
