import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/model/product_model.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<ProductModel> listProduct = <ProductModel>[].obs;

  Future<void> getDataProduct() async {
    
    try {
      listProduct.clear();

      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();

      listProduct.addAll(querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((map) => ProductModel.fromMap(map))
          .toList());
    } catch (e) {
      // print('e toString ${e.toString()}');
    }
  }
}
