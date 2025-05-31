class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String? token;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? 0,
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        gender: json['gender'] ?? '',
        image: json['image'] ?? '',
        token: json['token'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'image': image,
        'token': token,
      };
}
