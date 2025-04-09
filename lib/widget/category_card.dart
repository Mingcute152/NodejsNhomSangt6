import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/controllers/firebase/product_controller.dart';
import 'package:get/get.dart';

class CategoryCard extends StatelessWidget {
  final String icon;
  final int index;
  const CategoryCard({
    super.key,
    required this.icon,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());

    return GestureDetector(
      onTap: () {
        controller.filterProduct(type: index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: greyLightColor.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Image.asset(icon, width: 50, height: 50),
        ),
      ),
    );
  }
}
