// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class PayService {
  final String momoEndpoint =
      "https://test-payment.momo.vn/v2/gateway/api/create";
  final String partnerCode =
      "YOUR_PARTNER_CODE"; // Thay bằng mã đối tác của bạn
  final String accessKey = "YOUR_ACCESS_KEY"; // Thay bằng access key của bạn
  final String secretKey = "YOUR_SECRET_KEY"; // Thay bằng secret key của bạn
  final String redirectUrl =
      "YOUR_REDIRECT_URL"; // URL chuyển hướng sau thanh toán
  final String ipnUrl = "YOUR_IPN_URL"; // URL nhận thông báo từ MoMo

  Future<void> payWithMoMo(
      String productName, int quantity, int totalPrice) async {
    try {
      final String requestId = DateTime.now().millisecondsSinceEpoch.toString();
      final String orderId = "order_$requestId";

      // Tạo chữ ký (signature)
      final String rawData =
          "accessKey=$accessKey&amount=$totalPrice&extraData=&ipnUrl=$ipnUrl&orderId=$orderId&orderInfo=$productName&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=captureWallet";
      final String signature = _generateSignature(rawData);

      // Tạo payload gửi đến MoMo
      final Map<String, dynamic> payload = {
        "partnerCode": partnerCode,
        "accessKey": accessKey,
        "requestId": requestId,
        "amount": totalPrice.toString(),
        "orderId": orderId,
        "orderInfo": productName,
        "redirectUrl": redirectUrl,
        "ipnUrl": ipnUrl,
        "extraData": "",
        "requestType": "captureWallet",
        "signature": signature,
      };

      // Gửi yêu cầu HTTP POST đến MoMo
      final response = await http.post(
        Uri.parse(momoEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final payUrl = responseData['payUrl'];
        if (payUrl != null) {
          // Mở URL thanh toán trong trình duyệt
        } else {
          throw Exception("Không thể tạo giao dịch MoMo.");
        }
      } else {
        throw Exception("Lỗi khi kết nối đến MoMo: ${response.body}");
      }
    } catch (e) {}
  }

  String _generateSignature(String rawData) {
    // Tạo chữ ký HMAC SHA256
    final key = utf8.encode(secretKey);
    final bytes = utf8.encode(rawData);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  Future<void> payWithBank(
      String productName, int quantity, int totalPrice) async {
    // Logic thanh toán qua ngân hàng
  }

  Future<void> chooseShippingMethod() async {
    // Logic chọn phương thức vận chuyển
  }
}
