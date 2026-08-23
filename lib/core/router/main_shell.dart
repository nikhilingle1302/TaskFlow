import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    PlaceholderTabPage(
      title: 'Projects',
      subtitle: 'Project list',
    ),
    PlaceholderTabPage(
      title: 'Tasks',
      subtitle: 'Task list',
    ),
    PlaceholderTabPage(
      title: 'Notifications',
      subtitle: 'Inbox',
    ),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.notifications_outlined, size: 22.sp),
            selectedIcon: Icon(Icons.notifications_rounded, size: 22.sp),
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
  }
}

class PlaceholderTabPage extends StatelessWidget {
  const PlaceholderTabPage({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: AppTypography.screenTitle()),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: AppTypography.cardTitle()),
              SizedBox(height: 8.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
