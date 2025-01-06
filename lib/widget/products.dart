// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, avoid_unnecessary_containers

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/firebase/product_controller.dart';
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
        () => ListView.builder(
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
        ),
      ),
    );
  }
}
