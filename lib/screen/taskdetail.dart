import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner_daily/data/Dbhepler/db_helper.dart';
import 'package:planner_daily/data/model/task.dart';
import 'package:planner_daily/service/notification_service.dart'; // Import dịch vụ thông báo

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final bool _isSubmitting = false;

  late String _content;
  late String _timeRange;
  late String _location;
  late String _organizer;
  late String _notes;
  DateTime? _selectedDate;
  bool _isCompleted = false; // Theo dõi trạng thái hoàn thành
  DateTime? _reminderTime; // Thời gian nhắc nhở

  @override
  void initState() {
    super.initState();
    // Prepopulate fields with existing task data
    _content = widget.task.content;
    _timeRange = widget.task.timeRange;
    _location = widget.task.location;
    _organizer = widget.task.organizer;
    _notes = widget.task.notes;
    _selectedDate = DateFormat('EEEE, dd/MM/yyyy').parse(widget.task.day);
    _isCompleted =
        widget.task.isCompleted == 1; // Xác định trạng thái hoàn thành
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTask = Task(
        id: widget.task.id,
        day: DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate!),
        content: _content,
        timeRange: _timeRange,
        location: _location,
        organizer: _organizer,
        notes: _notes,
        isCompleted:
            _isCompleted ? 1 : 0, // Lưu trạng thái hoàn thành dưới dạng int
      );

      await DBHelper().updateTask(updatedTask);

      // Lập lịch thông báo nếu thời gian nhắc nhở đã được thiết lập
      if (_reminderTime != null) {
        await NotificationService.scheduleNotification(
          id: updatedTask.id!,
          title: 'Nhắc nhở nhiệm vụ',
          body: 'Thời gian để hoàn thành nhiệm vụ: $_content',
          scheduledTime: _reminderTime!,
        );
      }

      Navigator.pop(context, updatedTask);
    }
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
        backgroundColor: const Color(0xFF57015A),
        title: const Text('Chi tiết công việc',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            color: Colors.white,
            onPressed: _isSubmitting ? null : _updateTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Date Picker
              ListTile(
                title: Text(
                    _selectedDate == null
                        ? 'Hãy chọn ngày'
                        : DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate!),
                    style: theme.textTheme.headlineMedium),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              // Task Content
              TextFormField(
                initialValue: _content,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập tiêu đề công việc' : null,
                onSaved: (value) => _content = value!,
              ),
              const SizedBox(height: 16),

              // Time Range
              TextFormField(
                initialValue: _timeRange,
                decoration: const InputDecoration(
                    labelText: 'Thời gian (e.g. 8:00 -> 11:00)'),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập thời gian' : null,
                onSaved: (value) => _timeRange = value!,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'Vị trí'),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập vị trí' : null,
                onSaved: (value) => _location = value!,
              ),
              const SizedBox(height: 16),

              // Organizer
              TextFormField(
                initialValue: _organizer,
                decoration: const InputDecoration(labelText: 'Chủ trì'),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập người chủ trì' : null,
                onSaved: (value) => _organizer = value!,
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
                onSaved: (value) => _notes = value!,
              ),
              const SizedBox(height: 16),

              // Status Switch
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

              // Reminder Time Picker
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

              // Update Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _updateTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF57015A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Sửa nhiệm vụ',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
