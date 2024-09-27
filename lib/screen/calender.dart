import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selectedDay; // Use nullable type
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _tasks = {}; // Initialize the tasks map

  @override
  void initState() {
    super.initState();
    // Sample tasks
    _tasks = {
      DateTime.utc(2024, 9, 26): ["Task 1", "Task 2"],
      DateTime.utc(2024, 9, 27): ["Task 3"],
    };
    _selectedDay = _focusedDay; // Initialize with today's date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tasks Calendar")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update focused day
              });
              _showTasksForDate(selectedDay);
            },
            eventLoader: (day) => _tasks[day] ?? [],
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      width: 5,
                      height: 5,
                    ),
                  );
                }
                return SizedBox.shrink(); // Return an empty widget if no events
              },
            ),
          ),
          // Floating Action Button to add tasks
          FloatingActionButton(
            onPressed: () {
              // Implement task addition logic
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showTasksForDate(DateTime date) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final tasksForDate = _tasks[date] ?? [];
        return ListView.builder(
          itemCount: tasksForDate.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(tasksForDate[index]),
              // Optionally add more details (e.g., edit/delete)
            );
          },
        );
      },
    );
  }
}
