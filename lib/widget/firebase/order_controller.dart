import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_3/model/cart_model.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<CartModel> listOrder = <CartModel>[].obs;

  Future<void> getDataProduct({required int type}) async {
    try {
      listOrder.clear();

      QuerySnapshot querySnapshot = await _firestore.collection('carts').get();

      // print('type $type');
      // print(
      //     'asdasdasdasdasdasd ${(querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).map((map) => CartModel.fromMap(map))
      //         // .where((cart) => cart.status == type)
      //         .toList())}');

      listOrder.addAll(querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((map) => CartModel.fromMap(map))
          .where((cart) {
        print(cart.userId == FirebaseAuth.instance.currentUser?.uid);
        return cart.status == type &&
            cart.userId == FirebaseAuth.instance.currentUser?.uid;
      }).toList());

      print('listOrder ${listOrder.length}');
    } catch (e) {
      print('e toString ${e.toString()}');
    }
  }
}
