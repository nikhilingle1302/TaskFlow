import 'package:equatable/equatable.dart';

import '../../../projects/domain/entities/project.dart';

class HomeProjectItem extends Equatable {
  final Project project;
  final int doneCount;
  final int totalCount;

  const HomeProjectItem({
    required this.project,
    required this.doneCount,
    required this.totalCount,
  });

  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;

  int get progressPercent => (progress * 100).round();

  @override
  List<Object?> get props => [project.id, doneCount, totalCount];
}

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.userName,
    required this.projectCount,
    required this.taskCount,
    required this.overdueCount,
    required this.projects,
  });

  final String userName;
  final int projectCount;
  final int taskCount;
  final int overdueCount;
  final List<HomeProjectItem> projects;

  @override
  List<Object?> get props => [
        userName,
        projectCount,
        taskCount,
        overdueCount,
        projects,
      ];
}

class HomeEmpty extends HomeState {
  const HomeEmpty({required this.userName});

  final String userName;

  @override
  List<Object?> get props => [userName];
}

class HomeFailure extends HomeState {
  const HomeFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
