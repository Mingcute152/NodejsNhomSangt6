import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_3/model/cart_model.dart';
import 'package:flutter_application_3/model/product_model.dart';
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
    cartModel.value.listProduct.add(product.copyWith(quantity: quantity));
  }

  String get totalPrice {
    double totalPrice = 0;
    for (final ProductModel product in cartModel.value.listProduct) {
      totalPrice += product.price * product.quantity;
    }

    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );

    return formatter.format(totalPrice);
  }
}
