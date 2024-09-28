import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner_daily/data/model/task.dart';
import 'package:planner_daily/data/Dbhepler/db_helper.dart';
import 'package:planner_daily/screen/addtask.dart';
import 'package:planner_daily/screen/taskdetail.dart';
import 'package:planner_daily/screen/updatetask.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final List<Task> tasks;

  const CalendarScreen({super.key, required this.tasks});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  Map<DateTime, List<Task>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _events = _groupTasksByDate(widget.tasks);
  }

  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    Map<DateTime, List<Task>> groupedTasks = {};
    for (var task in tasks) {
      try {
        DateTime date = DateFormat('dd/MM/yyyy').parse(task.day);
        groupedTasks.putIfAbsent(date, () => []).add(task);
      } catch (e) {
        print("Error parsing date: ${task.day}");
      }
    }
    return groupedTasks;
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _navigateToDetail(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }

  Future<void> _navigateToUpdate(Task task) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(task: task),
      ),
    );

    if (updatedTask != null) {
      setState(() {
        _events = _groupTasksByDate(widget.tasks);
      });
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await DBHelper().deleteTask(task.id!);
      setState(() {
        _events = _groupTasksByDate(widget.tasks);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTasks = _events[_selectedDate] ?? [];
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF57015A),
          title: const Text(
            'Lịch công việc',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _selectedDate,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                onDaySelected: (selectedDay, focusedDay) {
                  _onDateSelected(selectedDay);
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF57015A),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 14,
                  ),
                  holidayTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 14,
                  ),
                  defaultTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Color(0xFF57015A),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            if (selectedTasks.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView.builder(
                    itemCount: selectedTasks.length,
                    itemBuilder: (context, index) {
                      final task = selectedTasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        elevation: 5,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            task.content,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            task.timeRange,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => _navigateToDetail(task),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _navigateToUpdate(task),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTask(task),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to Add Task Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddTaskScreen()), // Assuming you have an AddTaskScreen
            ).then((newTask) {
              if (newTask != null) {
                setState(() {
                  widget.tasks.add(newTask); // Update tasks list
                  _events =
                      _groupTasksByDate(widget.tasks); // Re-group tasks by date
                });
              }
            });
          },
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF57015A),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
