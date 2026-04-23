import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  Future<List<PostModel>> loadPosts() async {
    return await ApiService().fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("External Resources")),
      body: FutureBuilder<List<PostModel>>(
        future: loadPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(post.title),
                  leading: CircleAvatar(
                    child: Text(post.id.toString()),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}