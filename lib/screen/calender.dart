import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner_daily/data/model/task.dart';
import 'package:planner_daily/data/Dbhepler/db_helper.dart';
import 'package:planner_daily/screen/list.dart';
import 'package:planner_daily/screen/taskdetail.dart';
import 'package:planner_daily/screen/updatetask.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final List<Task> tasks;

  CalendarScreen({required this.tasks});

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
          title: Text('Xóa nhiệm vụ'),
          content: Text('Bạn có chắc chắn muốn xóa nhiệm vụ này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Xóa'),
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
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: 1.0), // Fixed text scale factor
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF57015A),
          title: Text(
            'Lịch công việc',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
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
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF57015A), // Modern color
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  // Update text colors based on theme
                  weekendTextStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary, // Theme color for weekends
                    fontSize: 14,
                  ),
                  holidayTextStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary, // Theme color for holidays
                    fontSize: 14,
                  ),
                  defaultTextStyle: TextStyle(
                    color: Colors.black87, // Default text color
                    fontSize: 16, // Set fixed font size
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Color(0xFF57015A),
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Set fixed font size
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
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView.builder(
                    itemCount: selectedTasks.length,
                    itemBuilder: (context, index) {
                      final task = selectedTasks[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 5,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            task.content,
                            style: TextStyle(
                              fontSize: 16, // Fixed font size
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            task.timeRange,
                            style: TextStyle(fontSize: 14), // Fixed font size
                          ),
                          onTap: () => _navigateToDetail(task),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _navigateToUpdate(task),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskListScreen()),
            ).then((_) {
              setState(() {
                _events = _groupTasksByDate(widget.tasks);
              });
            });
          },
          child: Icon(Icons.add),
          backgroundColor: Color(0xFF57015A),
        ),
      ),
    );
  }
}
