import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: IdentityCardScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class IdentityCardScreen extends StatelessWidget {
  const IdentityCardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kích thước giả lập cho thẻ, bạn có thể tuỳ chỉnh lại.
    final cardWidth = 350.0;
    final cardHeight = 220.0;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              )
            ],
          ),
          child: Stack(
            children: [
              // Background mờ (có thể chèn ảnh nền/xử lý gradient,...)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/background_map.png', // map Việt Nam
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Nội dung chính
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Quốc huy + Chữ "CỘNG HOÀ..." + "SOCIALIST REPUBLIC..."
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quốc huy (giả sử dùng Image.asset)
                        Image.asset(
                          'assets/images/quoc_huy.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'CỘNG HOÀ XÃ HỘI CHỦ NGHĨA VIỆT NAM',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Độc lập - Tự do - Hạnh phúc',
                                style: TextStyle(
                                  fontSize: 9,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'SOCIALIST REPUBLIC OF VIETNAM',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Independence - Freedom - Happiness',
                                style: TextStyle(
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // QR Code bên phải
                        Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[200], // Placeholder
                          child: Center(
                            child: Text(
                              'QR',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    // Tiêu đề "Căn Cước Công Dân"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'CĂN CƯỚC CÔNG DÂN',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Text "Citizen Identity Card"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Citizen Identity Card',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    // Thông tin chính
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ảnh chân dung
                          Container(
                            width: 60,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Các trường thông tin
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  title: 'Số / No.:',
                                  value: 'XXXXXXXX',
                                ),
                                _buildInfoRow(
                                  title: 'Họ và tên | Full name:',
                                  value: 'Nguyễn Văn A',
                                ),
                                _buildInfoRow(
                                  title: 'Ngày sinh | Date of birth:',
                                  value: '01/01/1990',
                                ),
                                _buildInfoRow(
                                  title: 'Giới tính | Sex:',
                                  value: 'Nam',
                                ),
                                _buildInfoRow(
                                  title: 'Quốc tịch | Nationality:',
                                  value: 'Việt Nam',
                                ),
                                _buildInfoRow(
                                  title: 'Quê quán | Place of origin:',
                                  value: 'Hà Nội',
                                ),
                                _buildInfoRow(
                                  title: 'Nơi thường trú | Place of residence:',
                                  value: 'TP. Hồ Chí Minh',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Thời hạn
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Có giá trị đến | Date of expiry:',
                          style: TextStyle(fontSize: 10),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'DD/MM/YYYY',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hàm tiện ích để xây dựng mỗi dòng thông tin
  Widget _buildInfoRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: '$title ',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 10,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
