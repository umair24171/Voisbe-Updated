// changin user account model

class UserAccount {
  final String name;
  final String email;
  final String password;
  final String profileImage;
  final bool isVerified;

  UserAccount(
      {required this.name,
      required this.email,
      required this.profileImage,
      required this.password,
      required this.isVerified});

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      name: map['name'],
      isVerified: map['isVerified'],
      email: map['email'],
      profileImage: map['profileImage'],
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'password': password,
      'isVerified': isVerified
    };
  }
}
