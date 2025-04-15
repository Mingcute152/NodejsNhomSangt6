// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_3/model/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String baseUrl = 'http://192.168.1.234:3001/api';

  // Thêm phương thức getToken
  Future<String> getToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        return token ?? '';
      }
      throw Exception('User not authenticated');
    } catch (e) {
      print('Error getting token: $e');
      throw Exception('Failed to get authentication token');
    }
  }

  Future<void> saveShippingAddress(String address) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'shippingAddress': address,
        });
      }
    } catch (e) {
      throw Exception("Lỗi khi lưu địa chỉ: $e");
    }
  }

  Future<String?> getShippingAddress() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final doc = await _firestore.collection('users').doc(userId).get();
        return doc.data()?['shippingAddress'] as String?;
      }
    } catch (e) {
      throw Exception("Lỗi khi lấy địa chỉ: $e");
    }
    return null;
  }

  Future<UserModel> getUserProfile() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(user.toMap()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
}
