import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// 📍 Google Places Service
///
/// ⚠️ DEMO MODE ENABLED ⚠️
/// Places API hiện đang TẮT để tránh lỗi billing.
/// Service này đang sử dụng 25 địa điểm DEMO có sẵn.
///
/// ✅ Lợi ích:
/// - Không lỗi REQUEST_DENIED
/// - Không tốn phí API
/// - Test UI/UX được ngay
/// - Coordinates chính xác
///
/// 🔄 Khi nào bật Places API thật?
/// - Khi backend ready
/// - Khi Google Cloud billing OK
/// - Uncomment code trong searchPlaces() method
///
///

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
    );
  }
}

class PlaceDetails {
  final double latitude;
  final double longitude;
  final String formattedAddress;

  PlaceDetails({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final location = json['result']?['geometry']?['location'];
    return PlaceDetails(
      latitude: (location?['lat'] ?? 0.0).toDouble(),
      longitude: (location?['lng'] ?? 0.0).toDouble(),
      formattedAddress: json['result']?['formatted_address'] ?? '',
    );
  }
}

class GooglePlacesService {
  // ⚠️ THAY API KEY Ở ĐÂY
  static const String apiKey = 'AIzaSyDhgfGtPlXoakaCKXMQwVHA0axMXB53Ejo';
  static const String baseUrl = 'https://maps.googleapis.com/maps/api/place';


  /// Tìm kiếm địa điểm với autocomplete
  Future<List<PlacePrediction>> searchPlaces(String input) async {
    if (input.isEmpty) return [];

    // 🔒 TẠM THỜI TẮT PLACES API - Chỉ dùng demo data
    // Sẽ bật lại khi backend ready và billing được setup đúng
    print('📦 Using DEMO mode - Places API disabled');
    return _getDemoData(input);

    /*
    // ⚠️ Code này sẽ dùng lại khi tích hợp Places API thật
    final session = _uuid.v4();
    final encoded = Uri.encodeQueryComponent(input);
    final url = Uri.parse(
      '$baseUrl/autocomplete/json?input=$encoded&key=$apiKey&components=country:vn&language=vi&sessiontoken=$session',
    );

    try {
      print('🔍 Searching places with input: "$input"');
      print('📡 Request URL: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = (data['predictions'] as List)
              .map((json) => PlacePrediction.fromJson(json))
              .toList();
          print('✅ Found ${predictions.length} predictions');
          return predictions;
        } else {
          print('⚠️ Places API returned status: ${data['status']}');
          print('⚠️ Error message: ${data['error_message']}');

          if (data['status'] == 'REQUEST_DENIED') {
            print('');
            print('❌❌❌ LỖI BILLING - HƯỚNG DẪN SỬA ❌❌❌');
            print('Nguyên nhân: Google Cloud Project chưa bật Billing');
            print('');
            print('CÁCH SỬA (3 BƯỚC):');
            print('1. Mở: https://console.cloud.google.com/billing');
            print('2. Tạo/chọn Billing Account và link vào project');
            print('3. Bật Places API tại: https://console.cloud.google.com/apis/library/places-backend.googleapis.com');
            print('');
            print('🔑 API Key hiện tại: $apiKey');
            print('📝 Tạm thời hiển thị dữ liệu DEMO để bạn test UI...');
            print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
            print('');
          }

          return _getDemoData(input);
        }
      } else {
        print('❌ Places API HTTP error: ${response.statusCode}');
        return _getDemoData(input);
      }
    } catch (e) {
      print('❌ Error searching places: $e');
      return _getDemoData(input);
    }
    */
  }

