import 'package:get/get.dart';
import 'package:flutter_application_3/services/pay_service.dart';

class PayController extends GetxController {
  final PayService _payService = PayService();

  Future<void> payWithBank(
      String productName, int quantity, int totalPrice) async {
    await _payService.payWithBank(productName, quantity, totalPrice);
  }

  Future<void> payWithMoMo(
      String productName, int quantity, int totalPrice) async {
    await _payService.payWithMoMo(productName, quantity, totalPrice);
  }

  Future<void> chooseShippingMethod() async {
    await _payService.chooseShippingMethod();
  }
}
