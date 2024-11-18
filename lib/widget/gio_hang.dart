// ignore_for_file: unused_import, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/navbar_root.dart';
import 'package:flutter_application_3/widget/categories.dart';
import 'package:flutter_application_3/widget/thanh_toan_van_chuyen/thanh_toan.dart';
import 'package:flutter_application_3/widget/trang_chu.dart';



class GioHang extends StatefulWidget {
  @override
  GioHangState createState() => GioHangState();
}

class GioHangState extends State<GioHang> {
  String tenSanPham = "Sản phẩm ABC";
  int soLuongSanPham = 1;
  int giaSanPham = 100000;
  String hinhAnhSanPham = 'assets/images/vitaC.png'; // Đường dẫn đến hình ảnh sản phẩm

  void tangSoLuong() {
    setState(() {
      soLuongSanPham++;
    });
  }

  void giamSoLuong() {
    if (soLuongSanPham > 1) {
      setState(() {
        soLuongSanPham--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          Container(
            color: whiteColor,
            padding: EdgeInsets.all(30),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavBarRoots(),
                      ),
                    );
                  },
                  child:  Positioned(
                    left: 40,
                    top: 30,
                    child: Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.green,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "Trang Chủ",
                    style: TextStyle(
                        fontSize: 23, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          // Box chứa thông tin sản phẩm
          Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Thông tin sản phẩm
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenSanPham,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Giá: $giaSanPham VND",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
                // Nút thêm/bớt số lượng
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: giamSoLuong,
                    ),
                    Text(
                      "$soLuongSanPham", // Số lượng sản phẩm 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: tangSoLuong,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacer(),
          // Nút thanh toán
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Thanhtoan(
                      tenSanPham: tenSanPham,
                      soLuongSanPham: soLuongSanPham,
                      giaSanPham: giaSanPham,
                      hinhAnhSanPham: hinhAnhSanPham,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Thanh Toán",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.payments_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}