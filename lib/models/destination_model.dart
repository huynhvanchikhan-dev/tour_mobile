class Destination {
  final String id;
  final String name;
  final int tourCount;
  final String url;

  Destination({
    required this.id,
    required this.name,
    required this.tourCount,
    required this.url,
  });

  // Tạo phương thức để chuyển JSON thành đối tượng Destination
  factory Destination.fromJson(Map<String, dynamic> json) {
    
    return Destination(
      id: json['id'],
      name: json['name'],
      tourCount: json['tourCount'],
      url: json['url'],
    );
  }
}