// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_3/widget/category_card.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> listIcons = [
      "assets/img_antibiotics.png",
      "assets/img_antiseptics.png",
      "assets/vitamins.png",
      "assets/skincare.png",
      "assets/sex.png"
    ];
    return SizedBox(
      height: 90,
      child: ListView.builder(
        itemCount: listIcons.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
        itemBuilder: (context, index) {
          return CategoryCard(
            icon: listIcons[index],
            index: index,
          );
        },
      ),
    );
  }
}
