// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/firebase/product_controller.dart';
import 'package:flutter_application_3/widget/gio_hang.dart';
import 'package:flutter_application_3/widget/trang_chu.dart';
import 'package:flutter_application_3/widget/tai_khoan.dart';
import 'package:get/get.dart';

class NavBarRoots extends StatefulWidget {
  const NavBarRoots({super.key});

  @override
  State<NavBarRoots> createState() => _NavBarRootsState();
}

class _NavBarRootsState extends State<NavBarRoots> {
  int _selectedIndex = 0;
  final _screens = [
    TrangChu(),
    GioHang(),
    TaiKhoan(),
  ];

  final controller = Get.put(ProductController());

  @override
  void initState() {
    super.initState();

    controller.getDataProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: 70,
        child: BottomNavigationBar(
          backgroundColor: whiteColor,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: greenColor,
          unselectedItemColor: blackColor,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Trang chủ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: "Giỏ hàng",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Tài Khoản",
            ),
          ],
        ),
      ),
    );
  }
}
