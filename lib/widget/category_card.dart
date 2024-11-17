import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';

class CategoryCard extends StatelessWidget {
  final String icon;
  const CategoryCard({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ignore: avoid_print
        print(icon);
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