  /// Demo data để test UI khi Places API chưa sẵn sàng
  List<PlacePrediction> _getDemoData(String input) {
    print('📦 Using DEMO data for testing (Places API disabled)');
    print('💡 Tip: Sẽ tích hợp Places API thật sau khi backend ready');

    // Danh sách địa điểm mẫu phong phú - Hà Nội
    final allPlaces = [
      // Trường học
      PlacePrediction(
        placeId: 'demo_1',
        description: 'Đại học Bách Khoa Hà Nội, Đại Cồ Việt, Hai Bà Trưng, Hà Nội',
        mainText: 'Đại học Bách Khoa Hà Nội',
        secondaryText: 'Đại Cồ Việt, Hai Bà Trưng',
      ),
      PlacePrediction(
        placeId: 'demo_2',
        description: 'Đại học Quốc gia Hà Nội, Xuân Thủy, Cầu Giấy, Hà Nội',
        mainText: 'Đại học Quốc gia Hà Nội',
        secondaryText: 'Xuân Thủy, Cầu Giấy',
      ),
      PlacePrediction(
        placeId: 'demo_3',
        description: 'Đại học Kinh tế Quốc dân, Giải Phóng, Hai Bà Trưng, Hà Nội',
        mainText: 'Đại học Kinh tế Quốc dân',
        secondaryText: 'Giải Phóng, Hai Bà Trưng',
      ),

      // Bệnh viện
      PlacePrediction(
        placeId: 'demo_4',
        description: 'Bệnh viện Bạch Mai, Giải Phóng, Đống Đa, Hà Nội',
        mainText: 'Bệnh viện Bạch Mai',
        secondaryText: 'Giải Phóng, Đống Đa',
      ),
      PlacePrediction(
        placeId: 'demo_5',
        description: 'Bệnh viện Nhi Trung ương, La Thành, Đống Đa, Hà Nội',
        mainText: 'Bệnh viện Nhi Trung ương',
        secondaryText: 'La Thành, Đống Đa',
      ),

      // Chợ
      PlacePrediction(
        placeId: 'demo_6',
        description: 'Chợ Đồng Xuân, Đồng Xuân, Hoàn Kiếm, Hà Nội',
        mainText: 'Chợ Đồng Xuân',
        secondaryText: 'Đồng Xuân, Hoàn Kiếm',
      ),
      PlacePrediction(
        placeId: 'demo_7',
        description: 'Chợ Hôm, Phố Huế, Hai Bà Trưng, Hà Nội',
        mainText: 'Chợ Hôm',
        secondaryText: 'Phố Huế, Hai Bà Trưng',
      ),

      // Công viên
      PlacePrediction(
        placeId: 'demo_8',
        description: 'Công viên Thống Nhất, Lê Duẩn, Đống Đa, Hà Nội',
        mainText: 'Công viên Thống Nhất',
        secondaryText: 'Lê Duẩn, Đống Đa',
      ),
      PlacePrediction(
        placeId: 'demo_9',
        description: 'Công viên Thủ Lệ, Buổi, Ba Đình, Hà Nội',
        mainText: 'Công viên Thủ Lệ',
        secondaryText: 'Buổi, Ba Đình',
      ),

      // Landmark
      PlacePrediction(
        placeId: 'demo_10',
        description: 'Keangnam Landmark 72, Phạm Hùng, Từ Liêm, Hà Nội',
        mainText: 'Keangnam Landmark 72',
        secondaryText: 'Phạm Hùng, Từ Liêm',
      ),
      PlacePrediction(
        placeId: 'demo_11',
        description: 'Lotte Center Hanoi, Liễu Giai, Ba Đình, Hà Nội',
        mainText: 'Lotte Center Hanoi',
        secondaryText: 'Liễu Giai, Ba Đình',
      ),

      // Di tích
      PlacePrediction(
        placeId: 'demo_12',
        description: 'Hồ Hoàn Kiếm, Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội',
        mainText: 'Hồ Hoàn Kiếm',
        secondaryText: 'Đinh Tiên Hoàng, Hoàn Kiếm',
      ),
      PlacePrediction(
        placeId: 'demo_13',
        description: 'Văn Miếu Quốc Tử Giám, Quốc Tử Giám, Đống Đa, Hà Nội',
        mainText: 'Văn Miếu Quốc Tử Giám',
        secondaryText: 'Quốc Tử Giám, Đống Đa',
      ),

      // Quán café
      PlacePrediction(
        placeId: 'demo_14',
        description: 'The Coffee House Hoàn Kiếm, Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội',
        mainText: 'The Coffee House Hoàn Kiếm',
        secondaryText: 'Đinh Tiên Hoàng, Hoàn Kiếm',
      ),
      PlacePrediction(
        placeId: 'demo_15',
        description: 'Highlands Coffee Tràng Tiền, Tràng Tiền, Hoàn Kiếm, Hà Nội',
        mainText: 'Highlands Coffee Tràng Tiền',
        secondaryText: 'Tràng Tiền, Hoàn Kiếm',
      ),

      // Nhà hàng
      PlacePrediction(
        placeId: 'demo_16',
        description: 'Phở Thìn Lò Đúc, Lò Đúc, Hai Bà Trưng, Hà Nội',
        mainText: 'Phở Thìn Lò Đúc',
        secondaryText: 'Lô Đúc, Hai Bà Trưng',
      ),
      PlacePrediction(
        placeId: 'demo_17',
        description: 'Bún Chả Hương Liên, Lê Văn Hưu, Hai Bà Trưng, Hà Nội',
        mainText: 'Bún Chả Hương Liên',
        secondaryText: 'Lê Văn Hưu, Hai Bà Trưng',
      ),

      // Siêu thị
      PlacePrediction(
        placeId: 'demo_18',
        description: 'Big C Thăng Long, Đại lộ Thăng Long, Đông Anh, Hà Nội',
        mainText: 'Big C Thăng Long',
        secondaryText: 'Đại lộ Thăng Long, Đông Anh',
      ),
      PlacePrediction(
        placeId: 'demo_19',
        description: 'Aeon Mall Long Biên, Cổ Linh, Long Biên, Hà Nội',
        mainText: 'Aeon Mall Long Biên',
        secondaryText: 'Cổ Linh, Long Biên',
      ),

      // Trung tâm thương mại
      PlacePrediction(
        placeId: 'demo_20',
        description: 'Vincom Center Bà Triệu, Bà Triệu, Hai Bà Trưng, Hà Nội',
        mainText: 'Vincom Center Bà Triệu',
        secondaryText: 'Bà Triệu, Hai Bà Trưng',
      ),
      PlacePrediction(
        placeId: 'demo_21',
        description: 'Trang Tien Plaza, Tràng Tiền, Hoàn Kiếm, Hà Nội',
        mainText: 'Trang Tien Plaza',
        secondaryText: 'Tràng Tiền, Hoàn Kiếm',
      ),

      // Sân bay
      PlacePrediction(
        placeId: 'demo_22',
        description: 'Sân bay Nội Bài, Phú Minh, Sóc Sơn, Hà Nội',
        mainText: 'Sân bay Nội Bài',
        secondaryText: 'Phú Minh, Sóc Sơn',
      ),

      // Bến xe
      PlacePrediction(
        placeId: 'demo_23',
        description: 'Bến xe Mỹ Đình, Phạm Hùng, Nam Từ Liêm, Hà Nội',
        mainText: 'Bến xe Mỹ Đình',
        secondaryText: 'Phạm Hùng, Nam Từ Liêm',
      ),
      PlacePrediction(
        placeId: 'demo_24',
        description: 'Bến xe Giáp Bát, Giải Phóng, Hoàng Mai, Hà Nội',
        mainText: 'Bến xe Giáp Bát',
        secondaryText: 'Giải Phóng, Hoàng Mai',
      ),

      // Khách sạn
      PlacePrediction(
        placeId: 'demo_25',
        description: 'Khách sạn Sofitel Legend Metropole, Ngô Quyền, Hoàn Kiếm, Hà Nội',
        mainText: 'Sofitel Legend Metropole',
        secondaryText: 'Ngô Quyền, Hoàn Kiếm',
      ),
    ];

    // Filter thông minh theo input
    if (input.isEmpty) {
      // Nếu chưa gõ gì, hiện top 10 địa điểm phổ biến
      return allPlaces.take(10).toList();
    }

    final search = input.toLowerCase().trim();

    // Tìm kiếm theo từ khóa
    final filtered = allPlaces.where((place) {
      final description = place.description.toLowerCase();
      final mainText = place.mainText.toLowerCase();
      final secondaryText = place.secondaryText.toLowerCase();

      // Tìm chính xác
      if (description.contains(search) ||
          mainText.contains(search) ||
          secondaryText.contains(search)) {
        return true;
      }

      // Tìm từng từ (cho search nhiều từ)
      final words = search.split(' ');
      return words.every((word) =>
        description.contains(word) ||
        mainText.contains(word) ||
        secondaryText.contains(word)
      );
    }).toList();

    // Nếu tìm thấy, trả về kết quả
    if (filtered.isNotEmpty) {
      print('🔍 Found ${filtered.length} demo places matching "$input"');
      return filtered;
    }

    // Nếu không tìm thấy, hiện top 5 địa điểm phổ biến
    print('⚠️ No demo places found for "$input", showing top 5 popular places');
    return allPlaces.take(5).toList();
  }

