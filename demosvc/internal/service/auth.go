package service

import (
	"context"

	pb "demosvc/api/helloworld/v1"
)

type AuthService struct {
	pb.UnimplementedAuthServer
}

func NewAuthService() *AuthService {
	return &AuthService{}
}

func (s *AuthService) SignIn(ctx context.Context, req *pb.CreateAuthRequest) (*pb.CreateAuthReply, error) {
	// redirect

	return &pb.CreateAuthReply{}, nil
}
func (s *AuthService) AuthCallback(ctx context.Context, req *pb.CreateAuthRequest) (*pb.CreateAuthReply, error) {
	return &pb.CreateAuthReply{}, nil
}
func (s *AuthService) SignOut(ctx context.Context, req *pb.CreateAuthRequest) (*pb.CreateAuthReply, error) {
	return &pb.CreateAuthReply{}, nil
}
func (s *AuthService) UpdateAuth(ctx context.Context, req *pb.UpdateAuthRequest) (*pb.UpdateAuthReply, error) {
	return &pb.UpdateAuthReply{}, nil
}
func (s *AuthService) DeleteAuth(ctx context.Context, req *pb.DeleteAuthRequest) (*pb.DeleteAuthReply, error) {
	return &pb.DeleteAuthReply{}, nil
}
func (s *AuthService) GetAuth(ctx context.Context, req *pb.GetAuthRequest) (*pb.GetAuthReply, error) {
	return &pb.GetAuthReply{}, nil
}
func (s *AuthService) ListAuth(ctx context.Context, req *pb.ListAuthRequest) (*pb.ListAuthReply, error) {
	return &pb.ListAuthReply{}, nil
}
