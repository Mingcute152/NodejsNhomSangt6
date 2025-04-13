// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String image;
  final String title;
  final String description;
  final double price;
  int quantity;
  final int type;

  ProductModel({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.price,
    this.quantity = 1,
    required this.type,
  });

  String get priceString {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );

    return formatter.format(price);
  }

  ProductModel copyWith({
    String? id,
    String? image,
    String? title,
    String? description,
    double? price,
    int? quantity,
    int? type,
  }) {
    return ProductModel(
      id: id ?? this.id,
      image: image ?? this.image,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'image': image,
      'title': title,
      'description': description,
      'price': price,
      'quantity': quantity,
      'type': type,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description'] ?? '',
      price: double.tryParse(map['price']?.toString() ?? '') ?? 0.0,
      quantity: int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
      type: int.tryParse(map['type']?.toString() ?? '0') ?? 0,
      // price: 0,
      // quantity: 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductModel(image: $image, title: $title, description: $description, price: $price)';
  }

  @override
  bool operator ==(covariant ProductModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.image == image &&
        other.title == title &&
        other.description == description &&
        other.price == price &&
        other.quantity == quantity &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        image.hashCode ^
        title.hashCode ^
        description.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        type.hashCode;
  }

  String getImageUrl() {
    if (image.isEmpty) return '';

    // Không thay đổi đường dẫn, chỉ trả về đúng format
    return image;
  }

  Widget getImageWidget(
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    try {
      // Case 1: Asset image (path starts with 'assets/')
      if (image.startsWith('assets/')) {
        return Image.asset(
          image,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('Asset image error: $error');
            return _buildErrorContainer(width, height);
          },
        );
      }
      // Case 2: Empty or invalid image path
      else if (image.isEmpty) {
        return _buildErrorContainer(width, height);
      }
      // Case 3: Network image
      else {
        return Image.network(
          image,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              color: Colors.grey.shade200,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Network image error for path $image: $error');
            return _buildErrorContainer(width, height);
          },
        );
      }
    } catch (e) {
      print('Exception loading image $image: $e');
      return _buildErrorContainer(width, height);
    }
  }

  // Helper method for error placeholder
  Widget _buildErrorContainer(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, color: Colors.grey),
          if (width != null && width > 60)
            Text(
              'Image not available',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }
}
