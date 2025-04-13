// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/rating_model.dart';
import 'package:flutter_application_3/services/rating_service.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class RatingWidget extends StatefulWidget {
  final String productId;
  final Function(double) onRatingChanged;

  const RatingWidget({
    super.key,
    required this.productId,
    required this.onRatingChanged,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late RatingService _ratingService;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _serverUrlController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double _userRating = 0;
  bool _isLoading = false;
  List<RatingModel> _ratings = [];
  double _averageRating = 0;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isNetworkError = false;
  bool _isTestingConnection = false;
  String? _connectionTestResult;
  bool _isInitializing = true;
  bool _isManuallyConnecting = false;

  @override
  void initState() {
    super.initState();
    _initializeRatingService();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _initializeRatingService() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Attempt to find the best server
      final bestServer = await RatingService.findBestServer();

      // Create rating service with the best server
      _ratingService = RatingService(customBaseUrl: bestServer);

      setState(() {
        _isInitializing = false;
      });

      // Load ratings
      await _loadRatings();
    } catch (e) {
      print('Error initializing rating service: $e');
      _ratingService = RatingService(); // Use default base URL

      setState(() {
        _isInitializing = false;
        _errorMessage =
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
        _isNetworkError = true;
      });
    }
  }

  Future<void> _showManualServerDialog() async {
    _serverUrlController.text = _ratingService.baseUrl;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Kết nối đến server'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nhập địa chỉ server API:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _serverUrlController,
                    decoration: const InputDecoration(
                      hintText: 'http://192.168.56.1:3000/api',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Auto-append /api if not present
                      if (value.isNotEmpty &&
                          !value.endsWith('/api') &&
                          !value.endsWith('/')) {
                        if (!value.contains('/api')) {
                          _serverUrlController.text = '$value/api';
                          _serverUrlController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                                offset: _serverUrlController.text.length),
                          );
                        }
                      }
                    },
                  ),
                  if (_isManuallyConnecting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Hủy'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Kiểm tra'),
                onPressed: _isManuallyConnecting
                    ? null
                    : () async {
                        setDialogState(() {
                          _isManuallyConnecting = true;
                        });

                        final url = _serverUrlController.text.trim();
                        final success =
                            await RatingService.testServerConnection(url);

                        setDialogState(() {
                          _isManuallyConnecting = false;
                        });

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kết nối thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Không thể kết nối đến server'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
              ),
              TextButton(
                child: const Text('Kết nối'),
                onPressed: _isManuallyConnecting
                    ? null
                    : () async {
                        setDialogState(() {
                          _isManuallyConnecting = true;
                        });

                        final url = _serverUrlController.text.trim();
                        final success =
                            await RatingService.testServerConnection(url);

                        setDialogState(() {
                          _isManuallyConnecting = false;
                        });

                        if (success) {
                          Navigator.of(context).pop();
                          _connectToCustomServer(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Không thể kết nối đến server'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _connectToCustomServer(String url) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create new service with the provided URL
      _ratingService = RatingService(customBaseUrl: url);

      // Try loading the ratings
      await _loadRatings();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã kết nối tới server: $url'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể kết nối đến server: $e';
        _isNetworkError = true;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionTestResult = null;
    });

    try {
      // Test localhost
      String result = "Kết quả kiểm tra kết nối:\n\n";

      try {
        final response = await http
            .get(Uri.parse('http://127.0.0.1:3000/health'))
            .timeout(const Duration(seconds: 3));
        result +=
            "localhost (127.0.0.1): ${response.statusCode == 200 ? 'OK ✓' : 'Lỗi ✗'}\n";
      } catch (e) {
        result += "localhost (127.0.0.1): Lỗi kết nối ✗\n";
      }

      // Test IP
      try {
        final response = await http
            .get(Uri.parse('http://192.168.56.1:3000/health'))
            .timeout(const Duration(seconds: 3));
        result +=
            "192.168.56.1: ${response.statusCode == 200 ? 'OK ✓' : 'Lỗi ✗'}\n";
      } catch (e) {
        result += "192.168.56.1: Lỗi kết nối ✗\n";
      }

      // Test Android emulator
      try {
        final response = await http
            .get(Uri.parse('http://10.0.2.2:3000/health'))
            .timeout(const Duration(seconds: 3));
        result +=
            "10.0.2.2 (Emulator): ${response.statusCode == 200 ? 'OK ✓' : 'Lỗi ✗'}\n";
      } catch (e) {
        result += "10.0.2.2 (Emulator): Lỗi kết nối ✗\n";
      }

      // Test current baseUrl
      try {
        final response = await http
            .get(
                Uri.parse(_ratingService.baseUrl.replaceAll('/api', '/health')))
            .timeout(const Duration(seconds: 3));
        result +=
            "Hiện tại (${_ratingService.baseUrl}): ${response.statusCode == 200 ? 'OK ✓' : 'Lỗi ✗'}\n";
      } catch (e) {
        result += "Hiện tại (${_ratingService.baseUrl}): Lỗi kết nối ✗\n";
      }

      setState(() {
        _isTestingConnection = false;
        _connectionTestResult = result;
      });
    } catch (e) {
      setState(() {
        _isTestingConnection = false;
        _connectionTestResult = "Lỗi kiểm tra kết nối: $e";
      });
    }
  }

  Future<void> _reconnectToServer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bestServer = await RatingService.findBestServer();

      // Create new service with best server
      _ratingService = RatingService(customBaseUrl: bestServer);

      // Try loading the ratings again
      await _loadRatings();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã kết nối tới server: $bestServer'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vẫn không thể kết nối đến server: $e';
        _isNetworkError = true;
      });
    }
  }

  Future<void> _loadRatings() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isNetworkError = false;
    });

    try {
      final ratings = await _ratingService.getProductRatings(widget.productId);
      final averageRating =
          await _ratingService.getAverageRating(widget.productId);

      if (mounted) {
        setState(() {
          _ratings = ratings;
          _averageRating = averageRating;
          _isLoading = false;
        });

        widget.onRatingChanged(_averageRating);
      }
    } catch (e) {
      print('Error loading ratings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isNetworkError = e.toString().contains('Connection') ||
              e.toString().contains('network') ||
              e.toString().contains('socket') ||
              e.toString().contains('timeout');
          _errorMessage = _isNetworkError
              ? 'Lỗi kết nối đến server. Vui lòng kiểm tra kết nối mạng và thử lại sau.'
              : 'Không thể tải đánh giá. Vui lòng thử lại sau.';
        });
      }
    }
  }

  Future<void> _addRating() async {
    // Debug information
    print("Attempting to add rating for product: ${widget.productId}");

    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao')),
      );
      return;
    }

    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để đánh giá')),
      );
      return;
    }

    // More debug information
    print("User authenticated: ${_auth.currentUser?.uid}");
    print("Rating value: $_userRating");
    print("Comment: ${_commentController.text}");

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _isNetworkError = false;
    });

    try {
      final user = _auth.currentUser!;

      // Create the rating object with validation
      final rating = RatingModel(
        id: '',
        productId: widget.productId.trim(),
        userId: user.uid,
        userName:
            user.displayName ?? user.email?.split('@').first ?? 'Người dùng',
        rating: _userRating,
        comment: _commentController.text,
        createdAt: DateTime.now(),
      );

      print("Submitting rating object: ${rating.toJson()}");

      // Wait with timeout
      final result = await _ratingService
          .addRating(rating)
          .timeout(Duration(seconds: 30), onTimeout: () {
        return {
          'success': false,
          'message': 'Đã hết thời gian chờ, vui lòng thử lại sau'
        };
      });

      print("Rating submission result: $result");

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
          _commentController.clear();
          setState(() {
            _userRating = 0;
          });
          await _loadRatings();
        } else {
          final isConnectionError =
              result['message'].toString().contains('kết nối') ||
                  result['message'].toString().contains('server');
          setState(() {
            _errorMessage = result['message'];
            _isNetworkError = isConnectionError;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _addRating: $e');
      if (mounted) {
        final isConnectionError = e.toString().contains('Connection') ||
            e.toString().contains('network') ||
            e.toString().contains('socket') ||
            e.toString().contains('timeout');
        setState(() {
          _isSubmitting = false;
          _isNetworkError = isConnectionError;
          _errorMessage = isConnectionError
              ? 'Lỗi kết nối đến server. Vui lòng kiểm tra kết nối mạng và thử lại sau.'
              : 'Đã xảy ra lỗi khi gửi đánh giá: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang kết nối đến server...'),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Đánh giá trung bình
        Row(
          children: [
            Text(
              'Đánh giá (${_ratings.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              _averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            ...List.generate(5, (index) {
              return Icon(
                index < _averageRating.floor()
                    ? Icons.star
                    : (index < _averageRating.ceil() &&
                            index > _averageRating.floor())
                        ? Icons.star_half
                        : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
          ],
        ),
        const SizedBox(height: 16),

        // Hiển thị lỗi nếu có
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_isNetworkError ? Icons.wifi_off : Icons.error_outline,
                        color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                      color: Colors.red.shade700,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (_isNetworkError) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Vui lòng kiểm tra kết nối internet của bạn và backend server. URL hiện tại: ${_ratingService.baseUrl}',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _showManualServerDialog,
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('Nhập URL',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _reconnectToServer,
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('Tìm server tự động',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

        // Phần debug và kiểm tra kết nối
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      print("Server URL: ${_ratingService.baseUrl}/ratings");
                      print("Product ID: ${widget.productId}");
                      print("User ID: ${_auth.currentUser?.uid}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Debug info printed to console')),
                      );
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Debug Info'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTestingConnection ? null : _testConnection,
                    icon: const Icon(Icons.network_check),
                    label: _isTestingConnection
                        ? const SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Kiểm tra kết nối'),
                  ),
                ),
              ],
            ),
          ),

        // Hiển thị kết quả kiểm tra kết nối
        if (_connectionTestResult != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Kết quả kiểm tra kết nối",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _connectionTestResult = null;
                        });
                      },
                      color: Colors.blue.shade700,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _connectionTestResult!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _showManualServerDialog,
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text('Nhập URL thủ công',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _reconnectToServer,
                      icon: const Icon(Icons.autorenew, size: 14),
                      label: const Text('Cấu hình lại kết nối',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Form đánh giá
        if (_auth.currentUser != null)
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đánh giá của bạn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _userRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _userRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Nhập đánh giá của bạn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _addRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Gửi đánh giá'),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Danh sách đánh giá
        _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            : _ratings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Chưa có đánh giá nào cho sản phẩm này',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_isLoading == false && _errorMessage != null)
                            TextButton.icon(
                              onPressed: _loadRatings,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                            ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ratings.length,
                    itemBuilder: (context, index) {
                      final rating = _ratings[index];
                      String formattedDate;
                      try {
                        formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                            .format(rating.createdAt);
                      } catch (e) {
                        formattedDate = 'Ngày không xác định';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rating.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < rating.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              if (rating.comment.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(rating.comment),
                              ],

                              // Nút xóa đánh giá (chỉ hiển thị với người dùng hiện tại)
                              if (_auth.currentUser?.uid == rating.userId)
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Xóa đánh giá'),
                                          content: const Text(
                                              'Bạn có chắc chắn muốn xóa đánh giá này không?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Hủy'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text('Xóa'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        final result = await _ratingService
                                            .deleteRating(rating.id);

                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });

                                          if (result['success']) {
                                            _loadRatings();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content:
                                                      Text(result['message'])),
                                            );
                                          } else {
                                            final isConnectionError =
                                                result['message']
                                                        .toString()
                                                        .contains('kết nối') ||
                                                    result['message']
                                                        .toString()
                                                        .contains('server');
                                            setState(() {
                                              _errorMessage = result['message'];
                                              _isNetworkError =
                                                  isConnectionError;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text(result['message']),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 30),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Xóa'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

        // Nút tải lại
        if (_ratings.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton.icon(
                onPressed: _loadRatings,
                icon: const Icon(Icons.refresh),
                label: const Text('Tải thêm đánh giá'),
              ),
            ),
          ),
      ],
    );
  }
}
