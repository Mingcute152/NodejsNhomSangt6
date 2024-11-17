// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/product_model.dart';
// ignore: unused_import
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/products_cart.dart';

class Products extends StatelessWidget {
  const Products({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: products.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
        itemBuilder: (context, index) {
          return ProductsCard(
            productModel: products[index],
          );
        },
      ),
    );
  }
}
