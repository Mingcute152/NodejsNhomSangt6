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
        width: 150,
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
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.fromLTRB(0, 0, 30, 0),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'free dedivery',
                style: TextStyle(
                    color: greenColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Image.asset(icon, width: 100, height: 70),
            Text(
              products_information,
              style: TextStyle(
                  color: blackColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'hello\n',
                style: TextStyle(
                    fontSize: 10,
                    color: blackColor,
                    fontWeight: FontWeight.normal),
                children: <TextSpan>[
                  TextSpan(
                    text: 'giá : 1000đ',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
