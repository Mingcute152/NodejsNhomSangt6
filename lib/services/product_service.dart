import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/model/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProductModel>> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((map) => ProductModel.fromMap(map))
          .toList();
    } catch (e) {
      // Handle error
      return [];
    }
  }
}
