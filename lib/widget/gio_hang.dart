// ignore_for_file: unused_import, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_3/controllers/firebase/cart_controller.dart';

import 'package:flutter_application_3/model/product_model.dart';
import 'package:flutter_application_3/theme.dart';

import 'package:flutter_application_3/widget/navbar_root.dart';
import 'package:flutter_application_3/widget/categories.dart';

import 'package:flutter_application_3/widget/trang_chu.dart';
import 'package:flutter_application_3/widget/product_detail_screen.dart';
import 'package:flutter_application_3/widget/xac_nhan_don_hang_screen.dart';
import 'package:get/get.dart';

class GioHang extends StatefulWidget {
  @override
  GioHangState createState() => GioHangState();
}

class GioHangState extends State<GioHang> {
  final CartController controller = Get.put(CartController());
  String _formattedTotalPrice = "0 VNĐ";

  @override
  void initState() {
    super.initState();
    _updateFormattedTotalPrice();

    // Lắng nghe thay đổi từ cart và cập nhật giá
    ever(controller.cartModel, (_) => _updateFormattedTotalPrice());
    ever(controller.listTemp, (_) => _updateFormattedTotalPrice());
  }

  @override
  void dispose() {
    // Clean up resources when widget is disposed
    super.dispose();
  }

  void _updateFormattedTotalPrice() {
    setState(() {
      _formattedTotalPrice = controller.calculateTotalPrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        backgroundColor: greenColor,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = controller.cartModel.value.listProduct;
        return Column(
          children: [
            Expanded(
              child: products.isEmpty
                  ? _buildEmptyCart()
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildCartItem(product);
                      },
                    ),
            ),
            if (products.isNotEmpty) _buildBottomPaymentSection(),
          ],
        );
      }),
    );
  }

  Widget _buildCartItem(ProductModel product) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Checkbox
            Obx(() => Checkbox(
                  value: controller.listTemp.contains(product.id),
                  onChanged: (value) {
                    // Check if widget is still mounted before making changes
                    // that would trigger a UI update
                    if (mounted) {
                      controller.onCheckProductCart(productId: product.id);
                    }
                  },
                )),

            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.getImageWidget(
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.priceString,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => controller.updateQuantiyProduct(
                          productId: product.id,
                          isPlus: false,
                        ),
                      ),
                      Text(
                        '${product.quantity}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => controller.updateQuantiyProduct(
                          productId: product.id,
                          isPlus: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/emptybag.jpg',
              width: 220,
              height: 120,
            ),
            const Text(
              'Chưa có sản phẩm nào trong giỏ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NavBarRoots()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Mua sắm ngay',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkBoxCustom({
    required bool isChecked,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isChecked ? Colors.green : Colors.transparent,
          border: Border.all(
            color: isChecked ? Colors.green : Colors.grey.shade400,
          ),
        ),
        padding: EdgeInsets.all(3),
        child: Icon(
          Icons.check,
          color: isChecked ? Colors.white : Colors.transparent,
          size: 13,
        ),
      ),
    );
  }

  Widget _buildBottomPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tổng tiền: $_formattedTotalPrice',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.payment();
                    // Check if widget is still mounted before updating UI
                    if (mounted) {
                      _updateFormattedTotalPrice();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Thanh toán',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
