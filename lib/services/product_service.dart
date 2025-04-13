// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_3/model/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductService {
  static const String baseUrl = 'http://192.168.1.234:3000/api';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy danh sách sản phẩm từ API Node.js
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      print("API Response: ${response.body}"); // Log phản hồi từ API

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e'); // Log lỗi nếu có
      return [];
    }
  }

  // Lấy token xác thực
  Future<String?> _getAuthToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Thêm sản phẩm mới qua API Node.js (với xác thực)
  Future<Map<String, dynamic>> addProduct(ProductModel product) async {
    try {
      // Lấy token xác thực
      final token = await _getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Bạn cần đăng nhập để thêm sản phẩm'
        };
      }

      print('Making POST request to: $baseUrl/products');
      print('Request data: ${json.encode(product.toMap())}');

      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(product.toMap()),
      );

      print('API response status code: ${response.statusCode}');
      print('API response body: ${response.body}');

      // Kiểm tra nếu response bắt đầu bằng <!DOCTYPE html> thì đây là lỗi HTML
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        return {
          'success': false,
          'message': 'Lỗi kết nối tới server. Vui lòng thử lại sau.'
        };
      }

      try {
        final responseData = json.decode(response.body);

        if (response.statusCode == 201) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Thêm sản phẩm thành công',
            'data': responseData
          };
        } else {
          return {
            'success': false,
            'message': responseData['error'] ?? 'Thêm sản phẩm thất bại'
          };
        }
      } catch (jsonError) {
        // Có lỗi khi parse JSON
        print('JSON parse error: $jsonError');
        return {
          'success': false,
          'message': 'Lỗi định dạng dữ liệu từ server: $jsonError'
        };
      }
    } catch (e) {
      print('Error adding product: $e');
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  // Cập nhật sản phẩm
  Future<Map<String, dynamic>> updateProduct(
      String id, Map<String, dynamic> data) async {
    try {
      // Lấy token xác thực
      final token = await _getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Bạn cần đăng nhập để cập nhật sản phẩm'
        };
      }

      print('Making PUT request to: $baseUrl/products/$id');
      print('Request data: ${json.encode(data)}');

      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      print('API response status code: ${response.statusCode}');
      print('API response body: ${response.body}');

      // Kiểm tra nếu response bắt đầu bằng <!DOCTYPE html> thì đây là lỗi HTML
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        return {
          'success': false,
          'message': 'Lỗi kết nối tới server. Vui lòng thử lại sau.'
        };
      }

      try {
        final responseData = json.decode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message':
                responseData['message'] ?? 'Cập nhật sản phẩm thành công',
            'data': responseData
          };
        } else {
          return {
            'success': false,
            'message': responseData['error'] ?? 'Cập nhật sản phẩm thất bại'
          };
        }
      } catch (jsonError) {
        // Có lỗi khi parse JSON
        print('JSON parse error: $jsonError');
        return {
          'success': false,
          'message': 'Lỗi định dạng dữ liệu từ server: $jsonError'
        };
      }
    } catch (e) {
      print('Error updating product: $e');
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  // Xóa sản phẩm
  Future<Map<String, dynamic>> deleteProduct(String id) async {
    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount <= maxRetries) {
      try {
        print('Deleting product with ID: $id (attempt ${retryCount + 1})');

        // Lấy token xác thực
        final token = await _getAuthToken();
        if (token == null) {
          print('Authentication token is null');
          return {
            'success': false,
            'message': 'Bạn cần đăng nhập để xóa sản phẩm'
          };
        }

        // Chuẩn bị header
        final headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        print('Making DELETE request to: $baseUrl/products/$id');

        final response = await http
            .delete(
          Uri.parse('$baseUrl/products/$id'),
          headers: headers,
        )
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Request timed out');
            throw Exception('Kết nối quá chậm, vui lòng thử lại sau');
          },
        );

        print('API response status code: ${response.statusCode}');
        print('API response body: ${response.body}');

        // Xử lý response body trống
        if (response.body.isEmpty) {
          if (response.statusCode == 200) {
            return {
              'success': true,
              'message': 'Xóa sản phẩm thành công',
            };
          } else {
            throw Exception('Phản hồi từ server trống');
          }
        }

        // Xử lý response là HTML thay vì JSON
        if (response.body.contains('<!DOCTYPE html>')) {
          throw Exception('Server không trả về định dạng JSON hợp lệ');
        }

        // Bảo vệ trước khi parse JSON
        String sanitizedBody = response.body.trim();
        if (!sanitizedBody.startsWith('{') && !sanitizedBody.startsWith('[')) {
          throw Exception('Định dạng phản hồi không hợp lệ: $sanitizedBody');
        }

        try {
          final responseData = json.decode(sanitizedBody);

          // Xử lý kết quả dựa trên status code
          if (response.statusCode >= 200 && response.statusCode < 300) {
            return {
              'success': true,
              'message': responseData['message'] ?? 'Xóa sản phẩm thành công',
            };
          } else {
            return {
              'success': false,
              'message': responseData['error'] ?? 'Xóa sản phẩm thất bại'
            };
          }
        } catch (jsonError) {
          print('JSON parse error: $jsonError for body: $sanitizedBody');

          // Nếu statusCode là 200 nhưng không parse được JSON, vẫn coi là thành công
          if (response.statusCode == 200) {
            return {
              'success': true,
              'message': 'Xóa sản phẩm thành công (không parse được phản hồi)',
            };
          }

          throw Exception('Lỗi xử lý dữ liệu từ server: $jsonError');
        }
      } catch (e) {
        retryCount++;
        print('Error in deleteProduct (attempt $retryCount): $e');

        // Nếu đã hết số lần thử lại thì trả về lỗi
        if (retryCount > maxRetries) {
          return {
            'success': false,
            'message': 'Không thể xóa sản phẩm: ${e.toString().split('\n')[0]}'
          };
        }

        // Chờ một chút trước khi thử lại
        await Future.delayed(Duration(seconds: 1 * retryCount));
      }
    }

    return {'success': false, 'message': 'Lỗi không xác định'};
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/products/search?query=${Uri.encodeComponent(query)}'));

      print("Search API Response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromMap(json)).toList();
      } else {
        throw Exception('Failed to search products');
      }
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}

// Xử lý lỗi exception đơn giản hơn
