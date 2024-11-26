import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/product_model.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/navbar_root.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int count = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hình ảnh sản phẩm
                  Stack(
                    children: [
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: 10,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, size: 30),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Center(
                        child: Image.asset(
                          widget.product.image,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  // Nội dung bên dưới
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          widget.product.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.green,
                              size: 20,
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.green,
                              size: 20,
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.green,
                              size: 20,
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.green,
                              size: 20,
                            ),
                            Icon(
                              Icons.star_border_sharp,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 5),
                            Text(
                              '4.0',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 5),
                            Text('(0 reviews)',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Giá và số lượng
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.product.priceString}/hộp',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (count == 1) return;

                                    setState(() {
                                      count--;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.green[300],
                                  ),
                                ),
                                Text(
                                  '$count',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      count++;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.green[300],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Mô tả
                        const Text(
                          'Mô tả',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.product.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Nút Add to Cart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.shopping_cart_outlined),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
