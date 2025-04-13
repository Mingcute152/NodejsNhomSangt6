// ignore_for_file: unused_import, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/product_model.dart';
import 'package:flutter_application_3/services/product_service.dart';
import 'package:flutter_application_3/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class ProductAdminScreen extends StatefulWidget {
  final ProductModel? product; // Null means adding new product

  const ProductAdminScreen({super.key, this.product});

  @override
  State<ProductAdminScreen> createState() => _ProductAdminScreenState();
}

class _ProductAdminScreenState extends State<ProductAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  int _selectedType = 0;
  File? _imageFile;
  bool _isLoading = false;
  String? _errorMessage;
  final ProductService _productService = ProductService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // If editing an existing product, populate the form fields
    if (widget.product != null) {
      _titleController.text = widget.product!.title;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.image;
      _selectedType = widget.product!.type;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Giảm chất lượng để giảm kích thước
        maxWidth: 800, // Giới hạn chiều rộng tối đa
        maxHeight: 800, // Giới hạn chiều cao tối đa
      );

      if (pickedFile != null) {
        print('Image picked: ${pickedFile.path}');

        final File imageFile = File(pickedFile.path);
        final int fileSize = await imageFile.length();
        print(
            'Original image size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

        // Kiểm tra kích thước và hiển thị cảnh báo nếu quá lớn
        if (fileSize > 2 * 1024 * 1024) {
          // > 2MB
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Hình ảnh có dung lượng lớn (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB). Có thể tải chậm.'),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        setState(() {
          _imageFile = imageFile;
          _imageUrlController.text = ''; // Xóa URL cũ khi chọn ảnh mới
        });
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      String errorMessage = 'Lỗi khi chọn ảnh';

      if (e.toString().contains('permission')) {
        errorMessage =
            'Không có quyền truy cập thư viện ảnh. Vui lòng cấp quyền trong cài đặt.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // Tải ảnh lên Firebase Storage
  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _imageUrlController.text;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('Starting image upload process');

      // Kiểm tra kích thước file ảnh
      final fileSize = await _imageFile!.length();
      print('Image file size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Kích thước ảnh quá lớn (tối đa 5MB)');
      }

      // Tạo tên file duy nhất
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_imageFile!.path)}';
      print('Generated filename: $fileName');

      final storageRef = _storage.ref().child('products/$fileName');
      print('Storage reference created');

      // Tải lên Firebase Storage với progress
      final uploadTask = storageRef.putFile(_imageFile!);
      print('Upload task started');

      // Theo dõi tiến trình upload (tùy chọn)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      // Đợi hoàn thành upload
      await uploadTask;
      print('Upload completed');

      // Lấy URL tải xuống
      final String downloadUrl = await storageRef.getDownloadURL();
      print('Download URL obtained: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('ERROR in _uploadImage: $e');

      String errorMessage = 'Không thể tải ảnh lên';

      // Chi tiết hơn về lỗi
      if (e.toString().contains('network')) {
        errorMessage = 'Lỗi kết nối mạng khi tải ảnh lên';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'Không có quyền tải ảnh lên storage';
      } else if (e.toString().contains('unauthorized')) {
        errorMessage = 'Bạn cần đăng nhập để tải ảnh lên';
      } else {
        errorMessage = 'Lỗi: ${e.toString().split('\n')[0]}';
      }

      setState(() {
        _errorMessage = errorMessage;
      });

      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Lưu sản phẩm
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final imageUrl = widget.product?.image ?? '';
        // Nếu là chỉnh sửa sản phẩm và ảnh không thay đổi, thì giữ nguyên URL ảnh cũ
        if (_imageFile == null &&
            widget.product != null &&
            imageUrl.isNotEmpty) {
          print('Using existing image URL: $imageUrl');

          // Tạo và lưu sản phẩm với URL ảnh cũ
          final product = ProductModel(
            id: widget.product!.id,
            title: _titleController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            image: imageUrl,
            type: _selectedType,
          );

          final result = await _productService.updateProduct(
              widget.product!.id, product.toMap());

          setState(() {
            _isLoading = false;
          });

          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'])),
            );
            Navigator.pop(context, true); // Return success
          } else {
            setState(() {
              _errorMessage = result['message'];
            });
          }
          return;
        }

        // Nếu đây là sản phẩm mới và không có ảnh
        if (_imageFile == null && imageUrl.isEmpty) {
          setState(() {
            _errorMessage = 'Vui lòng chọn ảnh sản phẩm';
            _isLoading = false;
          });
          return;
        }

        // Tải ảnh lên nếu có ảnh mới
        if (_imageFile != null) {
          int retryCount = 0;
          String? finalImageUrl;

          while (retryCount < 2 && finalImageUrl == null) {
            if (retryCount > 0) {
              // Hiển thị thông báo đang thử lại
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Đang thử lại lần ${retryCount + 1}...')),
              );
            }

            try {
              finalImageUrl = await _uploadImage();
              if (finalImageUrl == null) {
                // Nếu upload thất bại, tăng số lần thử và thử lại sau 1 giây
                retryCount++;
                await Future.delayed(Duration(seconds: 1));
              }
            } catch (e) {
              retryCount++;
              print('Upload attempt $retryCount failed: $e');
              await Future.delayed(Duration(seconds: 1));
            }
          }

          if (finalImageUrl == null) {
            setState(() {
              _errorMessage =
                  'Không thể tải ảnh lên sau nhiều lần thử. Vui lòng kiểm tra kết nối mạng và thử lại.';
              _isLoading = false;
            });
            return;
          }

          // Tạo mô hình sản phẩm với URL ảnh mới
          final product = ProductModel(
            id: widget.product?.id ?? '',
            title: _titleController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            image: finalImageUrl,
            type: _selectedType,
          );

          // API call để lưu sản phẩm
          final result = widget.product == null
              ? await _productService.addProduct(product)
              : await _productService.updateProduct(
                  widget.product!.id, product.toMap());

          setState(() {
            _isLoading = false;
          });

          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'])),
            );
            Navigator.pop(context, true); // Return success
          } else {
            setState(() {
              _errorMessage = result['message'];
            });
          }
        }
      } catch (uploadError) {
        print('Error during product save: $uploadError');
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Lỗi khi lưu sản phẩm: ${uploadError.toString().split('\n')[0]}';
        });
      }
    } catch (e) {
      print('General error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi không xác định: ${e.toString().split('\n')[0]}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: Text(
          widget.product == null ? 'Thêm sản phẩm mới' : 'Chỉnh sửa sản phẩm',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),

                    // Hình ảnh sản phẩm
                    const Text(
                      'Hình ảnh sản phẩm',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _imageUrlController.text.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _imageUrlController.text
                                            .startsWith('assets/')
                                        ? Image.asset(
                                            _imageUrlController.text,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  'Asset image error: $error');
                                              return Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          )
                                        : Image.network(
                                            _imageUrlController.text,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  'Network image error: $error');
                                              return Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_photo_alternate,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Nhấn để chọn ảnh',
                                        style: TextStyle(
                                            color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tiêu đề sản phẩm
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Tên sản phẩm',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên sản phẩm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mô tả sản phẩm
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả sản phẩm',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mô tả sản phẩm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Giá sản phẩm
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Giá (VNĐ)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập giá sản phẩm';
                        }
                        try {
                          final price = double.parse(value);
                          if (price <= 0) {
                            return 'Giá phải lớn hơn 0';
                          }
                        } catch (e) {
                          return 'Giá không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Loại sản phẩm
                    const Text(
                      'Loại sản phẩm',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Thời trang'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Điện tử'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Đồ gia dụng'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('Sách'),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('Khác'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value ?? 0;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Nút lưu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.product == null
                              ? 'Thêm sản phẩm'
                              : 'Cập nhật sản phẩm',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
