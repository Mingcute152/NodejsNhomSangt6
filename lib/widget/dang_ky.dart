import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/firebase/user_auth.dart';

class ManHinhDangKy extends StatefulWidget {
  const ManHinhDangKy({super.key});

  @override
  State<ManHinhDangKy> createState() => _ManHinhDangKyState();
}

class _ManHinhDangKyState extends State<ManHinhDangKy> {
  String? errorMessage = '';
  bool _isVisibility = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();

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
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tạo tài khoản thành công!"),
          backgroundColor: Colors.green,
        ),
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Quay lại màn hình đăng nhập
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });

      // ignore: use_build_context_synchronously
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
                  50,
                ),
                child: Image.asset(
                  "assets/login2.png",
                ),
              ),
              const SizedBox(
                height: 10,
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
                      "Nhập mật khẩu",
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
            ],
          ),
        ),
      ),
    );
  }
}
