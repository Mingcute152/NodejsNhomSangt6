import 'package:flutter/material.dart';
import 'package:flutter_application_3/controllers/firebase/product_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_application_3/theme.dart';

class CategoryCard extends StatelessWidget {
  final String icon;
  final int index;

  CategoryCard({
    super.key,
    required this.icon,
    required this.index,
  })  : assert(index >= 0, 'Index must be non-negative'),
        assert(icon.isNotEmpty, 'Icon path cannot be empty');

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return GestureDetector(
      onTap: () {
        try {
          controller.filterProduct(type: index);
        } catch (e) {
          Get.snackbar(
            'Error',
            'Unable to filter products',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
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
          child: Image.asset(
            icon,
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error);
            },
          ),
        ),
      ),
    );
  }
}
