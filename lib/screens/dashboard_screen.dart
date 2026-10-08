import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  final String rfidCode;
  const DashboardScreen({super.key, required this.rfidCode});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  Timer? _timer;
  
  bool _loading = true;
  String _error = "";
  
  // Student properties
  String _studentName = "---";
  String _studentClass = "---";
  String _studentStatus = "---";
  bool _isOnBus = false;
  double _busLat = 21.0021;
  double _busLon = 105.8462;
  
  // Vehicle / Crew properties
  String _vehiclePlate = "29A-123.45";
  String _vehicleStatus = "Xe đang dừng";
  String _studentsCount = "không xác định";
  String _temp = "không xác định";
  String _humi = "không xác định";
  String _driverName = "Chưa xác định";
  String _driverStatus = "logout";
  String _assistantName = "Chưa xác định";
  String _assistantStatus = "logout";

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    // Poll telemetry data every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchDashboardData(quiet: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDashboardData({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _loading = true;
        _error = "";
      });
    }

    try {
      final url = Uri.parse('${ApiService.baseUrl}/api/parent/child/${widget.rfidCode}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _studentName = data['full_name'] ?? "---";
            _studentClass = data['student_class'] ?? "---";
            _studentStatus = data['status_description'] ?? "---";
            _isOnBus = data['is_on_bus'] ?? false;
            _busLat = (data['bus_latitude'] as num?)?.toDouble() ?? 21.0021;
            _busLon = (data['bus_longitude'] as num?)?.toDouble() ?? 105.8462;
            
            _vehiclePlate = data['vehicle_plate'] ?? "29A-123.45";
            _vehicleStatus = data['vehicle_status'] ?? "Xe đang dừng";
            _studentsCount = data['students_count'] ?? "không xác định";
            _temp = data['temperature'] ?? "không xác định";
            _humi = data['humidity'] ?? "không xác định";
            _driverName = data['driver_name'] ?? "Chưa xác định";
            _driverStatus = data['driver_status'] ?? "logout";
            _assistantName = data['assistant_name'] ?? "Chưa xác định";
            _assistantStatus = data['assistant_status'] ?? "logout";
            
            _loading = false;
          });
        }
      } else {
        throw Exception('Mã phản hồi từ máy chủ: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted && !quiet) {
        setState(() {
          _error = "Lỗi tải dữ liệu giám sát: $e";
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1B),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD35400)),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1B),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                const SizedBox(height: 16),
                Text(
                  _error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _fetchDashboardData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD35400),
                  ),
                  child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1B),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Student Info Card (Avatar left, info right)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B2500), // Dark red-brown card background
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_studentName – Lớp $_studentClass',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Học Viện Kỹ Thuật Mật Mã',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Trạng thái: $_studentStatus',
                            style: TextStyle(
                              color: _isOnBus ? Colors.greenAccent : const Color(0xFFFFBF00),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Map Container (simulated maps visual)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF16162E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2E2E4F)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final centerX = constraints.maxWidth / 2;
                      final centerY = constraints.maxHeight / 2;
                      
                      // Scale factor to map lat/lon difference to visual pixels relative to ACTVN
                      double scaleX = 250000.0;
                      double scaleY = 250000.0;
                      
                      double dx = (_busLon - 105.8462) * scaleX;
                      double dy = -(_busLat - 21.0021) * scaleY; // Invert screen Y
                      
                      // Keep markers inside map container padding bounds
                      double busX = (centerX + dx).clamp(25.0, constraints.maxWidth - 55.0);
                      double busY = (centerY + dy).clamp(25.0, constraints.maxHeight - 55.0);

                      return Stack(
                        children: [
                          // Grid visual backing representing map
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _MapGridPainter(),
                            ),
                          ),

                          // Coordinates HUD Overlay
                          Positioned(
                            top: 15,
                            left: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'GNSS: ${_busLat.toStringAsFixed(6)}, ${_busLon.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),

                          // School Marker (ACTVN) at the center
                          Positioned(
                            left: centerX - 25,
                            top: centerY - 25,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.school, color: Colors.cyan, size: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  color: Colors.black54,
                                  child: const Text('ACTVN', style: TextStyle(color: Colors.white, fontSize: 8)),
                                )
                              ],
                            ),
                          ),

                          // Car Icon marker moving relative to center
                          Positioned(
                            left: busX - 20,
                            top: busY - 20,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF7F24),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF7F24).withOpacity(0.5),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.directions_bus,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _vehiclePlate,
                                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Vehicle Info Card (Bus telemetry and Crew)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B2500), // Dark red-brown card background
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bus Status Header
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _vehicleStatus.contains("di chuyển") ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                            boxShadow: [
                              if (_vehicleStatus.contains("di chuyển"))
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                )
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Trạng thái: $_vehicleStatus',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Onboard info
                    Text(
                      'Số học sinh trên xe: $_studentsCount   Nhiệt độ $_temp°C độ ẩm $_humi%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    
                    const Divider(color: Colors.white30, height: 24),

                    // Driver info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tài xế: $_driverName${_driverStatus == "Đang trên xe" ? " (Đang trên xe)" : ""}',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Plate number
                    Text(
                      'Biển số xe: $_vehiclePlate',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),

                    // Assistant info
                    Text(
                      'Phụ xe: $_assistantName${_assistantStatus == "Đang trên xe" ? " (Đang trên xe)" : ""}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
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
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E2E4F).withOpacity(0.4)
      ..strokeWidth = 1.0;

    // Draw grid lines
    const int step = 30;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw a simulated path line for the bus route
    final pathPaint = Paint()
      ..color = const Color(0xFFFF7F24).withOpacity(0.5)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.2,
        size.width,
        size.height * 0.5,
      );

    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
