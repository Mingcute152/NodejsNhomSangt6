import 'package:flutter/material.dart';

enum StatusOrder {
  chuathanhtoan(0),
  danggiaohang(1),
  dagiao(2),
  doitra(3);

  final int typeOrder;
  const StatusOrder(this.typeOrder);
}

extension StatusOrderY on int {
  StatusOrder get statusOrder {
    switch (this) {
      case 0:
        return StatusOrder.chuathanhtoan;
      case 1:
        return StatusOrder.danggiaohang;
      case 2:
        return StatusOrder.dagiao;
      case 3:
        return StatusOrder.doitra;
      default:
        return StatusOrder.chuathanhtoan;
    }
  }
}

extension StatusOrderX on StatusOrder {
  String get name {
    switch (this) {
      case StatusOrder.chuathanhtoan:
        return 'Chưa thanh toán';

      case StatusOrder.danggiaohang:
        return 'Đang giao hàng';
      case StatusOrder.dagiao:
        return 'Đã giao';
      case StatusOrder.doitra:
        return 'Đã trả';
    }
  }

  Color get getColor {
    switch (this) {
      case StatusOrder.chuathanhtoan:
        return Colors.red;

      case StatusOrder.danggiaohang:
        return Colors.blue;
      case StatusOrder.dagiao:
        return Colors.orange;
      case StatusOrder.doitra:
        return Colors.purple;
    }
  }
}
