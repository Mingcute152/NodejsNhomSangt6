import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/dang_nhap.dart'; // Đảm bảo bạn có widget đăng nhập này

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
        title: const Text("Tài Khoản"),
        backgroundColor: greenColor,
      ),
      body: ListView(
        children: [
          // Header section with user information
          Container(
            color: greenColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: whiteColor,
                      child: Icon(Icons.person, size: 40, color: greenColor),
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
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Column(
                      children: [
                        Icon(Icons.monetization_on,
                            color: Colors.yellow, size: 24),
                        Text("200", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Order Status Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Đơn của tôi",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Xem tất cả", style: TextStyle(color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOrderStatusButton(
                          Icons.local_shipping, "Đang xử lý"),
                      _buildOrderStatusButton(
                          Icons.directions_bike, "Đang giao"),
                      _buildOrderStatusButton(Icons.check_circle, "Đã giao"),
                      _buildOrderStatusButton(Icons.refresh, "Đổi/Trả"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Account Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tài khoản",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      _buildAccountOption(Icons.qr_code, "Mã QR của tôi"),
                      _buildAccountOption(Icons.person, "Thông tin cá nhân"),
                      _buildAccountOption(
                          Icons.location_on, "Quản lý sổ địa chỉ"),
                      _buildAccountOption(
                          Icons.credit_card, "Quản lý thẻ thanh toán"),
                      _buildAccountOption(
                          Icons.medical_services, "Đơn thuốc của tôi"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                // Xử lý đăng xuất
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DangNhap()), // Điều hướng về màn hình đăng nhập
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
                style: TextStyle(fontSize: 19, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build order status buttons
  Widget _buildOrderStatusButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: greenColor, size: 30),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Helper method to build account option rows
  Widget _buildAccountOption(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: greenColor),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Handle tap on each account option
      },
    );
  }
}
