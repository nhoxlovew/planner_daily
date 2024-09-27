import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để định dạng ngày tháng
import 'package:planner_daily/data/Dbhepler/db_helper.dart'; // DBHelper
import 'package:planner_daily/data/model/task.dart'; // Model Task

class UpdateTaskScreen extends StatefulWidget {
  final Task task;

  UpdateTaskScreen({required this.task});

  @override
  _UpdateTaskScreenState createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _content;
  late String _timeRange;
  late String _location;
  late String _organizer;
  late String _notes;
  late DateTime _selectedDate;

  // Sample data for dropdowns
  List<String> _organizers = ['Thanh Ngân', 'Hữu Nghĩa', 'Other'];

  @override
  void initState() {
    super.initState();
    _content = widget.task.content;
    _timeRange = widget.task.timeRange;
    _location = widget.task.location;
    _organizer = widget.task.organizer;
    _notes = widget.task.notes;
    _selectedDate = DateFormat('EEEE, dd/MM/yyyy').parse(widget.task.day);
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTask = Task(
        id: widget.task.id,
        day: DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate),
        content: _content,
        timeRange: _timeRange,
        location: _location,
        organizer: _organizer,
        notes: _notes,
      );

      await DBHelper().updateTask(updatedTask);
      Navigator.pop(context, updatedTask); // Trả về nhiệm vụ đã cập nhật
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
        title: Text('Update Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Date Picker
              ListTile(
                title:
                    Text(DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate)),
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
                onSaved: (value) => _content = value!,
              ),
              SizedBox(height: 16),

              // Time Range
              TextFormField(
                initialValue: _timeRange,
                decoration: InputDecoration(
                    labelText: 'Time Range (e.g. 8:00 -> 11:00)'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the time range' : null,
                onSaved: (value) => _timeRange = value!,
              ),
              SizedBox(height: 16),

              // Location
              TextFormField(
                initialValue: _location,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the location' : null,
                onSaved: (value) => _location = value!,
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
                onChanged: (value) {
                  setState(() {
                    _organizer = value!;
                  });
                },
              ),
              SizedBox(height: 16),

              // Notes
              TextFormField(
                initialValue: _notes,
                decoration: InputDecoration(labelText: 'Notes'),
                onSaved: (value) => _notes = value!,
              ),
              SizedBox(height: 16),

              // Update Button
              ElevatedButton(
                onPressed: _updateTask,
                child: Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
