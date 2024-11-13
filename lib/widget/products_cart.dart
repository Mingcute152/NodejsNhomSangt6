import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';

class ProductsCard extends StatelessWidget {
  final String icon;

  final String products_information;

  const ProductsCard({
    super.key,
    required this.icon,
    required this.products_information,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            // color: grey35Color.withOpacity(5.0),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 0),
          )
        ],
      ),
      child: Column(
        children: [
          Image.asset(icon, width: 70, height: 90),
          Text(
            products_information,
            style: TextStyle(
                color: blackColor, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
