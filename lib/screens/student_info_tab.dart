import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class StudentInfoTab extends StatefulWidget {
  final String rfidCode;
  const StudentInfoTab({super.key, required this.rfidCode});

  @override
  State<StudentInfoTab> createState() => _StudentInfoTabState();
}

class _StudentInfoTabState extends State<StudentInfoTab> {
  final ApiService _apiService = ApiService();
  
  bool _loading = true;
  String _fullName = "---";
  String _studentClass = "---";
  String _rfidCode = "---";
  String _parentPhone = "---";
  String _address = "---";
  String _schoolName = "Học Viện Kỹ Thuật Mật Mã";

  @override
  void initState() {
    super.initState();
    _fetchStudentInfo();
  }

  Future<void> _fetchStudentInfo() async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/api/parent/child/${widget.rfidCode}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _fullName = data['full_name'] ?? "---";
          _studentClass = data['student_class'] ?? "---";
          _rfidCode = widget.rfidCode;
          _parentPhone = data['parent_phone'] ?? "---";
          _address = data['address'] ?? "---";
          _schoolName = data['school_name'] ?? "Học Viện Kỹ Thuật Mật Mã";
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1B),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD35400)))
          : RefreshIndicator(
              onRefresh: _fetchStudentInfo,
              color: const Color(0xFFD35400),
              backgroundColor: const Color(0xFF16162E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'THÔNG TIN HỌC SINH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Thông tin chi tiết lý lịch của học sinh đăng ký xe đưa đón.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const Divider(color: Color(0xFF2E2E4F), height: 30),
                    const SizedBox(height: 10),

                    // Avatar card
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFF16162E),
                            child: Icon(Icons.person, size: 60, color: Color(0xFFD35400)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _fullName,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lớp: $_studentClass',
                            style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Information details card styled premium
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16162E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2E2E4F)),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.school, 'Trường học', _schoolName),
                          const Divider(color: Color(0xFF2E2E4F), height: 24),
                          _buildInfoRow(Icons.badge, 'Mã thẻ RFID', _rfidCode),
                          const Divider(color: Color(0xFF2E2E4F), height: 24),
                          _buildInfoRow(Icons.phone, 'SĐT phụ huynh', _parentPhone),
                          const Divider(color: Color(0xFF2E2E4F), height: 24),
                          _buildInfoRow(Icons.home, 'Địa chỉ nhà', _address),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFD35400), size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
