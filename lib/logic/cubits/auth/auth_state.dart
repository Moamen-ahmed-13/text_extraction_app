import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthenState {}

class AuthLoading extends AuthenState {}

class AuthAuthenticated extends AuthenState {
  final User user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthenState {}

class AuthError extends AuthenState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthenState {}
