// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/widget/log_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Đăng nhập bằng Email và Mật khẩu
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  // Đăng ký bằng Email và Mật khẩu
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> deleteAccount() async {
    try {
      User? user = _firebaseAuth.currentUser;

      await user?.delete();

      // // Điều hướng về màn hình đăng nhập hoặc xử lý tiếp
      // Navigator.of(context).pushReplacementNamed('/login');
      // ignore: empty_catches
    } on FirebaseAuthException {}
  }

  // Kiểm tra xem người dùng có phải là admin không
  Future<bool> isAdmin() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      // Giả sử bạn lưu thông tin admin trong custom claims hoặc Firestore
      // Thay thế đoạn này bằng logic kiểm tra admin thực tế
      final idTokenResult = await user.getIdTokenResult();
      return idTokenResult.claims?['admin'] == true;
    }
    return false;
  }

  // Thêm sản phẩm (chỉ dành cho admin)
  Future<void> addProduct({
    required String productName,
    required double price,
    required String description,
  }) async {
    if (await isAdmin()) {
      // Giả sử bạn lưu sản phẩm trong Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('products').add({
        'name': productName,
        'price': price,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      throw "Bạn không có quyền thêm sản phẩm.";
    }
  }
}
