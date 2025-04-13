// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, avoid_unnecessary_containers, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_3/controllers/firebase/product_controller.dart';
// ignore: unused_import

import 'package:flutter_application_3/widget/products_cart.dart';
import 'package:get/get.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final controller = Get.put(ProductController());
  // ignore: unused_field
  final TextEditingController _searchController = TextEditingController();
  // ignore: unused_field, prefer_final_fields
  List<Map<String, dynamic>> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Obx(
        () {
          print(
              "Products: ${controller.listProduct}"); // Log danh sách sản phẩm
          return ListView.builder(
            itemCount: controller.listProduct.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 10,
            ),
            itemBuilder: (context, index) {
              return ProductsCard(
                productModel: controller.listProduct[index],
              );
            },
          );
        },
      ),
    );
  }
}
