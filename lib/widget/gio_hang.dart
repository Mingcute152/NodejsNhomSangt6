// ignore_for_file: unused_import, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_3/controllers/firebase/cart_controller.dart';
import 'package:flutter_application_3/model/product_model.dart';
import 'package:flutter_application_3/theme.dart';

import 'package:flutter_application_3/widget/navbar_root.dart';
import 'package:flutter_application_3/widget/categories.dart';

import 'package:flutter_application_3/widget/trang_chu.dart';
import 'package:flutter_application_3/widget/product_detail_screen.dart';
import 'package:flutter_application_3/widget/xac_nhan_don_hang_screen.dart';
import 'package:get/get.dart';

class GioHang extends StatefulWidget {
  @override
  GioHangState createState() => GioHangState();
}

class GioHangState extends State<GioHang> {
  int count = 1;
  final controller = Get.put(CartController());

  @override
  void initState() {
    super.initState();
    controller.getCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        toolbarHeight: 70,
        leading: const SizedBox(),
        title: Text(
          'Giỏ hàng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade200,
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: controller.cartModel.value.listProduct.isEmpty
                  ? cartEmpty
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              checkBoxCustom(
                                isChecked: controller
                                        .cartModel.value.listProduct.length ==
                                    controller.listTemp.length,
                                onTap: () {
                                  controller.onCheckProductCart(productId: '');
                                },
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Chọn tất cả (${controller.listTemp.length})',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Tiếp tục mua sắm',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount:
                                controller.cartModel.value.listProduct.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return cartCard(
                                isLast: index ==
                                    controller.cartModel.value.listProduct
                                            .length -
                                        1,
                                product: controller
                                    .cartModel.value.listProduct[index],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Column(
                children: [
                  // Phần tổng giá
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thành tiền',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        controller.getTotalPriceString,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderConfirmation(
                            selectedProducts: const [],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      'Mua hàng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cartCard({bool isLast = false, required ProductModel product}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              checkBoxCustom(
                isChecked: controller.listTemp.contains(product.id),
                onTap: () {
                  controller.onCheckProductCart(productId: product.id);
                },
              ),
              SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(5),
                child: Image.asset(
                  product.image,
                  width: 55,
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.priceString,
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.updateQuantiyProduct(
                              productId: product.id,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(10),
                              ),
                            ),
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.remove,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade400),
                              bottom: BorderSide(color: Colors.grey.shade400),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 10,
                          ),
                          child: Text(
                            '${product.quantity}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.updateQuantiyProduct(
                              isPlus: true,
                              productId: product.id,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(10),
                              ),
                            ),
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.add,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            controller.listTemp.remove(product.id);
                            controller.removeProduct(product);
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            color: Colors.grey,
            height: 0.5,
            width: double.infinity,
          ),
      ],
    );
  }

  Widget get cartEmpty {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/emptybag.jpg',
              width: 220,
              height: 120,
            ),
            const Text(
              'Chưa có sản phẩm nào trong giỏ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NavBarRoots()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Mua sắm ngay',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkBoxCustom({
    required bool isChecked,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isChecked ? Colors.green : Colors.transparent,
          border: Border.all(
            color: isChecked ? Colors.green : Colors.grey.shade400,
          ),
        ),
        padding: EdgeInsets.all(3),
        child: Icon(
          Icons.check,
          color: isChecked ? Colors.white : Colors.transparent,
          size: 13,
        ),
      ),
    );
  }
}
