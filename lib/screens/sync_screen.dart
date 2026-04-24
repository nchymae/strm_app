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
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Sync Tasks'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [Color(0xFFff7eb3), Color(0xFF8B5CF6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(
                  Icons.cloud_sync,
                  size: 60,
                  color: Colors.white,
                ),

                const SizedBox(height: 20),

                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : syncTasks,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : const Text(
                            "Sync Now",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}