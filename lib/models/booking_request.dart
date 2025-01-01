class BookingRequest {
  final String fullname;
  final String phone;
  final String cin;
  final int guestSize;
  final int amount;
  final String tour_id;

  BookingRequest({
    required this.fullname,
    required this.phone,
    required this.cin,
    required this.guestSize,
    required this.amount,
    required this.tour_id,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'phone': phone,
      'cin': cin,
      'guestSize': guestSize,
      'amount': amount,
      'tour_id': tour_id,
    };
  }
}
