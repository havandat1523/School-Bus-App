import 'package:flutter/material.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleItems = [
      _ScheduleItem(
        time: "06:30 - 07:15",
        title: "Xe Đưa Đón Học Sinh",
        description: "Xe di chuyển đón học sinh tại điểm dừng và đưa đến trường.",
        icon: Icons.directions_bus,
        color: const Color(0xFFD35400),
      ),
      _ScheduleItem(
        time: "07:30 - 08:15",
        title: "Tiết 1: Học tập",
        description: "Học sinh bắt đầu bài giảng lớp học chính khóa buổi sáng.",
        icon: Icons.menu_book,
        color: const Color(0xFF2980B9),
      ),
      _ScheduleItem(
        time: "08:20 - 09:05",
        title: "Tiết 2: Học tập",
        description: "Tiết học chuyên đề khoa học công nghệ.",
        icon: Icons.science,
        color: const Color(0xFF27AE60),
      ),
      _ScheduleItem(
        time: "09:05 - 09:30",
        title: "Giờ Ra Chơi Giữa Giờ",
        description: "Hoạt động thể chất ngoài trời và uống sữa nhẹ.",
        icon: Icons.sports_soccer,
        color: const Color(0xFFF1C40F),
      ),
      _ScheduleItem(
        time: "09:30 - 10:15",
        title: "Tiết 3: Tiếng Anh",
        description: "Thực hành giao tiếp với giáo viên bản xứ.",
        icon: Icons.language,
        color: const Color(0xFF8E44AD),
      ),
      _ScheduleItem(
        time: "10:20 - 11:05",
        title: "Tiết 4: Mỹ Thuật / Nhạc",
        description: "Phát triển tư duy nghệ thuật, hội họa.",
        icon: Icons.palette,
        color: const Color(0xFFE74C3C),
      ),
      _ScheduleItem(
        time: "11:15 - 13:45",
        title: "Nghỉ Trưa & Ăn Bán Trú",
        description: "Ăn trưa dinh dưỡng tại căng tin và ngủ trưa tại phòng bán trú.",
        icon: Icons.hotel,
        color: const Color(0xFF16A085),
      ),
      _ScheduleItem(
        time: "14:00 - 16:00",
        title: "Hoạt Động Ngoại Khóa",
        description: "Học tập câu lạc bộ năng khiếu tự chọn (Võ thuật, Cờ vua, Vẽ).",
        icon: Icons.extension,
        color: const Color(0xFFE67E22),
      ),
      _ScheduleItem(
        time: "16:15 - 17:00",
        title: "Xe Đưa Đón Trở Về",
        description: "Xe đón học sinh tại trường trả về điểm hẹn của phụ huynh.",
        icon: Icons.home,
        color: const Color(0xFF2C3E50),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1B),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'THỜI KHÓA BIỂU HÀNG NGÀY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Lịch trình học tập và đưa đón của học sinh ngày hôm nay',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const Divider(color: Color(0xFF2E2E4F), height: 30),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scheduleItems.length,
              itemBuilder: (context, index) {
                final item = scheduleItems[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: item.color, width: 2),
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        if (index != scheduleItems.length - 1)
                          Container(
                            width: 2,
                            height: 60,
                            color: const Color(0xFF2E2E4F),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    
                    // Detail card
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16162E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2E2E4F)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.time,
                                  style: TextStyle(
                                    color: item.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleItem {
  final String time;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _ScheduleItem({
    required this.time,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
