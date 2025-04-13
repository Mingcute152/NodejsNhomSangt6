// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_application_3/model/product_model.dart';

class CartModel {
  String id;
  final String userId;
  late final List<ProductModel> listProduct;
  final int status;
  final DateTime? createDate;
  final double? totalPrice;

  CartModel({
    required this.id,
    required this.userId,
    required this.listProduct,
    required this.status,
    this.createDate,
    this.totalPrice,
  });

  CartModel copyWith({
    String? id,
    String? userId,
    List<ProductModel>? listProduct,
    int? status,
    DateTime? createDate,
    double? totalPrice,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listProduct: listProduct ?? this.listProduct,
      status: status ?? this.status,
      createDate: createDate ?? this.createDate,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'listProduct': listProduct.map((x) => x.toMap()).toList(),
      'status': status,
      'createDate': createDate.toString(),
      'totalPrice': totalPrice,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    // print('123123123123123123');
    Timestamp timestamp = map['createdAt'] ?? Timestamp.now();
    return CartModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      listProduct: (map['products'] as List<dynamic>? ?? [])
          .map((x) => ProductModel.fromMap(x as Map<String, dynamic>))
          .toList(),
      // listProduct: [],
      status: int.tryParse(map['status']?.toString() ?? '1') ?? 1,
      createDate: timestamp.toDate(),
      totalPrice: double.tryParse(map['totalPrice']?.toString() ?? '0') ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CartModel.fromJson(String source) =>
      CartModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CartModel(id: $id, userId: $userId, listProduct: $listProduct)';

  @override
  bool operator ==(covariant CartModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        listEquals(other.listProduct, listProduct) &&
        other.status == status;
  }

  @override
  int get hashCode =>
      id.hashCode ^ userId.hashCode ^ listProduct.hashCode ^ status.hashCode;
}
