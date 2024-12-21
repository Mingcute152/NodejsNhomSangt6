import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/cart_model.dart';
import 'package:flutter_application_3/model/status_order.dart';
import 'package:flutter_application_3/widget/firebase/order_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import package intl để format ngày tháng

class OrderListScreen extends StatefulWidget {
  final int type;
  const OrderListScreen({super.key, required this.type});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final controller = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
    controller.getDataProduct(type: widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Đơn của tôi'),
          // leading: const Icon(Icons.arrow_back), //Icon back
        ),
        body: Obx(
          () => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm tên sản phẩm, tên đơn, mã...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              // Tab trạng thái đơn hàng (có thể sử dụng TabBar nếu nhiều tab hơn)
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //   child: SingleChildScrollView(
              //     scrollDirection: Axis.horizontal,
              //     child: Row(
              //       children: [
              //         _buildStatusTab('Tất cả', true),
              //         _buildStatusTab(
              //           'Đang giao hàng',
              //           widget.type == StatusOrder.danggiaohang.typeOrder,
              //         ),
              //         _buildStatusTab(
              //           'Đã giao',
              //           widget.type == StatusOrder.dagiao.typeOrder,
              //         ),
              //         _buildStatusTab(
              //           'Đổi trả',
              //           widget.type == StatusOrder.doitra.typeOrder,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.listOrder.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final CartModel order = controller.listOrder[index];
                    return Card(
                      // Sử dụng Card để tạo hiệu ứng đổ bóng
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        isThreeLine: true, // Cho phép hiển thị 3 dòng text
                        title: Text(DateFormat('dd/MM/yyyy').format(
                          order.createDate ?? DateTime.now(),
                        )), // Format ngày tháng
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Giao hàng tận nơi • ${order.id}'),
                            ...order.listProduct
                                .map((product) => Text(product.title)),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              order.status.statusOrder.name,
                              style: TextStyle(
                                color: order.status.statusOrder.getColor,
                              ),
                            ),
                            Text(NumberFormat.currency(
                                    locale: 'vi_VN', symbol: '₫')
                                .format(order.totalPrice)),
                          ],
                        ),
                        onTap: () {
                          // Xử lý khi người dùng chạm vào đơn hàng
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildStatusTab(String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Chip(
        label: Text(title),
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }
}
