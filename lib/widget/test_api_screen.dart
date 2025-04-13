import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_3/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({Key? key}) : super(key: key);

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  final TextEditingController _serverUrlController = TextEditingController(
    text: 'http://192.168.56.1:3000',
  );
  final TextEditingController _productIdController = TextEditingController(
    text: 'test-product',
  );

  String _responseText = 'Kết quả sẽ hiển thị ở đây';
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _serverUrlController.dispose();
    _productIdController.dispose();
    super.dispose();
  }

  Future<void> _testHealthCheck() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _responseText = 'Đang kiểm tra kết nối...';
    });

    try {
      final response = await http
          .get(
            Uri.parse('${_serverUrlController.text}/health'),
          )
          .timeout(const Duration(seconds: 5));

      setState(() {
        _isLoading = false;
        _responseText = 'Health Check Status: ${response.statusCode}\n'
            'Body: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseText = 'Lỗi: $e';
      });
    }
  }

  Future<void> _testGetRatings() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _responseText = 'Đang lấy đánh giá...';
    });

    try {
      final response = await http
          .get(
            Uri.parse(
                '${_serverUrlController.text}/api/ratings/product/${_productIdController.text}'),
          )
          .timeout(const Duration(seconds: 5));

      setState(() {
        _isLoading = false;
        _responseText = 'Get Ratings Status: ${response.statusCode}\n'
            'Body: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseText = 'Lỗi: $e';
      });
    }
  }

  Future<void> _testAddRating() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _responseText = 'Đang thêm đánh giá...';
    });

    try {
      // Get Firebase auth token
      final token = await _auth.currentUser?.getIdToken();

      if (token == null) {
        setState(() {
          _isLoading = false;
          _responseText = 'Lỗi: Bạn cần đăng nhập để thêm đánh giá';
        });
        return;
      }

      final testRating = {
        'productId': _productIdController.text,
        'rating': 4.5,
        'comment': 'Đánh giá test từ màn hình kiểm tra API',
        'userName': _auth.currentUser?.displayName ?? 'Người dùng test',
      };

      final response = await http
          .post(
            Uri.parse('${_serverUrlController.text}/api/ratings'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(testRating),
          )
          .timeout(const Duration(seconds: 10));

      setState(() {
        _isLoading = false;
        _responseText = 'Add Rating Status: ${response.statusCode}\n'
            'Body: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseText = 'Lỗi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra API'),
        backgroundColor: greenColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Kiểm tra kết nối API',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Server URL
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Server',
                border: OutlineInputBorder(),
                hintText: 'http://192.168.56.1:3000',
              ),
            ),
            const SizedBox(height: 12),

            // Product ID
            TextField(
              controller: _productIdController,
              decoration: const InputDecoration(
                labelText: 'ID Sản phẩm',
                border: OutlineInputBorder(),
                hintText: 'test-product',
              ),
            ),
            const SizedBox(height: 20),

            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testHealthCheck,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Kiểm tra kết nối'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testGetRatings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Lấy đánh giá'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAddRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Thêm đánh giá (cần đăng nhập)'),
            ),
            const SizedBox(height: 24),

            // Response display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kết quả:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Text(
                      _responseText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
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
}
