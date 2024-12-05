import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/cart_model.dart';
import 'package:flutter_application_3/model/product_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CartController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final Rx<CartModel> cartModel = CartModel(
    id: '',
    userId: FirebaseAuth.instance.currentUser?.uid ?? '',
    listProduct: [],
  ).obs;

  Future<void> addCart({
    required ProductModel product,
    required int quantity,
  }) async {
    final int indexOfList = cartModel.value.listProduct
        .indexWhere((productModel) => productModel.id == product.id);

    if (indexOfList != -1) {
      cartModel.value.listProduct[indexOfList].quantity =
          cartModel.value.listProduct[indexOfList].quantity + quantity;
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
  }

  String totalPrice({required List<String> listProductIdChoose}) {
    double totalPrice = 0;
    for (final ProductModel product in cartModel.value.listProduct) {
      totalPrice += listProductIdChoose.contains(product.id)
          ? product.price * product.quantity
          : 0;
    }

    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );

    return formatter.format(totalPrice);
  }

  void removeProduct(ProductModel product) {
    cartModel.value.listProduct.remove(product);
    cartModel.refresh();
    updateTotalPrice();
     
  }
  void updateSelectedIds(dynamic listCartTempId) {
    listCartTempId.removeWhere((id) =>
        !cartModel.value.listProduct.any((product) => product.id == id));
  }

  void updateTotalPrice() {
    final total = totalPrice(
        listProductIdChoose:
            cartModel.value.listProduct.map((e) => e.id).toList());
    print("tổng giá trị sau khi xóa : $total");
  }



}