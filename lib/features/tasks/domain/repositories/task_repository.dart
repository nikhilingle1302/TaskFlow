import '../entities/comment.dart';
import '../entities/task_item.dart';

class TaskFilter {
  final String? status;
  final String? priority;
  final String? assigneeId;
  final DateTime? dueFrom;
  final DateTime? dueTo;

  const TaskFilter({
    this.status,
    this.priority,
    this.assigneeId,
    this.dueFrom,
    this.dueTo,
  });
}

abstract class TaskRepository {
  Future<List<TaskItem>> getTasks({
    required String orgId,
    String? projectId,
    TaskFilter filter = const TaskFilter(),
  });

  Future<TaskItem> getTaskById(String taskId);

  Future<TaskItem> createTask({
    required String orgId,
    required String projectId,
    required String title,
    required String description,
    required String status,
    required String priority,
    String? assigneeId,
    DateTime? dueDate,
  });

  Future<TaskItem> updateTask({
    required String orgId,
    required TaskItem task,
  });

  Future<void> deleteTask(String taskId);

  Future<TaskItem> assignTask({
    required String orgId,
    required String taskId,
    required String? userId,
  });

  Future<List<Comment>> getComments(String taskId);

  Future<Comment> addComment({
    required String taskId,
    required String authorId,
    required String body,
  });
}