  /// Lấy chi tiết địa điểm (coordinates) từ place_id
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;

    // Handle demo data
    if (placeId.startsWith('demo_')) {
      print('📦 Using demo coordinates for: $placeId');
      return _getDemoPlaceDetails(placeId);
    }

    final encoded = Uri.encodeQueryComponent(placeId);
    final url = Uri.parse(
      '$baseUrl/details/json?place_id=$encoded&key=$apiKey&language=vi',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data);
        } else {
          print('Place details API returned status: ${data['status']} with error_message: ${data['error_message']}');
        }
      } else {
        print('Place details HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting place details: $e');
    }

    return null;
  }

  /// Demo coordinates cho các địa điểm demo - Hà Nội
  PlaceDetails? _getDemoPlaceDetails(String placeId) {
    final demoCoordinates = {
      // Trường học
      'demo_1': PlaceDetails(
        latitude: 21.004819,
        longitude: 105.843466,
        formattedAddress: 'Đại học Bách Khoa Hà Nội, Đại Cồ Việt, Hai Bà Trưng, Hà Nội',
      ),
      'demo_2': PlaceDetails(
        latitude: 21.037531,
        longitude: 105.782486,
        formattedAddress: 'Đại học Quốc gia Hà Nội, Xuân Thủy, Cầu Giấy, Hà Nội',
      ),
      'demo_3': PlaceDetails(
        latitude: 20.997837,
        longitude: 105.847130,
        formattedAddress: 'Đại học Kinh tế Quốc dân, Giải Phóng, Hai Bà Trưng, Hà Nội',
      ),

      // Bệnh viện
      'demo_4': PlaceDetails(
        latitude: 20.999714,
        longitude: 105.843117,
        formattedAddress: 'Bệnh viện Bạch Mai, Giải Phóng, Đống Đa, Hà Nội',
      ),
      'demo_5': PlaceDetails(
        latitude: 21.017861,
        longitude: 105.822350,
        formattedAddress: 'Bệnh viện Nhi Trung ương, La Thành, Đống Đa, Hà Nội',
      ),

      // Chợ
      'demo_6': PlaceDetails(
        latitude: 21.034746,
        longitude: 105.850220,
        formattedAddress: 'Chợ Đồng Xuân, Đồng Xuân, Hoàn Kiếm, Hà Nội',
      ),
      'demo_7': PlaceDetails(
        latitude: 21.013699,
        longitude: 105.844537,
        formattedAddress: 'Chợ Hôm, Phố Huế, Hai Bà Trưng, Hà Nội',
      ),

      // Công viên
      'demo_8': PlaceDetails(
        latitude: 21.013133,
        longitude: 105.834778,
        formattedAddress: 'Công viên Thống Nhất, Lê Duẩn, Đống Đa, Hà Nội',
      ),
      'demo_9': PlaceDetails(
        latitude: 21.040527,
        longitude: 105.823853,
        formattedAddress: 'Công viên Thủ Lệ, Buổi, Ba Đình, Hà Nội',
      ),

      // Landmark
      'demo_10': PlaceDetails(
        latitude: 21.018261,
        longitude: 105.783637,
        formattedAddress: 'Keangnam Landmark 72, Phạm Hùng, Từ Liêm, Hà Nội',
      ),
      'demo_11': PlaceDetails(
        latitude: 21.022381,
        longitude: 105.816284,
        formattedAddress: 'Lotte Center Hanoi, Liễu Giai, Ba Đình, Hà Nội',
      ),

      // Di tích
      'demo_12': PlaceDetails(
        latitude: 21.028952,
        longitude: 105.852245,
        formattedAddress: 'Hồ Hoàn Kiếm, Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội',
      ),
      'demo_13': PlaceDetails(
        latitude: 21.027764,
        longitude: 105.835394,
        formattedAddress: 'Văn Miếu Quốc Tử Giám, Quốc Tử Giám, Đống Đa, Hà Nội',
      ),

      // Quán café
      'demo_14': PlaceDetails(
        latitude: 21.027763,
        longitude: 105.851839,
        formattedAddress: 'The Coffee House Hoàn Kiếm, Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội',
      ),
      'demo_15': PlaceDetails(
        latitude: 21.024163,
        longitude: 105.853729,
        formattedAddress: 'Highlands Coffee Tràng Tiền, Tràng Tiền, Hoàn Kiếm, Hà Nội',
      ),

      // Nhà hàng
      'demo_16': PlaceDetails(
        latitude: 21.011763,
        longitude: 105.844425,
        formattedAddress: 'Phở Thìn Lò Đúc, Lò Đúc, Hai Bà Trưng, Hà Nội',
      ),
      'demo_17': PlaceDetails(
        latitude: 21.017293,
        longitude: 105.845371,
        formattedAddress: 'Bún Chả Hương Liên, Lê Văn Hưu, Hai Bà Trưng, Hà Nội',
      ),

      // Siêu thị
      'demo_18': PlaceDetails(
        latitude: 21.053762,
        longitude: 105.764421,
        formattedAddress: 'Big C Thăng Long, Đại lộ Thăng Long, Đông Anh, Hà Nội',
      ),
      'demo_19': PlaceDetails(
        latitude: 21.027500,
        longitude: 105.886111,
        formattedAddress: 'Aeon Mall Long Biên, Cổ Linh, Long Biên, Hà Nội',
      ),

      // Trung tâm thương mại
      'demo_20': PlaceDetails(
        latitude: 21.013936,
        longitude: 105.847404,
        formattedAddress: 'Vincom Center Bà Triệu, Bà Triệu, Hai Bà Trưng, Hà Nội',
      ),
      'demo_21': PlaceDetails(
        latitude: 21.024556,
        longitude: 105.853699,
        formattedAddress: 'Trang Tien Plaza, Tràng Tiền, Hoàn Kiếm, Hà Nội',
      ),

      // Sân bay
      'demo_22': PlaceDetails(
        latitude: 21.221192,
        longitude: 105.807178,
        formattedAddress: 'Sân bay Nội Bài, Phú Minh, Sóc Sơn, Hà Nội',
      ),

      // Bến xe
      'demo_23': PlaceDetails(
        latitude: 21.013637,
        longitude: 105.771614,
        formattedAddress: 'Bến xe Mỹ Đình, Phạm Hùng, Nam Từ Liêm, Hà Nội',
      ),
      'demo_24': PlaceDetails(
        latitude: 20.981491,
        longitude: 105.840752,
        formattedAddress: 'Bến xe Giáp Bát, Giải Phóng, Hoàng Mai, Hà Nội',
      ),

      // Khách sạn
      'demo_25': PlaceDetails(
        latitude: 21.027149,
        longitude: 105.852142,
        formattedAddress: 'Khách sạn Sofitel Legend Metropole, Ngô Quyền, Hoàn Kiếm, Hà Nội',
      ),
    };

    return demoCoordinates[placeId];
  }
}
