class Project {
  final String id;
  final String orgId;
  final String name;
  final String description;
  final int taskCount;
  final String status;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.orgId,
    required this.name,
    required this.description,
    required this.taskCount,
    required this.status,
    required this.createdAt,
  });

  Project copyWith({
    String? name,
    String? description,
    int? taskCount,
    String? status,
  }) {
    return Project(
      id: id,
      orgId: orgId,
      name: name ?? this.name,
      description: description ?? this.description,
      taskCount: taskCount ?? this.taskCount,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
