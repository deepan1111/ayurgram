import '../models/user.dart';

abstract class AuthenticationService {
  Future<User?> authenticateUser(String email, String password);
  Future<User> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
  });
  Future<User?> findUserByEmail(String email);
}
