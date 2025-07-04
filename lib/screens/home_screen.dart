import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'login_screen.dart';
import 'create_task.dart';
import 'edit_task.dart';
import '../theme/theme_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://localhost:3000/api/task/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> fetched = jsonDecode(response.body);
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(fetched);
        _tasks.sort((a, b) {
          final aTime =
              DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.now();
          final bTime =
              DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.now();
          return bTime.compareTo(aTime);
        });
      });
    }
  }

  void _toggleTaskCompletion(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final task = _tasks[index];
    final newStatus = task['status'] == 'Completed' ? 'Pending' : 'Completed';

    final response = await http.put(
      Uri.parse('http://localhost:3000/api/task/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id': task['_id'],
        'title': task['title'],
        'description': task['description'],
        'status': newStatus,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _tasks[index]['status'] = newStatus;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        backgroundColor: ThemeColors.accent,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.settings, color: ThemeColors.textPrimary),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        title: Text(
          'Your Tasks',
          style: TextStyle(
            color: ThemeColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: ThemeColors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: ThemeColors.accent),
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: ThemeColors.textPrimary,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: ThemeColors.warn),
              title: Text('Logout', style: TextStyle(color: ThemeColors.warn)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  final groupedTasks = <String, List<Map<String, dynamic>>>{};

                  for (var task in _tasks) {
                    final timestamp = task['timestamp'];
                    if (timestamp != null) {
                      final date = DateTime.tryParse(timestamp);
                      if (date != null) {
                        final key = DateFormat('yyyy-MM-dd').format(date);
                        groupedTasks.putIfAbsent(key, () => []).add(task);
                      }
                    }
                  }

                  final sortedKeys =
                      groupedTasks.keys.toList()..sort(
                        (a, b) =>
                            DateTime.parse(b).compareTo(DateTime.parse(a)),
                      );

                  return ListView.builder(
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, sectionIndex) {
                      final key = sortedKeys[sectionIndex];
                      final tasks = groupedTasks[key]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                          Text(
                            DateFormat(
                              'EEEE, MMM dd',
                            ).format(DateTime.parse(key)),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.textPrimary,
                            ),
                          ),
                          Divider(color: ThemeColors.textPrimary, thickness: 1),
                          ...tasks.map((task) {
                            final isCompleted =
                                (task['status']?.toString().toLowerCase() ??
                                    '') ==
                                'completed';

                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      isCompleted
                                          ? ThemeColors.borderCompleted
                                          : ThemeColors.border,
                                  width: 1.4,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: Card(
                                elevation: 0,
                                margin: EdgeInsets.zero,
                                color:
                                    isCompleted
                                        ? ThemeColors.completed
                                        : ThemeColors.taskDefault,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: isCompleted,
                                    onChanged: (_) {
                                      final index = _tasks.indexWhere(
                                        (t) => t['_id'] == task['_id'],
                                      );
                                      if (index != -1) {
                                        _toggleTaskCompletion(index);
                                      }
                                    },
                                    activeColor: ThemeColors.checkboxActive,
                                  ),
                                  title: Text(
                                    task['title'] ?? '',
                                    style: TextStyle(
                                      decoration:
                                          isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                      color:
                                          isCompleted
                                              ? ThemeColors.textSecondary
                                              : ThemeColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (task['description'] != null &&
                                          task['description']
                                              .toString()
                                              .isNotEmpty)
                                        Text(
                                          task['description'],
                                          style: TextStyle(
                                            decoration:
                                                isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                            color: ThemeColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder:
                                          (context) => ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                            child: Material(
                                              color: ThemeColors.background,
                                              child: EditTaskScreen(task: task),
                                            ),
                                          ),
                                    ).then((refresh) {
                                      if (refresh == true) {
                                        _fetchTasks();
                                      }
                                    });
                                  },
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 140,
        height: 50,
        child: FloatingActionButton(
          shape: StadiumBorder(),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder:
                  (context) => ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Material(
                      color: ThemeColors.background,
                      child: AddTaskScreen(),
                    ),
                  ),
            ).then((refresh) {
              if (refresh == true) {
                _fetchTasks();
              }
            });
          },
          backgroundColor: ThemeColors.accent,
          elevation: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: ThemeColors.textPrimary),
              SizedBox(width: 6),
              Text(
                'Add Task',
                style: TextStyle(color: ThemeColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
