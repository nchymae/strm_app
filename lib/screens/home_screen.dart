import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'tasks_screen.dart';
import 'sync_screen.dart';
import 'resources_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildCard(BuildContext context, String title, IconData icon, Widget page) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("STRM Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              AuthService().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: ListView(
        children: [
          buildCard(context, "Manage Tasks", Icons.task, const TasksScreen()),
          buildCard(context, "Sync Tasks", Icons.sync, const SyncScreen()),
          buildCard(context, "External Resources", Icons.public, const ResourcesScreen()),
        ],
      ),
    );
  }
}