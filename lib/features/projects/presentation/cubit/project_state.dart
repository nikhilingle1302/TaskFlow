import 'package:equatable/equatable.dart';

import '../../domain/entities/project.dart';

class ProjectListItem extends Equatable {
  final Project project;
  final int doneCount;
  final int totalCount;

  const ProjectListItem({
    required this.project,
    required this.doneCount,
    required this.totalCount,
  });

  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;

  int get progressPercent => (progress * 100).round();

  @override
  List<Object?> get props => [project.id, doneCount, totalCount];
}

abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

class ProjectLoaded extends ProjectState {
  const ProjectLoaded({
    required this.items,
    required this.filtered,
    required this.query,
    required this.isAdmin,
  });

  final List<ProjectListItem> items;
  final List<ProjectListItem> filtered;
  final String query;
  final bool isAdmin;

  @override
  List<Object?> get props => [items, filtered, query, isAdmin];
}

class ProjectEmpty extends ProjectState {
  const ProjectEmpty({required this.isAdmin});

  final bool isAdmin;

  @override
  List<Object?> get props => [isAdmin];
}

class ProjectFailure extends ProjectState {
  const ProjectFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ProjectActionFailure extends ProjectState {
  const ProjectActionFailure({
    required this.message,
    required this.previous,
  });

  final String message;
  final ProjectLoaded previous;

  @override
  List<Object?> get props => [message, previous];
}
