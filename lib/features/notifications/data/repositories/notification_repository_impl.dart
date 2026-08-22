import '../../../../core/error/app_exception.dart';
import '../../../../core/network/mock_data_store.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._store);

  final MockDataStore _store;

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    await _store.ensureLoaded();
    return _store.notifications
        .where((n) => n.userId == userId)
        .map(_toEntity)
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _store.ensureLoaded();
    final index =
        _store.notifications.indexWhere((n) => n.id == notificationId);
    if (index < 0) {
      throw NotFoundException('Notification $notificationId was not found.');
    }
    final list = [..._store.notifications];
    list[index] = list[index].copyWith(read: true);
    _store.notifications = list;
  }

  AppNotification _toEntity(NotificationModel model) {
    return AppNotification(
      id: model.id,
      userId: model.userId,
      type: model.type,
      taskId: model.taskId,
      message: model.message,
      read: model.read,
      createdAt: model.createdAt,
    );
  }
}
