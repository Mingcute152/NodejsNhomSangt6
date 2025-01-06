import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/widget/dang_nhap.dart';

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

  // Đăng nhập bằng Số điện thoại và mã OTP
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Tự động đăng nhập nếu OTP được xác nhận tự động
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e.message ?? "Đã xảy ra lỗi khi xác minh số điện thoại.";
      },
      codeSent: (String verificationId, int? resendToken) {
        // Lưu lại verificationId để xác nhận mã OTP
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Timeout xử lý mã OTP
        this.verificationId = verificationId;
      },
    );
  }

  // Xác nhận mã OTP
  Future<void> verifyOtp({
    required String otp,
  }) async {
    if (verificationId != null) {
      final credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: otp);
      await _firebaseAuth.signInWithCredential(credential);
    } else {
      throw "Không tìm thấy mã xác minh!";
    }
  }

  // Biến để lưu lại verificationId khi mã OTP được gửi
  String? verificationId;

  Future<void> deleteAccount() async {
    try {
      User? user = _firebaseAuth.currentUser;

      await user?.delete();

      // // Điều hướng về màn hình đăng nhập hoặc xử lý tiếp
      // Navigator.of(context).pushReplacementNamed('/login');
    } on FirebaseAuthException catch (e) {
    } catch (e) {}
  }
}
