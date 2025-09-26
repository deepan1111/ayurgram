import 'package:mongo_dart/mongo_dart.dart';
import '../models/user.dart';
import '../config/mongodb_config.dart';

class MongoDBService {
  static final MongoDBService instance = MongoDBService._internal();
  Db? _db;
  DbCollection? _users;

  MongoDBService._internal();
  factory MongoDBService() => instance;

  Future<void> init() async {
    if (_db == null || !_db!.isConnected) {
      try {
        _db = await Db.create(MongoDBConfig.connectionUri);
        await _db!.open();
        _users = _db!.collection(MongoDBConfig.userCollection);
        await _users!.createIndex(key: 'email', unique: true);
      } catch (e) {
        print('MongoDB Connection Error: $e');
        rethrow;
      }
    }
  }

  Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
    }
  }

  Future<User?> findUserByEmail(String email) async {
    try {
      await init();
      final userDoc = await _users?.findOne(where.eq('email', email));
      if (userDoc != null) {
        return User.fromMap(userDoc);
      }
      return null;
    } catch (e) {
      print('Find User Error: $e');
      rethrow;
    }
  }

  Future<User> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      await init();

      final existingUser = await findUserByEmail(email);
      if (existingUser != null) {
        throw Exception('User with this email already exists');
      }

      final user = User(
        email: email,
        hashedPassword: User.hashPassword(password),
        name: name,
        role: role,
      );

      final result = await _users?.insertOne(user.toMap());
      if (result?.isSuccess ?? false) {
        return user;
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      print('Create User Error: $e');
      rethrow;
    }
  }

  Future<User?> authenticateUser(String email, String password) async {
    try {
      await init();
      final hashedPassword = User.hashPassword(password);

      final userDoc = await _users?.findOne(
        where.eq('email', email).eq('hashedPassword', hashedPassword),
      );

      if (userDoc != null) {
        return User.fromMap(userDoc);
      }
      return null;
    } catch (e) {
      print('Authentication Error: $e');
      rethrow;
    }
  }
}
