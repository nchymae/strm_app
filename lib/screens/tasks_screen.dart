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
    if (titleController.text.isEmpty) return;

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
  }

  Future<List<Task>> getTasks() async {
    return await DatabaseService.instance.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offline Tasks")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Task Title"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Task Description"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addTask,
              child: const Text("Save Task"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: getTasks(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = snapshot.data!;

                  if (tasks.isEmpty) {
                    return const Center(child: Text("No Tasks Yet"));
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return Card(
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text(task.description),
                          trailing: Icon(
                            task.synced == 1
                                ? Icons.cloud_done
                                : Icons.cloud_off,
                            color: task.synced == 1
                                ? Colors.green
                                : Colors.red,
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