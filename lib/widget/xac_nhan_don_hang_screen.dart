import 'package:flutter/material.dart';
import 'package:flutter_application_3/widget/firebase/cart_controller.dart';
import 'package:get/get.dart';

class OrderConfirmation extends StatelessWidget {
  const OrderConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác nhận đơn hàng"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Nội dung chính của trang
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hình thức nhận hàng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Hình thức nhận hàng",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Giao hàng tận nơi",
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Địa chỉ giao hàng
                  const SizedBox(height: 10),
                  const Text(
                    "Giao hàng tới",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "17/1A đường 100",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Phường Tân Phú, Quận 9, Hồ Chí Minh",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            Text(
                              "Hoàng Minh    0906 680 225",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Thay đổi",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),

                  // Ghi chú
                  const SizedBox(height: 10),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Thêm ghi chú...",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  // Thời gian nhận hàng dự kiến
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Thời gian nhận hàng dự kiến",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Từ 21:00 - 22:00 Hôm nay, 09/12/2024",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Thay đổi",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),

                  // Xuất hóa đơn điện tử
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Yêu cầu xuất hóa đơn điện tử",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Switch(
                        value: false,
                        onChanged: (value) {},
                      ),
                    ],
                  ),

                  const Divider(),

                  // Danh sách sản phẩm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Danh sách sản phẩm",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Thêm sản phẩm khác",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Nút Thanh toán luôn nằm dưới
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                controller.payment();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                "Thanh toán",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
