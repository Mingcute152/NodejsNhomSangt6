import 'package:get/get.dart';
import 'package:flutter_application_3/services/pay_service.dart';

class PaymentController extends GetxController {
  final PayService _payService = PayService();

  Future<void> payWithMoMo(
      String productName, int quantity, int totalPrice) async {
    await _payService.payWithMoMo(productName, quantity, totalPrice);
  }
}
