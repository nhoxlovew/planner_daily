import 'package:flutter/material.dart';
import 'package:planner_daily/data/Dbhepler/db_helper.dart';
import 'package:planner_daily/data/model/task.dart';
import 'package:planner_daily/screen/taskdetail.dart'; // Import màn hình Chi tiết Công việc

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
    final tasks = await DBHelper()
        .getTasks(); // Giả sử bạn có phương thức getTasks để lấy danh sách nhiệm vụ
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _navigateToDetail(Task task) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );

    if (updatedTask != null) {
      _loadTasks(); // Tải lại danh sách nhiệm vụ sau khi cập nhật
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
      await DBHelper()
          .deleteTask(task.id!); // Gọi phương thức xóa nhiệm vụ từ DBHelper
      _loadTasks(); // Tải lại danh sách sau khi xóa
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF57015A),
        title: Text('Task List'),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(task.content),
              subtitle: Text(task.day),
              onTap: () =>
                  _navigateToDetail(task), // Điều hướng đến Chi tiết Công việc
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteTask(
                    task), // Gọi hàm xóa khi nhấn vào biểu tượng xóa
                color: Colors.red,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Thêm chức năng thêm công việc mới ở đây nếu cần
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
