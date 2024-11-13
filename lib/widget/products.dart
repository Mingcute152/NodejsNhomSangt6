// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, avoid_unnecessary_containers

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/products_cart.dart';

class Products extends StatelessWidget {
  const Products({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> listIcons = [
      "assets/babemol.jpg",
      "assets/durex.png",
      "assets/makeup.png",
      "assets/paracetamol.png",
      "assets/ruatay.png",
    ];
     final List<String> listModel = [
      "Babel",
      "BCS",
      "sua rua mat",
      "paracetamol",
      "lifebouy",
    ];
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: listIcons.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
        itemBuilder: (context, index) {
          return ProductsCard(
            icon: listIcons[index],
            products_information: listModel[index],
          );
        },
      ),
    );
  }
}
