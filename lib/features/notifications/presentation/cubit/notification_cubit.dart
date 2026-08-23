import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

export 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required NotificationRepository notificationRepository,
    required String userId,
  })  : _notificationRepository = notificationRepository,
        _userId = userId,
        super(const NotificationInitial());

  final NotificationRepository _notificationRepository;
  final String _userId;

  Future<void> load() async {
    emit(const NotificationLoading());
    try {
      final notifications =
          await _notificationRepository.getNotifications(_userId);
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (notifications.isEmpty) {
        emit(const NotificationEmpty());
        return;
      }

      emit(NotificationLoaded(notifications: notifications));
    } on AppException catch (e) {
      emit(NotificationFailure(message: e.message));
    } catch (_) {
      emit(const NotificationFailure(message: 'Could not load notifications.'));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    try {
      await _notificationRepository.markAsRead(notificationId);
      final updated = current.notifications.map((notification) {
        if (notification.id == notificationId) {
          return AppNotification(
            id: notification.id,
            userId: notification.userId,
            type: notification.type,
            taskId: notification.taskId,
            message: notification.message,
            read: true,
            createdAt: notification.createdAt,
          );
        }
        return notification;
      }).toList();

      emit(NotificationLoaded(notifications: updated));
    } catch (_) {
      await load();
    }
  }
}
