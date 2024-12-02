// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:intl/intl.dart';

class ProductModel {
  final String id;
  final String image;
  final String title;
  final String description;
  final double price;
  int quantity;

  ProductModel({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.price,
    this.quantity = 1,
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
  }) {
    return ProductModel(
      id: id ?? this.id,
      image: image ?? this.image,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
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
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      image: map['image'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: double.tryParse(map['price']?.toString() ?? '') ?? 0.0,
      quantity: int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
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
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        image.hashCode ^
        title.hashCode ^
        description.hashCode ^
        price.hashCode ^
        quantity.hashCode;
  }
}
