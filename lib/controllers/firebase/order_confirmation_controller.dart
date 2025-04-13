// ignore_for_file: avoid_types_as_parameter_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_application_3/model/product_model.dart';
import 'package:flutter_application_3/services/user_service.dart';

class OrderConfirmationController extends GetxController {
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController addressController = TextEditingController();
  final RxString shippingAddress = ''.obs;
  final RxList<ProductModel> selectedProducts = <ProductModel>[].obs;
  final RxDouble totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadShippingAddress();
      _calculateTotalPrice();
    });
  }

  Future<void> _loadShippingAddress() async {
    try {
      final address = await _userService.getShippingAddress();
      if (address != null) {
        shippingAddress.value = address;
        addressController.text = address; // Tự động điền vào TextField
      }
    } catch (e) {
      Future.delayed(Duration.zero, () {
        Get.snackbar("Lỗi", e.toString());
      });
    }
  }

  void _calculateTotalPrice() {
    totalPrice.value = selectedProducts.fold(
      0.0,
      (sum, product) => sum + (product.price * product.quantity),
    );
  }

  Future<void> saveOrder() async {
    try {
      if (addressController.text.trim().isEmpty) {
        Get.snackbar("Lỗi", "Địa chỉ giao hàng không được để trống.");
        return;
      }

      final orderData = {
        "address": addressController.text.trim(),
        "createdAt": DateTime.now(),
        "status": "Đang xử lý",
        "products": selectedProducts.map((product) => product.toMap()).toList(),
        "totalPrice": totalPrice.value,
      };

      await _firestore.collection("orders").add(orderData);

      Get.snackbar("Thành công", "Đơn hàng đã được lưu.");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu đơn hàng: $e");
    }
  }

  Future<void> saveShippingAddress() async {
    try {
      final address = addressController.text.trim();
      if (address.isEmpty) {
        Get.snackbar("Lỗi", "Địa chỉ giao hàng không được để trống.");
        return;
      }

      // Lưu địa chỉ vào Firestore hoặc một nơi lưu trữ khác
      const userId = "USER_ID"; // Thay bằng logic lấy userId từ Firebase Auth
      await _firestore.collection("users").doc(userId).update({
        "shippingAddress": address, // Đã sửa lỗi chính tả và định dạng map
      });

      shippingAddress.value = address;
      Get.snackbar("Thành công", "Địa chỉ giao hàng đã được lưu.");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu địa chỉ: $e");
    }
  }
}

class OrderConfirmation extends StatelessWidget {
  final List<ProductModel> selectedProducts;

  const OrderConfirmation({super.key, required this.selectedProducts});

  @override
  Widget build(BuildContext context) {
    // Sử dụng selectedProducts trong widget
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác nhận đơn hàng"),
      ),
      body: ListView.builder(
        itemCount: selectedProducts.length,
        itemBuilder: (context, index) {
          final product = selectedProducts[index];
          return ListTile(
            title: Text(product.title),
            subtitle: Text(
                "Số lượng: ${product.quantity} - Giá: ${product.priceString}"),
          );
        },
      ),
    );
  }
}
//123123123123
