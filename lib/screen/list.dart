import 'package:flutter/material.dart';
import 'package:planner_daily/data/Dbhepler/db_helper.dart';
import 'package:planner_daily/data/model/task.dart';
import 'package:planner_daily/screen/taskdetail.dart';
import 'package:planner_daily/screen/updatetask.dart';
import 'package:planner_daily/screen/addtask.dart';
import 'package:planner_daily/screen/calender.dart'; // Import CalendarScreen
import 'package:provider/provider.dart'; // Import Provider
import 'package:planner_daily/theme/theme_provider.dart'; // Import your ThemeProvider

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DBHelper().getTasks();
    setState(() {
      _tasks = tasks;
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
      _loadTasks(); // Load tasks again after updating
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
      _loadTasks(); // Reload tasks after deleting
    }
  }

  Future<void> _navigateToCalendar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarScreen(
          tasks: _tasks, // Pass the tasks to the CalendarScreen
        ),
      ),
    );
  }

  Future<void> _navigateToAddTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen()),
    );

    if (newTask != null) {
      setState(() {
        _tasks.add(newTask); // Add the new task to the list
      });
    } else {
      _loadTasks(); // Reload tasks if no new task was added
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        Provider.of<ThemeProvider>(context); // Get the theme provider

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF57015A),
        title: Text('Danh sách công việc',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            color: Colors.white,
            onPressed: _navigateToCalendar, // Navigate to CalendarScreen
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: themeProvider.isDarkMode
                ? Colors.grey[850]
                : Colors.white, // Card background color
            child: ListTile(
              title: Text(
                task.content,
                style: TextStyle(color: themeProvider.textColor), // Text color
              ),
              subtitle: Text(
                task.day,
                style:
                    TextStyle(color: themeProvider.textColor), // Subtitle color
              ),
              onTap: () => _navigateToDetail(task),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _navigateToUpdate(task),
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTask(task),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddTask, // Navigate to AddTaskScreen
          child: Icon(Icons.add),
          hoverColor: Colors.white,
          backgroundColor: Color(0xFF57015A)),
    );
  }
}
