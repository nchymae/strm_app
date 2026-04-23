import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadTask(Task task) async {
    await _firestore
        .collection('tasks')
        .doc(task.id.toString())
        .set({
      'title': task.title,
      'description': task.description,
      'timestamp': Timestamp.now(),
      'synced': 1,
    });
  }
}