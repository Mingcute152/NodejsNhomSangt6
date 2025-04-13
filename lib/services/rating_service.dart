// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_3/model/rating_model.dart';

class RatingService {
  // Non-static field for instance use
  final String baseUrl;

  // Default API base URL - using the local network IP instead of localhost
  static const String defaultBaseUrl = 'http://192.168.56.1:3000/api';

  // List of possible server addresses to try - ordered by priority
  static const List<String> possibleServers = [
    'http://192.168.56.1:3000/api', // Your specific IP shown in the error
    'http://localhost:3000/api',
    'http://127.0.0.1:3000/api',
    'http://10.0.2.2:3000/api', // For Android emulator
    'http://10.0.3.2:3000/api', // For Genymotion
    'http://192.168.1.11:3000/api', // Common LAN IP
    'http://192.168.0.1:3000/api', // Common LAN IP
    'http://172.20.10.3:3000/api', // iPhone hotspot
    'http://172.20.10.1:3000/api', // iPhone hotspot
  ];

  // Allow for URL override during construction
  RatingService({String? customBaseUrl})
      : baseUrl = customBaseUrl ?? defaultBaseUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Find the best server to connect to
  static Future<String> findBestServer() async {
    print('Attempting to find the best server to connect to...');

    for (String serverUrl in possibleServers) {
      try {
        print('Testing connection to $serverUrl/health');
        final response = await http
            .get(
              Uri.parse(serverUrl.replaceAll('/api', '/health')),
            )
            .timeout(const Duration(seconds: 2));

        if (response.statusCode == 200) {
          print('Successfully connected to $serverUrl');
          return serverUrl;
        }
      } catch (e) {
        print('Failed to connect to $serverUrl: $e');
        // Continue to next server
      }
    }

    print('Could not connect to any server, using default');
    return defaultBaseUrl;
  }

