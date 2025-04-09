import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveShippingAddress(String address) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'shippingAddress': address,
        });
      }
    } catch (e) {
      throw Exception("Lỗi khi lưu địa chỉ: $e");
    }
  }

  Future<String?> getShippingAddress() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final doc = await _firestore.collection('users').doc(userId).get();
        return doc.data()?['shippingAddress'] as String?;
      }
    } catch (e) {
      throw Exception("Lỗi khi lấy địa chỉ: $e");
    }
    return null;
  }
}
