import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_status.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.137.1:8000';

  Future<StudentStatus> fetchChildStatus(String rfidCode) async {
    final url = Uri.parse('$baseUrl/api/parent/child/$rfidCode');
    late http.Response response;
    try {
      response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Hết thời gian chờ - máy chủ không phản hồi!'),
      );
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ: $e');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return StudentStatus.fromJson(data);
    } else {
      throw Exception('Mã thẻ RFID không tồn tại trên hệ thống! (HTTP ${response.statusCode})');
    }
  }

  Future<bool> updateVacationStatus(String rfidCode, bool isVacation) async {
    final url = Uri.parse('$baseUrl/api/parent/vacation');
    try {
      final response = await http.post(
        url,
        body: {
          'rfid_code': rfidCode,
          'status': isVacation ? 'vacation' : 'active',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'] == 1;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
