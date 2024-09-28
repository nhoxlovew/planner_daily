import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để định dạng ngày
import 'package:planner_daily/data/Dbhepler/db_helper.dart'; // DBHelper của bạn
import 'package:planner_daily/data/model/task.dart'; // Model Task của bạn
import 'package:planner_daily/service/notification_service.dart'; // Import dịch vụ thông báo

class UpdateTaskScreen extends StatefulWidget {
  final Task task;

  const UpdateTaskScreen({super.key, required this.task});

  @override
  _UpdateTaskScreenState createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  String? _content;
  String? _timeRange;
  String? _location;
  String? _organizer;
  String? _notes;
  DateTime? _selectedDate;
  bool _isCompleted = false; // Theo dõi trạng thái hoàn thành
  DateTime? _reminderTime; // Thêm thời gian nhắc nhở

  final List<String> _organizers = ['Thanh Ngân', 'Hữu Nghĩa', 'Other'];

  @override
  void initState() {
    super.initState();
    // Nếu chỉnh sửa nhiệm vụ hiện có, hãy điền vào các trường
    _content = widget.task.content;
    _timeRange = widget.task.timeRange;
    _location = widget.task.location;
    _organizer = widget.task.organizer;
    _notes = widget.task.notes;
    _selectedDate = DateFormat('EEEE, dd/MM/yyyy').parse(widget.task.day);
    _isCompleted =
        widget.task.isCompleted == 1; // Xác định trạng thái hoàn thành
  }

  Future<void> _submitTask() async {
    if (_isSubmitting) {
      print('Nhiệm vụ đang được gửi đi.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTask = Task(
        id: widget.task.id, // Giữ ID để cập nhật
        day: DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate!),
        content: _content!,
        timeRange: _timeRange!,
        location: _location!,
        organizer: _organizer!,
        notes: _notes ?? '',
        isCompleted:
            _isCompleted ? 1 : 0, // Lưu trạng thái hoàn thành dưới dạng int
      );

      await DBHelper().updateTask(updatedTask); // Cập nhật nhiệm vụ

      // Lập lịch thông báo nếu thời gian nhắc nhở đã được thiết lập
      if (_reminderTime != null) {
        await NotificationService.scheduleNotification(
          id: updatedTask.id!,
          title: 'Nhắc nhở nhiệm vụ',
          body: 'Thời gian để hoàn thành nhiệm vụ: $_content',
          scheduledTime: _reminderTime!,
        );
      }

      Navigator.of(context).pop(
          updatedTask); // Quay lại màn hình trước và trả về nhiệm vụ đã cập nhật
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      _reminderTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Lấy theme hiện tại

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật nhiệm vụ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF57015A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Hãy chọn ngày --->'
                      : DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate!),
                  style: theme.textTheme.headlineMedium,
                ),
                trailing: Icon(Icons.calendar_today, color: theme.primaryColor),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                  'Tiêu đề',
                  _content,
                  'Vui lòng nhập tiêu đề công việc',
                  (value) => _content = value),
              const SizedBox(height: 16),
              _buildTextField('Thời gian (e.g. 8:00 -> 11:00)', _timeRange,
                  'Vui lòng nhập thời gian', (value) => _timeRange = value),
              const SizedBox(height: 16),
              _buildTextField('Vị trí', _location, 'Vui lòng nhập vị trí',
                  (value) => _location = value),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _organizer,
                items: _organizers.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: theme.textTheme.bodyLarge),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Chủ trì',
                  labelStyle: theme.textTheme.bodyLarge,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Vui lòng nhập người chủ trì' : null,
                onChanged: (value) {
                  setState(() {
                    _organizer = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                  'Ghi chú', _notes, null, (value) => _notes = value, false),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text('Trạng thái hoàn thành',
                    style: theme.textTheme.bodyLarge),
                value: _isCompleted,
                activeColor: theme.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _reminderTime == null
                      ? 'Đặt thời gian nhắc'
                      : DateFormat.jm().format(_reminderTime!),
                  style: theme.textTheme.bodyLarge,
                ),
                trailing: Icon(Icons.alarm, color: theme.primaryColor),
                onTap: _pickReminderTime,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF57015A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cập nhật nhiệm vụ',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Phương thức trợ giúp để xây dựng các trường văn bản với kiểu dáng đồng nhất
  Widget _buildTextField(String label, String? initialValue,
      String? validatorMessage, Function(String?) onSaved,
      [bool isRequired = true]) {
    final theme = Theme.of(context);
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyLarge,
        border: const OutlineInputBorder(),
      ),
      validator: isRequired
          ? (value) => value!.isEmpty ? validatorMessage : null
          : null,
      onSaved: onSaved,
    );
  }
}
