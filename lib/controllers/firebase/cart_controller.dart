import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/cart_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_3/model/cart_model.dart';
import 'package:flutter_application_3/model/product_model.dart';

class CartController extends GetxController {
  final CartService _cartService = CartService();
  final RxBool isLoading = false.obs;

  Rx<CartModel> cartModel = CartModel(
    id: '',
    userId: '',
    listProduct: [],
    status: 0,
  ).obs;

  final RxList<String> listTemp = <String>[].obs;
  RxDouble totalPrice = 0.0.obs;

  Future<void> getCart() async {
    try {
      isLoading.value = true;
      final fetchedCart = await _cartService.fetchCart();
      if (fetchedCart != null) {
        cartModel.value = fetchedCart;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCart({
    required ProductModel product,
    required int quantity,
  }) async {
    try {
      final int indexOfList = cartModel.value.listProduct
          .indexWhere((productModel) => productModel.id == product.id);

      if (indexOfList != -1) {
        // Cập nhật số lượng nếu sản phẩm đã tồn tại
        cartModel.value.listProduct[indexOfList].quantity += quantity;
      } else {
        // Thêm sản phẩm mới vào giỏ hàng
        cartModel.value.listProduct.add(product.copyWith(quantity: quantity));
      }

      // Cập nhật tổng tiền
      updateTotalPrice();

      // Lưu vào database
      if (cartModel.value.id.isEmpty) {
        cartModel.value.id = await _cartService.createCart(cartModel.value);
      } else {
        await _cartService.updateCart(cartModel.value);
      }

      cartModel.refresh();

      Get.snackbar(
        'Thành công',
        'Đã thêm sản phẩm vào giỏ hàng',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể thêm vào giỏ hàng: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String calculateTotalPrice() {
    try {
      // Initialize a local variable to hold the sum
      double sum = 0;

      // Only include products that are in the listTemp (selected products)
      for (var product in cartModel.value.listProduct) {
        if (listTemp.contains(product.id)) {
          sum += product.price * product.quantity;
        }
      }

      // Format the sum as currency
      final formatter = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: 'VNĐ',
        decimalDigits: 0,
      );

      // Return the formatted string
      return formatter.format(sum);
    } catch (e) {
      print('Error calculating total price: $e');
      return '0 VNĐ';
    }
  }

  String get getTotalPriceString {
    return calculateTotalPrice();
  }

  void removeProduct(ProductModel product) async {
    cartModel.value.listProduct.remove(product);
    cartModel.refresh();

    if (cartModel.value.id.isNotEmpty) {
      await _cartService.removeProductFromCart(
          cartModel.value.id, cartModel.value.listProduct);
    }

    updateTotalPrice();

    await Fluttertoast.showToast(
      msg: "Xóa sản phẩm thành công!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade300,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  void updateTotalPrice() {
    double sum = 0;
    for (var product in cartModel.value.listProduct) {
      if (listTemp.contains(product.id)) {
        sum += product.price * product.quantity;
      }
    }
    totalPrice.value = sum;
  }

  Future<void> payment() async {
    try {
      if (listTemp.isEmpty) {
        Get.snackbar(
          'Thông báo',
          'Vui lòng chọn sản phẩm để thanh toán',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Lọc sản phẩm đã chọn
      cartModel.value.listProduct
          .where((p) => listTemp.contains(p.id))
          .toList();

      // Tạo order mới

      // Gọi API tạo order

      Get.snackbar(
        'Thành công',
        'Đặt hàng thành công',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh giỏ hàng
      await getCart();
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đặt hàng thất bại: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void checkAllProductCart({required bool isChecked}) {
    if (isChecked) {
      // Thêm tất cả sản phẩm vào danh sách tạm
      listTemp.addAll(cartModel.value.listProduct.map((product) => product.id));
    } else {
      // Xóa tất cả sản phẩm khỏi danh sách tạm
      listTemp.clear();
    }
    listTemp.refresh();
    updateTotalPrice();
  }

  void onCheckProductCart({required String productId}) {
    if (listTemp.contains(productId)) {
      listTemp.remove(productId); // Bỏ chọn sản phẩm
    } else {
      listTemp.add(productId); // Chọn sản phẩm
    }
    listTemp.refresh();
    updateTotalPrice(); // Cập nhật tổng giá
  }

  void updateQuantiyProduct({required String productId, bool isPlus = false}) {
    final index =
        cartModel.value.listProduct.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final updatedList = [...cartModel.value.listProduct];
      if (isPlus) {
        updatedList[index].quantity += 1; // Tăng số lượng
      } else {
        if (updatedList[index].quantity > 1) {
          updatedList[index].quantity -= 1; // Giảm số lượng
        }
      }

      cartModel.update((val) {
        if (val != null) {
          val.listProduct = updatedList;
        }
      });

      updateTotalPrice(); // Cập nhật tổng giá

      // Lưu vào database nếu cần
      if (cartModel.value.id.isNotEmpty) {
        _cartService.updateCart(cartModel.value);
      }
    }
  }

  void updateQuantity(String productId, bool increase) {
    final index =
        cartModel.value.listProduct.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final updatedList = [...cartModel.value.listProduct];
      if (increase) {
        updatedList[index].quantity++;
      } else if (updatedList[index].quantity > 1) {
        updatedList[index].quantity--;
      }
      cartModel.update((val) {
        val?.listProduct = updatedList;
      });
    }
  }
}
