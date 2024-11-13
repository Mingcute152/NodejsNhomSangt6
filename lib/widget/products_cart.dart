import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';

class ProductsCard extends StatelessWidget {
  final String icon;
  const ProductsCard({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: grey35Color.withOpacity(5.0),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ]),
        child: Image.asset(icon, width: 10, height: 10),
      ),
    );
  }
}
