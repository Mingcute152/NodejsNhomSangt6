// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/status_order.dart';
import 'package:flutter_application_3/services/auth_service.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/build_Status_Button.dart';
import 'package:flutter_application_3/widget/log_in.dart';
import 'package:flutter_application_3/widget/order_status_screen.dart';
import 'package:flutter_application_3/widget/product_admin_screen.dart';
import 'package:flutter_application_3/widget/product_management_screen.dart';

class TaiKhoan extends StatefulWidget {
  const TaiKhoan({super.key});

  @override
  State<TaiKhoan> createState() => _TaiKhoanState();
}

class _TaiKhoanState extends State<TaiKhoan> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  User? _user; // Thông tin người dùng
  bool _isLoading = false;
  bool _isAdmin = false; // Biến để kiểm tra người dùng có phải admin không

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser; // Lấy thông tin người dùng hiện tại
    _checkAdmin(); // Kiểm tra quyền admin
    FirebaseAuth.instance.currentUser
        ?.getIdToken()
        .then((token) => print("TOKEN: $token"));
  }

  // Kiểm tra người dùng có quyền admin không
  Future<void> _checkAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Đơn giản hóa: Nếu email chứa "admin", coi như là admin
        // Trong thực tế, bạn nên sử dụng Firebase Custom Claims hoặc Firestore để lưu vai trò
        final isAdmin = user.email?.contains('admin') ?? false;
        setState(() {
          _isAdmin = isAdmin;
        });
      }
    } catch (e) {
      print('Error checking admin: $e');
    }
  }

  // Xử lý đăng xuất và gọi API
  Future<void> _handleLogout() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Gọi API đăng xuất
      await _authService.logout();

      // Chuyển đến màn hình đăng nhập
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DangNhap()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng xuất: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Xử lý xóa tài khoản và gọi API
  Future<void> _handleDeleteAccount() async {
    // Hiển thị hộp thoại xác nhận
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa tài khoản'),
            content: const Text(
                'Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Gọi API xóa tài khoản
      await _authService.deleteAccount();

      // Chuyển đến màn hình đăng nhập
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DangNhap()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa tài khoản: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                                        type:
                                            StatusOrder.chuathanhtoan.typeOrder,
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
                                        type:
                                            StatusOrder.danggiaohang.typeOrder,
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

                  // Admin Section - only visible to admins
                  if (_isAdmin)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Quản lý (Admin)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProductAdminScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text("Thêm sản phẩm mới"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProductManagementScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.inventory),
                            label: const Text("Quản lý sản phẩm"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Navigate to order management screen
                            },
                            icon: const Icon(Icons.assignment),
                            label: const Text("Quản lý đơn hàng"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                          onPressed: _handleLogout,
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
                          onPressed: _handleDeleteAccount,
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
