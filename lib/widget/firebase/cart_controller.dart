import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/cart_model.dart';
import 'package:flutter_application_3/model/product_model.dart';
import 'package:flutter_application_3/model/status_order.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CartController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // ignore: unused_field
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Rx<CartModel> cartModel = CartModel(
    id: '',
    userId: FirebaseAuth.instance.currentUser?.uid ?? '',
    listProduct: [],
    status: 0,
  ).obs;

  final RxList<String> listTemp = <String>[].obs;

  RxDouble totalPrice = 0.0.obs;

  Future<void> getCart() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('carts').get();

      querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList()
          .forEach((map) {
        if (map['status'] == 0 &&
            map['userId'] == _firebaseAuth.currentUser?.uid) {
          cartModel.value = CartModel(
            id: map['id'],
            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
            listProduct: map['products'] != null && (map['products'] is List)
                ? (map['products'] as List)
                    .map((e) => ProductModel.fromMap(e))
                    .toList()
                : [],
            status: map['status'] ?? 0,
          );
        }
      });
    } catch (e) {
      // print('e toString ${e.toString()}');
    }
  }

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

    if (cartModel.value.id.isEmpty) {
      DocumentReference docRef = await _firestore.collection('carts').add({
        'username': 'Hoàng Minh',
        'address': '17/1A đường 100',
        'phone': '0906680225',
        'products': cartModel.value.listProduct.map((e) => e.toMap()),
        'userId': cartModel.value.userId,
        'status': StatusOrder.chuathanhtoan.typeOrder,
      });

      // Lấy ID của document vừa tạo
      String docId = docRef.id;

      // Cập nhật lại document với trường 'id' là docId
      await docRef.update({
        'id': docId, // Thêm trường 'id' vào document
      });
      cartModel.value.id = docId;
      cartModel.refresh();
    } else {
      DocumentReference docRef =
          _firestore.collection('carts').doc(cartModel.value.id);

      // Cập nhật dữ liệu trong document
      await docRef.update({
        'username': 'Hoàng Minh',
        'address': '17/1A đường 100',
        'phone': '0906680225',
        'products': cartModel.value.listProduct.map((e) => e.toMap()),
        'userId': cartModel.value.userId,
        'status':
            StatusOrder.chuathanhtoan.typeOrder, // Cập nhật trường 'email'
      });
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

  void removeProduct(ProductModel product) {
    cartModel.value.listProduct.remove(product);
    cartModel.refresh();
    updateTotalPrice();
  }

  void updateSelectedIds(dynamic listTemp) {
    listTemp.removeWhere((id) =>
        !cartModel.value.listProduct.any((product) => product.id == id));
  }

  void updateTotalPrice() {
    totalPrice.value = cartModel.value.listProduct.fold<double>(
      0.0,
      // ignore: avoid_types_as_parameter_names
      (sum, product) => sum + product.price * product.quantity,
    );
  }

  void onCheckProductCart({required String productId}) {
    if (listTemp.contains(productId)) {
      listTemp.remove(productId);
    } else {
      listTemp.add(productId);
    }

    listTemp.refresh();
  }

  void onCheckAllProductCart() {
    if (cartModel.value.listProduct.length == listTemp.length) {
      listTemp.clear();
    } else {
      listTemp.clear();
      listTemp.addAll(
          cartModel.value.listProduct.map((product) => product.id).toList());
    }
  }

  void updateQuantiyProduct({bool isPlus = false, required String productId}) {
    final int indexOfCartProduct = cartModel.value.listProduct
        .indexWhere((product) => product.id == productId);

    if (indexOfCartProduct != -1) {
      if (isPlus) {
        cartModel.value.listProduct[indexOfCartProduct].quantity++;
      } else {
        cartModel.value.listProduct[indexOfCartProduct].quantity--;
        if (cartModel.value.listProduct[indexOfCartProduct].quantity == 0) {
          removeProduct(cartModel.value.listProduct[indexOfCartProduct]);
        }
      }
    }

    cartModel.refresh();
  }

  Future<void> payment() async {
    DocumentReference docRef =
        _firestore.collection('carts').doc(cartModel.value.id);

    docRef.update({
      'username': 'Hoàng Minh',
      'address': '17/1A đường 100',
      'phone': '0906680225',
      'products': cartModel.value.listProduct.map((e) => e.toMap()),
      'userId': cartModel.value.userId,
      'status': StatusOrder.danggiaohang.typeOrder,
      'id': cartModel.value.id,
      'createdAt': DateTime.now(),
      'totalPrice': totalPrice.value,
    });

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
}
