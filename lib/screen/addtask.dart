import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:planner_daily/data/Dbhepler/db_helper.dart'; // Your DBHelper
import 'package:planner_daily/data/model/task.dart'; // Your Task model

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  AddTaskScreen({this.task});

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

  // Sample data for dropdowns
  List<String> _organizers = ['Thanh Ngân', 'Hữu Nghĩa', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      // If editing an existing task, prepopulate fields
      _content = widget.task!.content;
      _timeRange = widget.task!.timeRange;
      _location = widget.task!.location;
      _organizer = widget.task!.organizer;
      _notes = widget.task!.notes;
      _selectedDate = DateFormat('EEEE, dd/MM/yyyy').parse(widget.task!.day);
    }
  }

  Future<void> _submitTask() async {
    if (_isSubmitting) {
      print('Task is already being submitted.'); // Ghi log khi đã gửi nhiệm vụ
      return;
    }

    _isSubmitting = true; // Đánh dấu là đang xử lý
    print('Submit task called'); // Ghi log

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final task = Task(
        id: widget.task?.id,
        day: DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate!),
        content: _content!,
        timeRange: _timeRange!,
        location: _location!,
        organizer: _organizer!,
        notes: _notes ?? '',
      );

      print('Submitting task: $task'); // Ghi log

      if (await _taskExists(task)) {
        print('Task already exists, not adding again.');
        _isSubmitting = false; // Đánh dấu kết thúc
        return;
      }

      if (widget.task == null) {
        await DBHelper().createTask(task);
        print('New task added: $task'); // Ghi log
      } else {
        await DBHelper().updateTask(task);
        print('Task updated: $task'); // Ghi log
      }

      Navigator.pop(context, task);
    }

    _isSubmitting = false; // Đánh dấu kết thúc
    print('Task submission complete'); // Ghi log
  }

  // Hàm kiểm tra xem nhiệm vụ có tồn tại không
  Future<bool> _taskExists(Task task) async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> result = await db.query(
      'tasks',
      where: 'content = ? AND day = ?',
      whereArgs: [task.content, task.day],
    );

    // Ghi log để kiểm tra kết quả truy vấn
    print(
        'Checking if task exists: content=${task.content}, day=${task.day}, result=${result.isNotEmpty}');

    return result.isNotEmpty; // Trả về true nếu nhiệm vụ đã tồn tại
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Date Picker
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Select a Date'
                    : DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 16),

              // Task Content
              TextFormField(
                initialValue: _content,
                decoration: InputDecoration(labelText: 'Task Content'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the task content' : null,
                onSaved: (value) => _content = value,
              ),
              SizedBox(height: 16),

              // Time Range
              TextFormField(
                initialValue: _timeRange,
                decoration: InputDecoration(
                    labelText: 'Time Range (e.g. 8:00 -> 11:00)'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the time range' : null,
                onSaved: (value) => _timeRange = value,
              ),
              SizedBox(height: 16),

              // Location
              TextFormField(
                initialValue: _location,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the location' : null,
                onSaved: (value) => _location = value,
              ),
              SizedBox(height: 16),

              // Organizer
              DropdownButtonFormField<String>(
                value: _organizer,
                items: _organizers.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Organizer'),
                validator: (value) =>
                    value == null ? 'Please select an organizer' : null,
                onChanged: (value) {
                  setState(() {
                    _organizer = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Notes
              TextFormField(
                initialValue: _notes,
                decoration: InputDecoration(labelText: 'Notes'),
                onSaved: (value) => _notes = value,
              ),
              SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : _submitTask, // Vô hiệu hóa khi đang xử lý
                child: Text(widget.task == null ? 'Add Task' : 'Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
