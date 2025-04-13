// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:flutter_application_3/model/user_model.dart';
import 'package:flutter_application_3/services/user_service.dart';

class UserController extends GetxController {
  final UserService _userService = UserService();
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  Future<void> getUserProfile() async {
    try {
      isLoading.value = true;
      final userProfile = await _userService.getUserProfile();
      user.value = userProfile;
    } catch (e) {
      print('Error in getUserProfile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      if (user.value == null) return;

      final updatedUser = UserModel(
        id: user.value!.id,
        email: user.value!.email,
        name: name ?? user.value!.name,
        phoneNumber: phoneNumber ?? user.value!.phoneNumber,
        address: address ?? user.value!.address,
      );

      await _userService.updateUserProfile(updatedUser);
      user.value = updatedUser;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    }
  }
}
