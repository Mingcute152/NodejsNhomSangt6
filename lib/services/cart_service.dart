import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_3/model/cart_model.dart';
import 'package:flutter_application_3/model/product_model.dart';
import 'package:flutter_application_3/model/status_order.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<CartModel?> fetchCart() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('carts').get();

      for (var doc in querySnapshot.docs) {
        final map = doc.data() as Map<String, dynamic>;
        if (map['status'] == 0 &&
            map['userId'] == _firebaseAuth.currentUser?.uid) {
          return CartModel(
            id: map['id'],
            userId: map['userId'],
            listProduct: map['products'] != null && (map['products'] is List)
                ? (map['products'] as List)
                    .map((e) => ProductModel.fromMap(e))
                    .toList()
                : [],
            status: map['status'] ?? 0,
          );
        }
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<String> createCart(CartModel cartModel) async {
    try {
      DocumentReference docRef = await _firestore.collection('carts').add({
        'username': 'Hoàng Minh',
        'address': '17/1A đường 100',
        'phone': '0906680225',
        'products': cartModel.listProduct.map((e) => e.toMap()).toList(),
        'userId': cartModel.userId,
        'status': StatusOrder.chuathanhtoan.typeOrder,
      });

      String docId = docRef.id;
      await docRef.update({'id': docId});
      return docId;
    } catch (e) {
      // Handle error
      return '';
    }
  }

  Future<void> updateCart(CartModel cartModel) async {
    try {
      if (cartModel.id.isNotEmpty) {
        DocumentReference docRef =
            _firestore.collection('carts').doc(cartModel.id);

        await docRef.update({
          'username': 'Hoàng Minh',
          'address': '17/1A đường 100',
          'phone': '0906680225',
          'products': cartModel.listProduct.map((e) => e.toMap()).toList(),
          'userId': cartModel.userId,
          'status': StatusOrder.chuathanhtoan.typeOrder,
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeProductFromCart(
      String cartId, List<ProductModel> products) async {
    try {
      DocumentReference docRef = _firestore.collection('carts').doc(cartId);
      await docRef.update({
        'products': products.map((e) => e.toMap()).toList(),
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> processPayment(CartModel cartModel, double totalPrice) async {
    try {
      DocumentReference docRef =
          _firestore.collection('carts').doc(cartModel.id);

      await docRef.update({
        'username': 'Hoàng Minh',
        'address': '17/1A đường 100',
        'phone': '0906680225',
        'products': cartModel.listProduct.map((e) => e.toMap()).toList(),
        'userId': cartModel.userId,
        'status': StatusOrder.danggiaohang.typeOrder,
        'id': cartModel.id,
        'createdAt': DateTime.now(),
        'totalPrice': totalPrice,
      });
    } catch (e) {
      // Handle error
    }
  }
}
