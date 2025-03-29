import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/status_order.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/build_Status_Button.dart';
import 'package:flutter_application_3/widget/dang_nhap.dart';
import 'package:flutter_application_3/widget/firebase/user_auth.dart';
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
        toolbarHeight: 10,
      ),
      body: ListView(
        children: [
          // Header section with user information
          Container(
            color: greenColor,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: whiteColor,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: greenColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user?.displayName ?? 'Chưa có tên',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _user?.phoneNumber ??
                              _user?.email ??
                              'Chưa có thông tin',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),

          // Order Status Section
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Đơn của tôi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 80,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Nút: Chưa thanh toán
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
                        const SizedBox(width: 20),

                        // Nút: Đang giao
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
                        const SizedBox(width: 20),

                        // Nút: Đã giao
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
                        const SizedBox(width: 20),

                        // Nút: Đổi/Trả
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
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 330,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (_) => DangNhap(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Đăng xuất",
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await Auth().deleteAccount();
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (_) => DangNhap(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: grey35Color,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Xóa tài khoản",
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
