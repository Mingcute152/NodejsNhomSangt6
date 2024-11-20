// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/dang_ky.dart';
import 'package:flutter_application_3/widget/firebase/user_auth.dart';
import 'package:flutter_application_3/widget/navbar_root.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DangNhap extends StatefulWidget {
  @override
  State<DangNhap> createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap> {
  String? errorMessage = '';
  bool _isVisibility = true;
  bool _isLoading = false; // Thêm biến để hiển thị trạng thái loading

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  // Hàm đăng nhập
  Future<void> signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true; // Bắt đầu trạng thái loading
    });
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );

      // Hiển thị thông báo đăng nhập thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng nhập thành công!"),
          backgroundColor: Colors.green,
        ),
      );

      // Điều hướng đến NavBarRoots
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NavBarRoots(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Kết thúc trạng thái loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        color: whiteColor,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.all(50),
                  child: Image.asset("assets/login2.png"),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    controller: _controllerEmail,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Nhập email"),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    controller: _controllerPassword,
                    obscureText: _isVisibility, // Ẩn mật khẩu
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Nhập mật khẩu"),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            _isVisibility = !_isVisibility;
                          });
                        },
                        child: Icon(
                          _isVisibility
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye_fill,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: greenColor,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: _isLoading
                            ? null // Vô hiệu hoá nút nếu đang loading
                            : signInWithEmailAndPassword,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                          child: Center(
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color: whiteColor,
                                  )
                                : Text(
                                    "Đăng Nhập",
                                    style: TextStyle(
                                      color: whiteColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Bạn chưa có tài khoản?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: greyBoldColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Chuyển đến màn hình đăng ký
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManHinhDangKy(),
                            ));
                      },
                      child: Text(
                        "Tạo tài khoản",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
