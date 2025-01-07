// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';
// ignore: unused_import
import 'package:flutter_application_3/widget/dang_nhap.dart';
// ignore: unused_import
import 'package:flutter_application_3/widget/dang_ky.dart';
class TaiKhoan extends StatefulWidget {
  @override
  State<TaiKhoan> createState() => _TaiKhoanState();
}

class _TaiKhoanState extends State<TaiKhoan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // Header section with user information
          Container(
            color: greenColor,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: whiteColor,
                      child: Icon(Icons.person, size: 40, color: greenColor),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Hoàng Minh",
                          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "0906 680 225",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: const [
                        Icon(Icons.monetization_on, color: Colors.yellow, size: 24),
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
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Đơn của tôi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Xem tất cả", style: TextStyle(color: Colors.blue)),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
<<<<<<< refs/remotes/origin/main
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOrderStatusButton(Icons.local_shipping, "Đang xử lý"),
                      _buildOrderStatusButton(Icons.directions_bike, "Đang giao"),
                      _buildOrderStatusButton(Icons.check_circle, "Đã giao"),
                      _buildOrderStatusButton(Icons.refresh, "Đổi/Trả"),
                    ],
=======
                  height: 70,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderListScreen(
                                  type: StatusOrder.chuathanhtoan.typeOrder,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.check_box_outline_blank,
                            color: Colors.green,
                          ),
                          label: const Text('Chưa thanh toán'),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderListScreen(
                                  type: StatusOrder.danggiaohang.typeOrder,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.local_shipping,
                              color: Colors.green),
                          label: const Text('Đang giao'),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderListScreen(
                                  type: StatusOrder.dagiao.typeOrder,
                                ),
                              ),
                            );
                          },
                          icon:
                              const Icon(Icons.check_box, color: Colors.green),
                          label: const Text('Đã giao'),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderListScreen(
                                  type: StatusOrder.doitra.typeOrder,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.published_with_changes,
                              color: Colors.green),
                          label: const Text('Đổi/Trả'),
                        ),
                      ],
                    ),
>>>>>>> local
                  ),
                ),
              ],
            ),
          ),

<<<<<<< refs/remotes/origin/main
          // Account Section
=======
          // Favorite Products Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                // Thêm logic mở danh sách sản phẩm yêu thích tại đây
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Sản phẩm yêu thích",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Logout Button
>>>>>>> local
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tài khoản", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      _buildAccountOption(Icons.qr_code, "Mã QR của tôi"),
                      _buildAccountOption(Icons.person, "Thông tin cá nhân"),
                      _buildAccountOption(Icons.location_on, "Quản lý sổ địa chỉ"),
                      _buildAccountOption(Icons.credit_card, "Quản lý thẻ thanh toán"),
                      _buildAccountOption(Icons.medical_services, "Đơn thuốc của tôi"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Handle logout functionality here
                Navigator.pushReplacementNamed(context, '/login'); // Example: Navigate to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Đăng xuất",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, // Index for "Tài khoản"
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Điểm thưởng"),
          BottomNavigationBarItem(icon: Icon(Icons.support), label: "Tư vấn"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Giỏ hàng"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
    );
  }
<<<<<<< refs/remotes/origin/main

  // Helper method to build order status buttons
  Widget _buildOrderStatusButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: greenColor, size: 30),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // Helper method to build account option rows
  Widget _buildAccountOption(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: greenColor),
      title: Text(label),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Handle tap on each account option
      },
    );
  }
}
=======
}
>>>>>>> local
