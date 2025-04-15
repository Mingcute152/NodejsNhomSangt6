// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class AuthService extends GetxService {
  // For Android emulator use 10.0.2.2
  static const String baseUrl = 'http://192.168.1.234:3001/api';

  // For physical device, use your computer's actual IP address
  // static const String baseUrl = 'http://192.168.1.234:3001/api';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Duration timeout = const Duration(seconds: 10);
  final int maxRetries = 3;

  Future<http.Response> _makeRequest(
    String method,
    String endpoint,
    Map<String, dynamic>? body,
    String? token,
  ) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        final headers = {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        };

        final uri = Uri.parse('$baseUrl$endpoint');
        http.Response response;

        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: headers).timeout(timeout);
            break;
          case 'POST':
            response = await http
                .post(
                  uri,
                  headers: headers,
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(timeout);
            break;
          case 'PUT':
            response = await http
                .put(
                  uri,
                  headers: headers,
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(timeout);
            break;
          case 'DELETE':
            response =
                await http.delete(uri, headers: headers).timeout(timeout);
            break;
          default:
            throw Exception('Unsupported HTTP method');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        // Nếu là lỗi 401 (Unauthorized), không thử lại
        if (response.statusCode == 401) {
          throw Exception('Unauthorized');
        }

        // Nếu là lỗi khác, thử lại
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: 1 * retryCount));
          continue;
        }

        throw Exception('Request failed after $maxRetries attempts');
      } catch (e) {
        if (e is Exception && e.toString().contains('timeout')) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: 1 * retryCount));
            continue;
          }
        }
        rethrow;
      }
    }
    throw Exception('Request failed after $maxRetries attempts');
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<String?> getToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  Future<void> logout() async {
    try {
      final idToken = await _auth.currentUser?.getIdToken();
      if (idToken != null) {
        await _makeRequest('POST', '/auth/logout', null, idToken);
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final idToken = await _auth.currentUser?.getIdToken();
      if (idToken != null) {
        await _makeRequest('DELETE', '/auth/delete-account', null, idToken);
      }
      await _auth.currentUser?.delete();
    } catch (e) {
      throw Exception('Account deletion failed: $e');
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
