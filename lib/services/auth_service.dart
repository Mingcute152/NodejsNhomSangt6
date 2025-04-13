// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  // For Android emulator use 10.0.2.2
  static const String baseUrl = 'http://192.168.1.234:3001/api';

  // For physical device, use your computer's actual IP address
  // static const String baseUrl = 'http://192.168.1.234:3001/api';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw Exception("Đã xảy ra lỗi: $e");
    }
  }

  Future<String?> getToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  Future<void> logout() async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Không tìm thấy người dùng');

      final token = await user.getIdToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/auth/delete-account'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Lỗi khi xóa tài khoản');
      }

      // Xóa tài khoản Firebase Auth local
      await user.delete();

      // Đăng xuất sau khi xóa tài khoản
      await _auth.signOut();
    } catch (e) {
      print('Delete account error: $e');
      throw Exception('Lỗi khi xóa tài khoản: $e');
    }
  }

  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Gọi API login
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Đăng nhập với custom token từ server
        final userCredential = await _auth.signInWithCustomToken(data['token']);

        return userCredential;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Gọi API đăng ký
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        // Đăng ký thành công, thực hiện đăng nhập
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return userCredential;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      print('Register error: $e');
      throw Exception('Đăng ký thất bại: $e');
    }
  }
}
