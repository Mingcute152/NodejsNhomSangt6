import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';

class ProductsCard extends StatelessWidget {
  final String icon;

  final String productsinformation;

  const ProductsCard({
    super.key,
    required this.icon,
    required this.productsinformation,
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
        boxShadow: const [
          BoxShadow(
            // color: grey35Color.withOpacity(5.0),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 0),
          )
        ],
      ),
      child: Column(
        children: [
          Image.asset(icon, width: 70, height: 90),
          Text(
            productsinformation,
            style: TextStyle(
                color: blackColor, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
