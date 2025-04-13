class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? address;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.address,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }
}
