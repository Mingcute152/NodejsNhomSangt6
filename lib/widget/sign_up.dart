// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/auth_service.dart';
import 'package:flutter_application_3/theme.dart';

import 'package:flutter_application_3/widget/log_in.dart';

class ManHinhDangKy extends StatefulWidget {
  const ManHinhDangKy({super.key});

  @override
  State<ManHinhDangKy> createState() => _ManHinhDangKyState();
}

class _ManHinhDangKyState extends State<ManHinhDangKy> {
  String? errorMessage = '';
  bool _isVisibility = true;

  // Thêm controller cho trường name
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();
  final AuthService _authService = AuthService();

  // Thêm dispose để giải phóng controllers
  @override
  void dispose() {
    _controllerName.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerConfirmPassword.dispose();
    super.dispose();
  }

  Future<void> createUserWithEmailAndPassword() async {
    if (_controllerPassword.text.trim() !=
        _controllerConfirmPassword.text.trim()) {
      setState(() {
        errorMessage = "Mật khẩu không khớp!";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _authService.registerWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
        name: _controllerName.text.trim(), // Thêm field name nếu cần
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký thành công!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Quay lại màn hình đăng nhập
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(
                  60,
                ),
                child: Image.asset(
                  "assets/login2.png",
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(
                  20,
                ),
                child: TextField(
                  controller: _controllerEmail,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text(
                      "Nhập email",
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(
                  20,
                ),
                child: TextField(
                  controller: _controllerPassword,
                  obscureText: _isVisibility,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text(
                      "Nhập mật khẩu 6-12 chữ",
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                    ),
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
              Padding(
                padding: const EdgeInsets.all(
                  20,
                ),
                child: TextField(
                  controller: _controllerConfirmPassword,
                  obscureText: _isVisibility,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text(
                      "Xác nhận mật khẩu",
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(
                  10,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: greenColor,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: createUserWithEmailAndPassword,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 40,
                        ),
                        child: Center(
                          child: Text(
                            "Đăng Ký",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bạn đã có tài khoản?",
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
                            builder: (context) => DangNhap(),
                          ));
                    },
                    child: Text(
                      "Đăng nhập",
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
    );
  }
}
