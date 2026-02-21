import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final int count;

  const AuthState({required this.count});

  @override
  List<Object?> get props => [count];

  AuthState copyWith({int? count}) {
    return AuthState(count: count ?? this.count);
  }
}