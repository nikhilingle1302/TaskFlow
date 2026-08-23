import 'package:equatable/equatable.dart';

import '../../domain/entities/app_notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded({required this.notifications});

  final List<AppNotification> notifications;

  int get unreadCount =>
      notifications.where((notification) => !notification.read).length;

  @override
  List<Object?> get props => [notifications];
}

class NotificationEmpty extends NotificationState {
  const NotificationEmpty();
}

class NotificationFailure extends NotificationState {
  const NotificationFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
