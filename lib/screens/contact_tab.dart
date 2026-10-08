import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class ContactTab extends StatefulWidget {
  final String rfidCode;
  const ContactTab({super.key, required this.rfidCode});

  @override
  State<ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<ContactTab> {
  final ApiService _apiService = ApiService();
  
  bool _loading = true;
  String _phone = "Chưa xác định";
  String _email = "Chưa xác định";
  String _driverName = "Chưa xác định";

  @override
  void initState() {
    super.initState();
    _fetchContactDetails();
  }

  Future<void> _fetchContactDetails() async {
    try {
      final res = await _apiService.fetchChildStatus(widget.rfidCode);
      // Let's print response details or extract directly
      // Wait, we designed our extended JSON response to include:
      // "driver_phone", "driver_email", "driver_name"
      // Let's extract them from the JSON raw map or parse them by casting or extending the model.
      // Wait! Since StudentStatus has a factory formJson, let's check if we want to extend StudentStatus class or fetch from ApiService directly.
      // Fetching from ApiService directly is extremely easy:
      final url = Uri.parse('${ApiService.baseUrl}/api/parent/child/${widget.rfidCode}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _phone = data['driver_phone'] ?? "Chưa xác định";
          _email = data['driver_email'] ?? "Chưa xác định";
          _driverName = data['driver_name'] ?? "Chưa xác định";
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    if (urlString.contains("Chưa xác định")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể liên lạc: Tài xế chưa đăng nhập!'),
          backgroundColor: Color(0xFF8B2500),
        ),
      );
      return;
    }
    
    final Uri uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở ứng dụng liên kết: $e'),
            backgroundColor: const Color(0xFF8B2500),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1B),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD35400)))
          : RefreshIndicator(
              onRefresh: _fetchContactDetails,
              color: const Color(0xFFD35400),
              backgroundColor: const Color(0xFF16162E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LIÊN LẠC VỚI TÀI XẾ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Thông tin liên lạc của tài xế đang thực hiện đưa đón học sinh.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const Divider(color: Color(0xFF2E2E4F), height: 30),
                    const SizedBox(height: 10),

                    // Driver status card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: _phone != "Chưa xác định"
                            ? const Color(0xFF16A085).withOpacity(0.1)
                            : const Color(0xFFC0392B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _phone != "Chưa xác định"
                              ? const Color(0xFF16A085)
                              : const Color(0xFFC0392B),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _phone != "Chưa xác định" ? Icons.verified_user : Icons.error_outline,
                            color: _phone != "Chưa xác định" ? const Color(0xFF16A085) : const Color(0xFFC0392B),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _phone != "Chưa xác định" ? 'TÀI XẾ ĐÃ ĐĂNG NHẬP' : 'TÀI XẾ CHƯA ĐĂNG NHẬP',
                                  style: TextStyle(
                                    color: _phone != "Chưa xác định" ? const Color(0xFF16A085) : const Color(0xFFC0392B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _phone != "Chưa xác định"
                                      ? 'Họ tên: $_driverName'
                                      : 'Hệ thống chưa ghi nhận tài xế hoạt động đưa đón hôm nay.',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Call Option Row
                    _buildContactCard(
                      icon: Icons.phone_in_talk,
                      title: 'Gọi điện trực tiếp',
                      value: _phone,
                      onTap: () => _launchURL('tel:$_phone'),
                    ),

                    // SMS Option Row
                    _buildContactCard(
                      icon: Icons.sms,
                      title: 'Gửi tin nhắn SMS',
                      value: _phone,
                      onTap: () => _launchURL('sms:$_phone'),
                    ),

                    // Email Option Row
                    _buildContactCard(
                      icon: Icons.email,
                      title: 'Gửi thư Email',
                      value: _email,
                      onTap: () => _launchURL('mailto:$_email'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16162E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E2E4F)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF8B2500).withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF8B2500), width: 1.5),
          ),
          child: Icon(icon, color: const Color(0xFFD35400), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
        onTap: onTap,
      ),
    );
  }
}

