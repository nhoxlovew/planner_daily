import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:planner_daily/data/Dbhepler/db_helper.dart'; // Make sure to import your DBHelper

class TaskStatisticsScreen extends StatefulWidget {
  const TaskStatisticsScreen({super.key});

  @override
  _TaskStatisticsScreenState createState() => _TaskStatisticsScreenState();
}

class _TaskStatisticsScreenState extends State<TaskStatisticsScreen> {
  int completedTasks = 0;
  int newTasks = 0;
  int inProgressTasks = 0;

  @override
  void initState() {
    super.initState();
    _fetchTaskStatistics();
  }

  Future<void> _fetchTaskStatistics() async {
    Map<String, int> stats = await DBHelper().getTaskStatistics();
    setState(() {
      completedTasks = stats['completed']!;
      newTasks = stats['new']!;
      inProgressTasks = stats['inProgress']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê công việc',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF57015A), // Match your app's color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Tổng quan công việc',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: completedTasks.toDouble(),
                      title: 'Đã hoàn thành\n$completedTasks',
                      color: Colors.green,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: newTasks.toDouble(),
                      title: 'Mới tạo\n$newTasks',
                      color: Colors.blue,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: inProgressTasks.toDouble(),
                      title: 'Đang thực hiện\n$inProgressTasks',
                      color: Colors.orange,
                      radius: 50,
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  centerSpaceRadius: 40,
                  sectionsSpace: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Optional: Display more detailed statistics
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chi tiết thống kê:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Đã hoàn thành: $completedTasks'),
                    Text('Mới tạo: $newTasks'),
                    Text('Đang thực hiện: $inProgressTasks'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
