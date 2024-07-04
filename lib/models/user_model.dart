class User {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? gender;
  final String? phone;

  User({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.gender,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      gender: json['gender'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'gender': gender,
      'phone': phone,
    };
  }
}
