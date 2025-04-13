import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static const String baseUrl = 'http://192.168.1.234:3000/api';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  Future<String> createOrder(OrderModel order) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(order.toMap()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['orderId'];
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  Future<List<OrderModel>> getUserOrders() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OrderModel.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Error getting orders: $e');
    }
  }
}
