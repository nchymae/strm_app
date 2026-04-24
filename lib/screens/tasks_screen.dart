import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  Future<void> addTask() async {
    // ✅ VALIDATION (UNCHANGED)
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task title is required")),
      );
      return;
    }

    try {
      await DatabaseService.instance.insertTask(
        Task(
          title: titleController.text,
          description: descController.text,
          synced: 0,
        ),
      );

      titleController.clear();
      descController.clear();

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving task: $e")),
      );
    }
  }

  Future<List<Task>> getTasks() async {
    try {
      return await DatabaseService.instance.getTasks();
    } catch (e) {
      return [];
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Offline Tasks"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 INPUT CARD
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Task Title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: "Task Description",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: addTask,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text("Save Task"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 TASK LIST
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: getTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Tasks Yet",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final tasks = snapshot.data!;

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: task.synced == 1
                                ? [Colors.green.shade300, Colors.green]
                                : [Colors.red.shade300, Colors.red],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            task.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            task.description,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          trailing: Icon(
                            task.synced == 1
                                ? Icons.cloud_done
                                : Icons.cloud_off,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}