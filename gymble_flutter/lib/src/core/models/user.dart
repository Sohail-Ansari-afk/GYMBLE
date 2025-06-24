import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? name;

  @HiveField(3)
  final String? profileImageUrl;

  @HiveField(4)
  final String gymId;

  @HiveField(5)
  final String? gymName;

  @HiveField(6)
  final String? token;

  User({
    required this.id,
    required this.email,
    this.name,
    this.profileImageUrl,
    required this.gymId,
    this.gymName,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
      gymId: json['gym_id'] ?? '',
      gymName: json['gym_name'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'profile_image_url': profileImageUrl,
      'gym_id': gymId,
      'gym_name': gymName,
      'token': token,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    String? gymId,
    String? gymName,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      gymId: gymId ?? this.gymId,
      gymName: gymName ?? this.gymName,
      token: token ?? this.token,
    );
  }
}