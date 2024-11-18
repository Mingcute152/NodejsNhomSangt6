import 'package:intl/intl.dart';

class ProductModel {
  final String image;
  final String title;
  final String description;
  final double price;

  ProductModel({
    required this.image,
    required this.title,
    required this.description,
    required this.price,
  });

  String get priceString {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );

    return formatter.format(price);
  }
}

final List<ProductModel> products = [
  ProductModel(
    image: 'assets/pharmox.png',
    title: 'Pharmox',
    description: 'Pharmacy',
    price: 20000,
  ),
  ProductModel(
    image: 'assets/durex.png',
    title: 'BCS',
    description: 'pharmacy',
    price: 12000,
  ),
  ProductModel(
    image: 'assets/makeup.png',
    title: 'sua rua mat',
    description: 'Pharmacy',
    price: 13000,
  ),
  ProductModel(
    image: 'assets/paracetamol.png',
    title: 'paracetamol',
    description: 'Pharmacy',
    price: 14000,
  ),
  ProductModel(
    image: 'assets/ruatay.png',
    title: 'lifebouy',
    description: 'Pharmacy',
    price: 15000,
  ),
];
