import 'dart:convert';

class Restaurant {
  final String userId;
  final String name;
  final String location;
  final Map<String, dynamic> menu;
  final String? imageUrl;

  Restaurant({
    required this.userId,
    required this.name,
    required this.location,
    required this.menu,
    this.imageUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> menuData = {};
    if (json['menu'] != null) {
      if (json['menu'] is String) {
        menuData = jsonDecode(json['menu']);
      } else {
        menuData = Map<String, dynamic>.from(json['menu']);
      }
    }
    return Restaurant(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      menu: menuData,
      imageUrl: json['image_url'],
    );
  }
}
