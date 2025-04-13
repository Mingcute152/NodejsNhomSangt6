// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/product_model.dart';
import 'package:flutter_application_3/services/product_service.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:flutter_application_3/widget/product_admin_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Load danh sách sản phẩm từ API
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productService.fetchProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải sản phẩm: $e';
        _isLoading = false;
      });
    }
  }

  // Xóa sản phẩm
  Future<void> _deleteProduct(ProductModel product) async {
    // Hiển thị hộp thoại xác nhận
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa sản phẩm'),
            content: Text('Bạn có chắc chắn muốn xóa "${product.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Hiển thị đang xóa sản phẩm
      const deleteSnackBar = SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Đang xóa sản phẩm...'),
          ],
        ),
        duration: Duration(seconds: 60), // Thời gian dài để hiển thị quá trình
        backgroundColor: Colors.blue,
      );

      ScaffoldMessenger.of(context).showSnackBar(deleteSnackBar);

      // Gọi API xóa sản phẩm
      final result = await _productService.deleteProduct(product.id);

      // Đóng SnackBar đang hiển thị
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result['success']) {
        // Nếu xóa thành công, cập nhật lại danh sách
        setState(() {
          _products.removeWhere((p) => p.id == product.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${result['message']}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        String errorMessage = result['message'];

        // Hiển thị thông báo lỗi chi tiết hơn
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('❌ Không thể xóa sản phẩm',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(errorMessage),
                const SizedBox(height: 4),
                const Text('Vui lòng kiểm tra kết nối mạng và thử lại.',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Đóng SnackBar đang hiển thị
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi không xác định: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Chỉnh sửa sản phẩm
  Future<void> _editProduct(ProductModel product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductAdminScreen(product: product),
      ),
    );

    // Nếu có sự thay đổi, tải lại danh sách sản phẩm
    if (result == true) {
      _loadProducts();
    }
  }

  // Thêm sản phẩm mới
  Future<void> _addNewProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductAdminScreen(),
      ),
    );

    // Nếu có sản phẩm mới được thêm, tải lại danh sách
    if (result == true) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: const Text(
          'Quản lý sản phẩm',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProducts,
            tooltip: 'Tải lại',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: greenColor,
        onPressed: _addNewProduct,
        child: const Icon(Icons.add),
        tooltip: 'Thêm sản phẩm mới',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProducts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _products.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có sản phẩm nào',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: ListView.builder(
                        itemCount: _products.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: product.getImageWidget(
                                    width: 60, height: 60, fit: BoxFit.cover),
                              ),
                              title: Text(
                                product.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                product.priceString,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _editProduct(product),
                                    tooltip: 'Chỉnh sửa',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteProduct(product),
                                    tooltip: 'Xóa',
                                  ),
                                ],
                              ),
                              onTap: () => _editProduct(product),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
