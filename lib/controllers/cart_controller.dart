import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/cart_model.dart';
import 'package:flutter_application_3/model/product_model.dart';
import 'package:flutter_application_3/services/cart_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CartController extends GetxController {
  final CartService _cartService = CartService();

  Rx<CartModel> cartModel = CartModel(
    id: '',
    userId: '',
    status: 0,
    listProduct: [],
  ).obs;

  final RxList<String> listTemp = <String>[].obs;
  RxDouble totalPrice = 0.0.obs;
  final RxBool isLoading = false.obs;

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
    final int indexOfList = cartModel.value.listProduct
        .indexWhere((productModel) => productModel.id == product.id);

    if (indexOfList != -1) {
      cartModel.value.listProduct[indexOfList].quantity += quantity;
    } else {
      cartModel.value.listProduct.add(product.copyWith(quantity: quantity));
    }

    await Fluttertoast.showToast(
      msg: "Thêm vào giỏ hàng thành công!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade300,
      textColor: Colors.black,
      fontSize: 16.0,
    );

    if (cartModel.value.id.isEmpty) {
      cartModel.value.id = await _cartService.createCart(cartModel.value);
    } else {
      await _cartService.updateCart(cartModel.value);
    }

    cartModel.refresh();
  }

  String get getTotalPriceString {
    totalPrice.value = 0.0;

    for (final ProductModel product in cartModel.value.listProduct) {
      totalPrice.value +=
          listTemp.contains(product.id) ? product.price * product.quantity : 0;
    }

    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );

    totalPrice.refresh();

    return formatter.format(totalPrice.value);
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
    totalPrice.value = cartModel.value.listProduct.fold<double>(
      0.0,
      (sum, product) => sum + product.price * product.quantity,
    );
  }

  Future<void> payment() async {
    await _cartService.processPayment(cartModel.value, totalPrice.value);

    await Fluttertoast.showToast(
      msg: "Thanh toán thành công",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade300,
      textColor: Colors.black,
      fontSize: 16.0,
    );

    cartModel.value.id = '';
    cartModel.value.listProduct.clear();
    cartModel.refresh();
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
      if (isPlus) {
        cartModel.value.listProduct[index].quantity += 1; // Tăng số lượng
      } else {
        if (cartModel.value.listProduct[index].quantity > 1) {
          cartModel.value.listProduct[index].quantity -= 1; // Giảm số lượng
        }
      }
      cartModel.refresh();
      updateTotalPrice(); // Cập nhật tổng giá
    }
  }
}
