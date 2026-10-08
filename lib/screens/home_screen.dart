import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'vacation_screen.dart';
import 'schedule_tab.dart';
import 'contact_tab.dart';
import 'student_info_tab.dart';

class HomeScreen extends StatefulWidget {
  final String rfidCode;
  const HomeScreen({super.key, required this.rfidCode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Default to Tab 3 (index 2) - Home Dashboard

  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const ScheduleTab(),
      VacationScreen(rfidCode: widget.rfidCode),
      DashboardScreen(rfidCode: widget.rfidCode),
      ContactTab(rfidCode: widget.rfidCode),
      StudentInfoTab(rfidCode: widget.rfidCode),
    ];
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rfid_code');
    await prefs.remove('parent_phone');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1B),
      appBar: AppBar(
        title: const Text(
          'ACTVN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFD35400), // Orange header background
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF8B2500), // Dark red-brown matching PDF drawer design
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF7A1E00),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_bus, size: 50, color: Colors.white),
                      const SizedBox(height: 10),
                      const Text(
                        'SchoolBus Portal',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Mã thẻ: ${widget.rfidCode}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications, color: Colors.white),
                title: const Text('THÔNG BÁO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureDialog('THÔNG BÁO');
                },
              ),
              const Divider(color: Colors.white30),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('CÀI ĐẶT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Thông tin xe • Bản đồ • Ngôn ngữ', style: TextStyle(color: Colors.white70, fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureDialog('CÀI ĐẶT');
                },
              ),
              const Divider(color: Colors.white30),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.white),
                title: const Text('LỊCH SỬ CHUYẾN ĐI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureDialog('LỊCH SỬ CHUYẾN ĐI');
                },
              ),
              const Divider(color: Colors.white30),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.white),
                title: const Text('HỖ TRỢ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureDialog('HỖ TRỢ');
                },
              ),
              const Spacer(),
              const Divider(color: Colors.white30),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.white),
                title: const Text('ĐĂNG XUẤT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _handleLogout();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF16162E), // Dark navigation bar
        selectedItemColor: const Color(0xFFD35400), // Orange for active icon
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Nghỉ học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Giám sát',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Liên lạc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Thông tin',
          ),
        ],
      ),
    );
  }

  void _showFeatureDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text('Tính năng $title đang được phát triển.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng', style: TextStyle(color: Color(0xFFD35400))),
          ),
        ],
      ),
    );
  }
}
