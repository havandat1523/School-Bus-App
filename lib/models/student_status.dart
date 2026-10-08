class StudentStatus {
  final int studentId;
  final String fullName;
  final String status;
  final int currentSeat;
  final bool isOnBus;
  final String statusDescription;
  final double busLatitude;
  final double busLongitude;

  StudentStatus({
    required this.studentId,
    required this.fullName,
    required this.status,
    required this.currentSeat,
    required this.isOnBus,
    required this.statusDescription,
    required this.busLatitude,
    required this.busLongitude,
  });

  factory StudentStatus.fromJson(Map<String, dynamic> json) {
    return StudentStatus(
      studentId: json['student_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      status: json['status'] ?? 'active',
      currentSeat: json['current_seat'] ?? 0,
      isOnBus: json['is_on_bus'] ?? false,
      statusDescription: json['status_description'] ?? 'Chưa xác định',
      busLatitude: (json['bus_latitude'] as num?)?.toDouble() ?? 0.0,
      busLongitude: (json['bus_longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
