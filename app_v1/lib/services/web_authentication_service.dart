import 'authentication_service.dart';
import '../models/user.dart';
import 'package:mongo_dart/mongo_dart.dart';

class WebAuthenticationService implements AuthenticationService {
  static final WebAuthenticationService instance =
      WebAuthenticationService._internal();
  factory WebAuthenticationService() => instance;
  WebAuthenticationService._internal();

  // In-memory storage for demo/testing purposes
  final Map<String, User> _users = {};

  @override
  Future<User?> authenticateUser(String email, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    final user = _users[email];
    if (user != null && user.hashedPassword == User.hashPassword(password)) {
      return user;
    }
    return null;
  }

  @override
  Future<User> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    if (_users.containsKey(email)) {
      throw Exception('User with this email already exists');
    }

    final user = User(
      id: ObjectId(),
      email: email,
      hashedPassword: User.hashPassword(password),
      name: name,
      role: role,
    );

    _users[email] = user;
    return user;
  }

  @override
  Future<User?> findUserByEmail(String email) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    return _users[email];
  }
}
