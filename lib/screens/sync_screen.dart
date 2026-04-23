import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/firestore_service.dart';
import '../services/connectivity_service.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  String status = "Ready to sync";
  bool loading = false;

  Future<void> syncTasks() async {
    setState(() {
      loading = true;
      status = "Checking internet...";
    });

    final online = await ConnectivityService.isOnline();

    if (!online) {
      setState(() {
        loading = false;
        status = "No Internet Connection";
      });
      return;
    }

    setState(() => status = "Syncing tasks...");

    try {
      final tasks = await DatabaseService.instance.getUnsyncedTasks();

      for (var task in tasks) {
        try {
          await FirestoreService().uploadTask(task);

          if (task.id != null) {
            await DatabaseService.instance.markSynced(task.id!);
          }
        } catch (e) {
          print("Error syncing task ${task.id}: $e");
        }
      }

      setState(() {
        loading = false;
        status = "${tasks.length} task(s) synced successfully";
      });
    } catch (e) {
      setState(() {
        loading = false;
        status = "Sync failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Tasks')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : syncTasks,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Sync Now"),
            )
          ],
        ),
      ),
    );
  }
}