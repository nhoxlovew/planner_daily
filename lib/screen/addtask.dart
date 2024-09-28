import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:planner_daily/data/Dbhepler/db_helper.dart'; // Your DBHelper
import 'package:planner_daily/data/model/task.dart'; // Your Task model
import 'package:planner_daily/service/notification_service.dart'; // Import notification service

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({super.key, this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  String? _content;
  String? _timeRange;
  String? _location;
  String? _organizer;
  String? _notes;
  DateTime? _selectedDate;
  bool _isCompleted = false; // Track completion status
  DateTime? _reminderTime; // Add reminder time

  final List<String> _organizers = ['Thanh Ngân', 'Hữu Nghĩa', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      // If editing an existing task, fill in the fields
      _content = widget.task!.content;
      _timeRange = widget.task!.timeRange;
      _location = widget.task!.location;
      _organizer = widget.task!.organizer;
      _notes = widget.task!.notes;
      _selectedDate = DateFormat('EEEE, dd/MM/yyyy').parse(widget.task!.day);
      _isCompleted =
          widget.task!.isCompleted == 1; // Determine completion status
    }
  }

  Future<void> _submitTask() async {
    if (_isSubmitting) {
      print('Task is already being submitted.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final task = Task(
        id: widget.task?.id, // Keep ID for update
        day: DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate!),
        content: _content!,
        timeRange: _timeRange!,
        location: _location!,
        organizer: _organizer!,
        notes: _notes ?? '',
        isCompleted: _isCompleted ? 1 : 0, // Store completion status as int
      );

      if (widget.task == null) {
        await DBHelper().createTask(task);
      } else {
        await DBHelper().updateTask(task);
      }

      // Schedule notification if reminder time is set
      if (_reminderTime != null) {
        await NotificationService.scheduleNotification(
          id: task.id!,
          title: 'Task Reminder',
          body: 'Time to complete the task: $_content',
          scheduledTime: _reminderTime!,
        );
      }

      // Only pop the screen if reminder time is NOT set
      if (_reminderTime == null) {
        Navigator.of(context)
            .pop(task); // Pop the screen and return task to the previous screen
      }
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent,
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final now = DateTime.now();
      _reminderTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Thêm nhiệm vụ' : 'Edit Task',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
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
                    value == null ? 'Vui lòng chọn người chủ trì' : null,
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
                child: Text(
                  widget.task == null ? 'Thêm nhiệm vụ' : 'Update Task',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields with consistent style
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
