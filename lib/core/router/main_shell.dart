import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../injection.dart';
import '../theme/app_colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = [
    HomePage(),
    ProjectsPage(),
    TasksPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (_) => NotificationCubit(
        notificationRepository: sl(),
        userId: authState.session.userId,
      )..load(),
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, notificationState) {
          final unreadCount = notificationState is NotificationLoaded
              ? notificationState.unreadCount
              : 0;

          return Scaffold(
            body: IndexedStack(
              index: _index,
              children: _pages,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (index) {
                setState(() => _index = index);
              },
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primaryLight,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, size: 22.sp),
                  selectedIcon: Icon(Icons.home_rounded, size: 22.sp),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_outlined, size: 22.sp),
                  selectedIcon: Icon(Icons.folder_rounded, size: 22.sp),
                  label: 'Projects',
                ),
                NavigationDestination(
                  icon: Icon(Icons.task_alt_outlined, size: 22.sp),
                  selectedIcon: Icon(Icons.task_alt_rounded, size: 22.sp),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text('$unreadCount'),
                    child: Icon(Icons.notifications_outlined, size: 22.sp),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text('$unreadCount'),
                    child: Icon(Icons.notifications_rounded, size: 22.sp),
                  ),
                  label: 'Alerts',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline, size: 22.sp),
                  selectedIcon: Icon(Icons.person_rounded, size: 22.sp),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
