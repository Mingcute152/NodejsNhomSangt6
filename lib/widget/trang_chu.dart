// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, duplicate_ignore, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/categories.dart';
// ignore: unused_import
import 'package:flutter_application_3/widget/products_cart.dart';
// ignore: unused_import
import 'package:flutter_application_3/widget/products.dart';

class TrangChu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // TrangChu(),

          // ignore: prefer_const_constructors
          Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10,
              ),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ]),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: greenColor,
                        size: 30,
                      ),
                      Container(
                        height: 50,
                        width: 300,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "Tìm sản phẩm, TPCN cần tìm... ",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.filter_list,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              )),
          Padding(
            padding: EdgeInsets.only(
              top: 1,
              left: 15,
            ),
            child: Text(
              "Danh sách",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          //sản phẩm
          Categories(),
          //phổ biến
          Padding(
            padding: EdgeInsets.only(top: 20, left: 15),
            child: Text(
              "Sản phẩm phổ biến",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Products(),
        ],
      ),
    );
  }
}
