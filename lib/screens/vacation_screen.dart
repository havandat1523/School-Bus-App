import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VacationScreen extends StatefulWidget {
  final String rfidCode;

  const VacationScreen({super.key, required this.rfidCode});

  @override
  State<VacationScreen> createState() => _VacationScreenState();
}

class _VacationScreenState extends State<VacationScreen> {
  final ApiService _apiService = ApiService();
  final _nameController = TextEditingController();
  final _rfidController = TextEditingController();
  final _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _loading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _rfidController.text = widget.rfidCode;
    _dateController.text = _formatDate(DateTime.now());
    _selectedDate = DateTime.now();
    _fetchStudentName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rfidController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudentName() async {
    try {
      final res = await _apiService.fetchChildStatus(widget.rfidCode);
      setState(() {
        _nameController.text = res.fullName;
      });
    } catch (_) {
      // Ignored: Parent can type manually if fetch fails
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD35400),
              onPrimary: Colors.white,
              surface: Color(0xFF16162E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submitVacation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    final inputName = _nameController.text.trim();
    final inputRfid = _rfidController.text.trim();

    try {
      // 1. Fetch current status to check if name matches the RFID
      final res = await _apiService.fetchChildStatus(inputRfid);
      
      // Check if student name contains/matches input name
      final nameMatches = res.fullName.toLowerCase().contains(inputName.toLowerCase()) || 
                          inputName.toLowerCase().contains(res.fullName.toLowerCase());
      
      if (!nameMatches) {
        _showResultDialog(success: false);
        return;
      }

      // 2. Call vacation register
      final success = await _apiService.updateVacationStatus(inputRfid, true);
      _showResultDialog(success: success);
    } catch (e) {
      _showResultDialog(success: false);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showResultDialog({required bool success}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon wrapper matching PDF Page 3 designs
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: success ? const Color(0xFFE8F8F5) : const Color(0xFFFDEBD0),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: success ? const Color(0xFF2ecc71) : const Color(0xFFe74c3c),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    success ? Icons.check : Icons.close,
                    color: success ? const Color(0xFF2ecc71) : const Color(0xFFe74c3c),
                    size: 45,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  success ? 'Đăng ký nghỉ học\nthành công' : 'Đăng ký thất bại',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: success ? const Color(0xFF27AE60) : const Color(0xFFC0392B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  success
                      ? 'Lịch nghỉ phép của học sinh đã được cập nhật hệ thống và gửi đến tài xế thành công.'
                      : 'Vui lòng kiểm tra lại họ tên học sinh hoặc mã số thẻ RFID của học sinh.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: success ? const Color(0xFF27AE60) : const Color(0xFFC0392B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1B),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ĐĂNG KÝ NGHỈ HỌC HÔM NAY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Hệ thống sẽ thông báo tự động cho xe đưa đón học sinh để bỏ qua điểm đón này.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const Divider(color: Color(0xFF2E2E4F), height: 30),
                const SizedBox(height: 10),

                // Form background container styled like Page 3
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16162E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2E2E4F)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nhập tên học sinh:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Họ tên đầy đủ của học sinh...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          fillColor: const Color(0xFF7A1E00).withOpacity(0.2),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF8B2500)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2E2E4F)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD35400)),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng nhập họ tên học sinh';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      const Text(
                        'Mã thẻ học sinh:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _rfidController,
                        style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          hintText: 'RFID Card UID...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          fillColor: const Color(0xFF7A1E00).withOpacity(0.2),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF8B2500)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2E2E4F)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD35400)),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng nhập mã thẻ RFID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      const Text(
                        'Chọn ngày nghỉ:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFD35400)),
                          fillColor: const Color(0xFF7A1E00).withOpacity(0.2),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF8B2500)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2E2E4F)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD35400)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Confirmation button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B2500),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD35400), width: 1.5),
                          ),
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submitVacation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Xác Nhận',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