  // Manually specify server URL
  static Future<bool> testServerConnection(String serverUrl) async {
    try {
      final fullUrl = serverUrl.endsWith('/api')
          ? serverUrl.replaceAll('/api', '/health')
          : serverUrl.endsWith('/')
              ? '${serverUrl}health'
              : '$serverUrl/health';

      print('Testing connection to $fullUrl');
      final response = await http
          .get(
            Uri.parse(fullUrl),
          )
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
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

  // Lấy danh sách đánh giá của một sản phẩm
  Future<List<RatingModel>> getProductRatings(String productId) async {
    try {
      print(
          'Fetching ratings for product: $productId from $baseUrl/ratings/product/$productId');

      final response = await http
          .get(
        Uri.parse('$baseUrl/ratings/product/$productId'),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Timeout fetching ratings');
          return http.Response(
            '{"error": "Connection timeout"}',
            408,
          );
        },
      );

      print(
          'API Response for ratings: ${response.statusCode}: ${response.body}');

      // Kiểm tra nếu response là HTML thay vì JSON
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        print('Server trả về HTML thay vì JSON');
        return [];
      }

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];

        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RatingModel.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load ratings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ratings: $e');
      return [];
    }
  }

  // Thêm đánh giá mới
  Future<Map<String, dynamic>> addRating(RatingModel rating) async {
    try {
      // Kiểm tra xác thực
      final token = await _getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Bạn cần đăng nhập để đánh giá sản phẩm'
        };
      }

      // Print token for debugging (first 20 chars only)
      final tokenPreview =
          token.length > 20 ? token.substring(0, 20) + '...' : token;
      print(
          'Making POST request to: $baseUrl/ratings with token: $tokenPreview');

      // Test server connection first
      try {
        final testResponse = await http
            .get(
              Uri.parse(baseUrl.replaceAll('/api', '/health')),
            )
            .timeout(const Duration(seconds: 5));

        print('Server health check status: ${testResponse.statusCode}');

        if (testResponse.statusCode != 200) {
          return {
            'success': false,
            'message':
                'Lỗi kết nối đến server. Vui lòng kiểm tra kết nối mạng và thử lại sau.'
          };
        }
      } catch (e) {
        print('Server health check failed: $e');
        return {
          'success': false,
          'message':
              'Lỗi kết nối đến server. Vui lòng kiểm tra kết nối mạng và thử lại sau.'
        };
      }

      final response = await http
          .post(
        Uri.parse('$baseUrl/ratings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(rating.toMap()),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          return http.Response(
            '{"error": "Kết nối quá chậm, vui lòng thử lại sau"}',
            408,
          );
        },
      );

      print('API response status code: ${response.statusCode}');
      print('API response body: ${response.body}');

      // Xử lý khi API trả về HTML thay vì JSON
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        print('Server trả về HTML thay vì JSON');
        return {
          'success': false,
          'message':
              'Lỗi kết nối đến server. Vui lòng kiểm tra kết nối mạng và thử lại sau.'
        };
      }

      // Nếu response body trống
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {'success': true, 'message': 'Đã thêm đánh giá thành công'};
        } else {
          return {'success': false, 'message': 'Lỗi: ${response.statusCode}'};
        }
      }

      try {
        final responseData = json.decode(response.body);

        if (response.statusCode == 201) {
          return {
            'success': true,
            'message': 'Đã thêm đánh giá thành công',
            'data': responseData
          };
        } else {
          return {
            'success': false,
            'message': responseData['error'] ?? 'Không thể thêm đánh giá'
          };
        }
      } catch (jsonError) {
        print('JSON parse error: $jsonError');
        return {
          'success': false,
          'message': 'Lỗi xử lý dữ liệu từ server: $jsonError'
        };
      }
    } catch (e) {
      print('Error adding rating: $e');
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  // Xóa đánh giá
  Future<Map<String, dynamic>> deleteRating(String ratingId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Bạn cần đăng nhập để xóa đánh giá'
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/ratings/$ratingId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Xử lý khi API trả về HTML thay vì JSON
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        print('Server trả về HTML thay vì JSON');
        return {'success': false, 'message': 'Lỗi kết nối đến server'};
      }

      if (response.statusCode == 200) {
        // Nếu response body trống
        if (response.body.isEmpty) {
          return {'success': true, 'message': 'Đã xóa đánh giá thành công'};
        }

        try {
          final responseData = json.decode(response.body);
          return {
            'success': true,
            'message': responseData['message'] ?? 'Đã xóa đánh giá thành công'
          };
        } catch (jsonError) {
          return {'success': true, 'message': 'Đã xóa đánh giá thành công'};
        }
      } else {
        try {
          final responseData = json.decode(response.body);
          return {
            'success': false,
            'message': responseData['error'] ?? 'Không thể xóa đánh giá'
          };
        } catch (jsonError) {
          return {
            'success': false,
            'message': 'Không thể xóa đánh giá: Lỗi ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      print('Error deleting rating: $e');
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  // Sửa đánh giá
  Future<Map<String, dynamic>> updateRating(
      String ratingId, RatingModel rating) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Bạn cần đăng nhập để sửa đánh giá'
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/ratings/$ratingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(rating.toMap()),
      );

      // Xử lý khi API trả về HTML thay vì JSON
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        print('Server trả về HTML thay vị JSON');
        return {'success': false, 'message': 'Lỗi kết nối đến server'};
      }

      if (response.statusCode == 200) {
        // Nếu response body trống
        if (response.body.isEmpty) {
          return {
            'success': true,
            'message': 'Đã cập nhật đánh giá thành công'
          };
        }

        try {
          final responseData = json.decode(response.body);
          return {
            'success': true,
            'message':
                responseData['message'] ?? 'Đã cập nhật đánh giá thành công',
            'data': responseData
          };
        } catch (jsonError) {
          return {
            'success': true,
            'message': 'Đã cập nhật đánh giá thành công'
          };
        }
      } else {
        try {
          final responseData = json.decode(response.body);
          return {
            'success': false,
            'message': responseData['error'] ?? 'Không thể cập nhật đánh giá'
          };
        } catch (jsonError) {
          return {
            'success': false,
            'message': 'Không thể cập nhật đánh giá: Lỗi ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      print('Error updating rating: $e');
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  // Lấy đánh giá trung bình của một sản phẩm
  Future<double> getAverageRating(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ratings/product/$productId/average'),
      );

      if (response.statusCode == 200) {
        // Kiểm tra response body
        if (response.body.isEmpty) return 0;

        // Kiểm tra nếu response là HTML thay vì JSON
        if (response.body.trim().startsWith('<!DOCTYPE html>')) {
          print('Server trả về HTML thay vì JSON');
          return 0;
        }

        final data = json.decode(response.body);
        return (data['averageRating'] ?? 0).toDouble();
      } else {
        print('Failed to get average rating: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error getting average rating: $e');
      return 0;
    }
  }
}
