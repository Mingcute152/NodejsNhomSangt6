import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_3/controllers/firebase/order_confirmation_controller.dart';
import 'package:flutter_application_3/model/product_model.dart';

class OrderConfirmation extends StatelessWidget {
  final List<ProductModel> selectedProducts;

  const OrderConfirmation({super.key, required this.selectedProducts});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderConfirmationController());
    controller.selectedProducts.addAll(selectedProducts);

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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Giao hàng tới",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.addressController,
                          decoration: const InputDecoration(
                            labelText: "Nhập địa chỉ giao hàng",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          controller.saveShippingAddress();
                        },
                        child: const Text("Lưu"),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Danh sách sản phẩm",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.selectedProducts.length,
                      itemBuilder: (context, index) {
                        final product = controller.selectedProducts[index];
                        return ListTile(
                          leading: Image.network(
                            product.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(product.title),
                          subtitle: Text(
                            "Số lượng: ${product.quantity} - Giá: ${product.priceString}",
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Obx(
                    () => Text(
                      "Tổng tiền: ${controller.totalPrice.value.toStringAsFixed(0)} VNĐ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                controller.saveOrder();
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
