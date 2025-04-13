// ignore_for_file: avoid_print

import 'package:flutter_application_3/model/product_model.dart';
import 'package:flutter_application_3/services/product_service.dart';

import 'package:get/get.dart';
import 'dart:async';

class ProductController extends GetxController {
  final ProductService _productService = ProductService();
  final RxList<ProductModel> listProduct = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxBool isSearching = false.obs;
  Timer? _debounce;
  List<ProductModel> listTemp = [];

  Future<void> getDataProduct() async {
    try {
      listProduct.clear();
      List<ProductModel> products = await _productService.fetchProducts();
      print("Fetched products: $products"); // Log dữ liệu sản phẩm
      listProduct.addAll(products);
      listTemp.addAll(products);
    } catch (e) {
      print("Error fetching products: $e"); // Log lỗi nếu cóR
    }
  }

  void filterProduct({required int type}) {
    List<ProductModel> temp2 = [];
    temp2.addAll(listTemp);

    listProduct.value = temp2.where((product) => product.type == type).toList();
  }

  Future<void> searchProduct({required String name}) async {
    // Hủy timer cũ nếu có
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Tạo timer mới
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        isSearching.value = true;

        if (name.isEmpty) {
          await getDataProduct();
          return;
        }

        final searchResults = await _productService.searchProducts(name);
        listProduct.value = searchResults;
      } catch (e) {
        print('Error in searchProduct: $e');
      } finally {
        isSearching.value = false;
      }
    });
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      filteredProducts.value = listProduct;
      return;
    }

    // Chuẩn hóa query và thực hiện tìm kiếm
    final normalizedQuery = query.toLowerCase().trim();

    filteredProducts.value = listProduct.where((product) {
      final normalizedTitle = product.title.toLowerCase();
      return normalizedTitle.contains(normalizedQuery);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    getDataProduct();
    // Khởi tạo filteredProducts với toàn bộ sản phẩm
    filteredProducts.value = listProduct;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
