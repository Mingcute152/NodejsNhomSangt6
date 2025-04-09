import 'package:flutter_application_3/model/product_model.dart';
import 'package:flutter_application_3/services/product_service.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService();
  final RxList<ProductModel> listProduct = <ProductModel>[].obs;
  List<ProductModel> listTemp = [];

  Future<void> getDataProduct() async {
    try {
      listProduct.clear();

      List<ProductModel> products = await _productService.fetchProducts();

      listProduct.addAll(products);
      listTemp.addAll(products);
    } catch (e) {
      // Handle error
    }
  }

  void filterProduct({required int type}) {
    List<ProductModel> temp2 = [];
    temp2.addAll(listTemp);

    listProduct.value = temp2.where((product) => product.type == type).toList();
  }

  void searchProduct({required String name}) {
    List<ProductModel> temp2 = [];
    temp2.addAll(listTemp);

    listProduct.value = temp2
        .where((product) =>
            product.title.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }
}
