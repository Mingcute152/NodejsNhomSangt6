import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/model/product_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<ProductModel> products;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final String shippingAddress;

  OrderModel({
    required this.id,
    required this.userId,
    required this.products,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.shippingAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'products': products.map((product) => product.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': Timestamp.fromDate(orderDate),
      'shippingAddress': shippingAddress,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      products: List<ProductModel>.from(
        (map['products'] as List).map((x) => ProductModel.fromMap(x)),
      ),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: map['status'] ?? 'pending',
      orderDate: (map['orderDate'] as Timestamp).toDate(),
      shippingAddress: map['shippingAddress'] ?? '',
    );
  }
}
