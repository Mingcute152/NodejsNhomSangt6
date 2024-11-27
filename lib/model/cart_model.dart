// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_application_3/model/product_model.dart';

class CartModel {
  final String id;
  final String userId;
  final List<ProductModel> listProduct;
  CartModel({
    required this.id,
    required this.userId,
    required this.listProduct,
  });

  CartModel copyWith({
    String? id,
    String? userId,
    List<ProductModel>? listProduct,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listProduct: listProduct ?? this.listProduct,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'listProduct': listProduct.map((x) => x.toMap()).toList(),
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      listProduct: (map['listProduct'] ?? []).map(
        (x) => ProductModel.fromMap(x as Map<String, dynamic>),
      ),
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
        listEquals(other.listProduct, listProduct);
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ listProduct.hashCode;
}
