// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';
// ignore: unused_import
import 'package:flutter_application_3/widget/gio_hang.dart';

class Thanhtoan extends StatelessWidget {
  final String tenSanPham;
  final int soLuongSanPham;
  final int giaSanPham;
  final String hinhAnhSanPham;

  // nhận giá trị từ `GioHang`
  const Thanhtoan({
    required this.tenSanPham,
    required this.soLuongSanPham,
    required this.giaSanPham,
    required this.hinhAnhSanPham,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trang Thanh Toán',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff4fc65b),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: [
            // Khung chứa thông tin sản phẩm
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: greenColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Hình ảnh sản phẩm
                  const SizedBox(height: 8),
                  Text(
                    'Tên sản phẩm: $tenSanPham',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Số lượng: $soLuongSanPham',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Giá: ${giaSanPham * soLuongSanPham} VND',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Khung chứa các tùy chọn thanh toán
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: greenColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Thanh toán bằng Ngân hàng'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // ignore: avoid_print
                      print('Thanh toán qua MoMo');
                    },
                    child: const Text('Thanh toán qua MoMo'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // ignore: avoid_print
                      print('Chọn phương thức vận chuyển');
                    },
                    child: const Text('Chọn phương thức vận chuyển'),
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
