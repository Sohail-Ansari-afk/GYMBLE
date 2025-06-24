import 'package:hive/hive.dart';

part 'gym.g.dart';

@HiveType(typeId: 1)
class Gym {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String? imageUrl;

  Gym({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'image_url': imageUrl,
    };
  }
}