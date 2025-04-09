import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/status_order.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/build_Status_Button.dart';
import 'package:flutter_application_3/widget/log_in.dart';
import 'package:flutter_application_3/controllers/firebase/user_auth.dart';
import 'package:flutter_application_3/widget/order_status_screen.dart';

class TaiKhoan extends StatefulWidget {
  const TaiKhoan({super.key});

  @override
  State<TaiKhoan> createState() => _TaiKhoanState();
}

class _TaiKhoanState extends State<TaiKhoan> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user; // Thông tin người dùng

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser; // Lấy thông tin người dùng hiện tại
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: const Text(
          "Tài khoản của tôi",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with user information
            Container(
              color: greenColor,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: whiteColor,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: greenColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user?.displayName ?? 'Chưa có tên',
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user?.phoneNumber ??
                              _user?.email ??
                              'Chưa có thông tin',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Order Status Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Đơn của tôi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildStatusButton(
                          icon: Icons.check_box_outline_blank,
                          label: 'Chưa thanh toán',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderListScreen(
                                  type: StatusOrder.chuathanhtoan.typeOrder,
                                ),
                              ),
                            );
                          },
                        ),
                        buildStatusButton(
                          icon: Icons.local_shipping,
                          label: 'Đang giao',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderListScreen(
                                  type: StatusOrder.danggiaohang.typeOrder,
                                ),
                              ),
                            );
                          },
                        ),
                        buildStatusButton(
                          icon: Icons.check_box,
                          label: 'Đã giao',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderListScreen(
                                  type: StatusOrder.dagiao.typeOrder,
                                ),
                              ),
                            );
                          },
                        ),
                        buildStatusButton(
                          icon: Icons.published_with_changes,
                          label: 'Đổi/Trả',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderListScreen(
                                  type: StatusOrder.doitra.typeOrder,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Logout and Delete Account Buttons
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DangNhap(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Đăng xuất",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await Auth().deleteAccount();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DangNhap(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: grey35Color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Xóa tài khoản",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
