import 'package:get/get.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) {
      user.value = newUser;
    });
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.logout();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      await _authService.deleteAccount();
    } finally {
      isLoading.value = false;
    }
  }
}
