import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:planner_daily/data/Dbhepler/db_helper.dart'; // Your DBHelper
import 'package:planner_daily/data/model/task.dart'; // Your Task model
import 'package:planner_daily/service/notification_service.dart'; // Import notification service

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
  bool _isCompleted = false; // Track completion status
  DateTime? _reminderTime; // Add reminder time

  List<String> _organizers = ['Thanh Ngân', 'Hữu Nghĩa', 'Other'];

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

    // Set submitting state to true
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

      // Pop the screen and return task to the previous screen
      Navigator.of(context).pop(task); // Ensure to use Navigator.of(context)
    }

    // Reset submitting state
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
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Select a Date'
                    : DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _content,
                decoration: InputDecoration(labelText: 'Task Content'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the task content' : null,
                onSaved: (value) => _content = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _timeRange,
                decoration: InputDecoration(
                    labelText: 'Time Range (e.g. 8:00 -> 11:00)'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the time range' : null,
                onSaved: (value) => _timeRange = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _location,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the location' : null,
                onSaved: (value) => _location = value,
              ),
              SizedBox(height: 16),
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
              TextFormField(
                initialValue: _notes,
                decoration: InputDecoration(labelText: 'Notes'),
                onSaved: (value) => _notes = value,
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Completed'),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value; // Toggle completion status
                  });
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(_reminderTime == null
                    ? 'Set Reminder Time'
                    : DateFormat.jm().format(_reminderTime!)),
                trailing: Icon(Icons.alarm),
                onTap: _pickReminderTime,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null // Disable when submitting
                    : _submitTask,
                child: Text(widget.task == null ? 'Add Task' : 'Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
