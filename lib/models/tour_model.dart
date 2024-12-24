class Tour {
  final String id;
  final String title;
  final String description;
  final List<String> itinerary;
  final double price;
  final int durationDays;
  final String departureDate;
  final String destination;
  final List<String> images;
  final bool featured;
  final String status;

  Tour({
    required this.id,
    required this.title,
    required this.description,
    required this.itinerary,
    required this.price,
    required this.durationDays,
    required this.departureDate,
    required this.destination,
    required this.images,
    required this.featured,
    required this.status
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    final dateList = json['departureDate'] as List<dynamic>?;
    String dateString = '';
    if (dateList != null && dateList.isNotEmpty) {
      // ghép mảng thành chuỗi "2024-12-07"
      dateString = dateList.join('-'); 
    }
    return Tour(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      itinerary: List<String>.from(json['itinerary'] ?? []),
      price: (json['price'] as num).toDouble(),
      durationDays: json['durationDays'] ?? 0,
      departureDate: dateString,
      destination: json['destination'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      featured: json['featured'] ?? false,
      status:  json['status'] ?? '',
    );
  }
}
