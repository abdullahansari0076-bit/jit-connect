// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/auth_repository.dart';

// These files actually exist separately in your folders
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/teacher/teacher_dashboard_screen.dart';
import '../../presentation/screens/teacher/mark_attendance_screen.dart';
import '../../presentation/screens/student/student_dashboard_screen.dart';

// This single import replaces all the missing screen errors!
import '../../presentation/screens/all_screens.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final user = userAsync.asData?.value;
      final isLoggingIn = state.matchedLocation == '/login';

      if (user == null) {
        return isLoggingIn ? null : '/login';
      }
      if (user.mustChangePassword && state.matchedLocation != '/change-password') {
        return '/change-password';
      }
      if (isLoggingIn) {
        return switch (user.role) {
          UserRole.hod => '/hod',
          UserRole.teacher => '/teacher',
          UserRole.student => '/student',
        };
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/change-password', builder: (c, s) => const ChangePasswordScreen()),

      // HOD routes
      ShellRoute(
        builder: (c, s, child) => HodScaffold(child: child),
        routes: [
          GoRoute(path: '/hod', builder: (c, s) => const HodDashboardScreen()),
          GoRoute(path: '/hod/courses', builder: (c, s) => const ManageCoursesScreen()),
          GoRoute(path: '/hod/students', builder: (c, s) => const ManageStudentsScreen()),
          GoRoute(path: '/hod/teachers', builder: (c, s) => const ManageTeachersScreen()),
          GoRoute(
            path: '/hod/timetable/:courseId',
            builder: (c, s) => TimetableBuilderScreen(courseId: s.pathParameters['courseId']!),
          ),
          GoRoute(path: '/hod/reports', builder: (c, s) => const ReportsScreen()),
          GoRoute(path: '/hod/notifications', builder: (c, s) => const NotificationsScreen()),
        ],
      ),

      // Teacher routes
      ShellRoute(
        builder: (c, s, child) => TeacherScaffold(child: child),
        routes: [
          GoRoute(path: '/teacher', builder: (c, s) => const TeacherDashboardScreen()),
          GoRoute(
            path: '/teacher/attendance/:sessionId',
            builder: (c, s) => MarkAttendanceScreen(sessionId: s.pathParameters['sessionId']!),
          ),
          GoRoute(path: '/teacher/extra-class', builder: (c, s) => const ExtraClassScreen()),
          GoRoute(
            path: '/teacher/timetable',
            builder: (c, s) => const TimetableScreen(role: UserRole.teacher),
          ),
          GoRoute(path: '/teacher/notifications', builder: (c, s) => const NotificationsScreen()),
        ],
      ),

      // Student routes
      ShellRoute(
        builder: (c, s, child) => StudentScaffold(child: child),
        routes: [
          GoRoute(path: '/student', builder: (c, s) => const StudentDashboardScreen()),
          GoRoute(
            path: '/student/timetable',
            builder: (c, s) => const TimetableScreen(role: UserRole.student),
          ),
          GoRoute(path: '/student/notifications', builder: (c, s) => const NotificationsScreen()),
        ],
      ),
    ],
  );
});

// ── Bottom nav shells ─────────────────────────────────────────────────────────
class HodScaffold extends StatelessWidget {
  final Widget child;
  const HodScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (i) => _navigate(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Teachers'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Reports'),
        ],
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/hod/courses')) return 1;
    if (location.startsWith('/hod/students')) return 2;
    if (location.startsWith('/hod/teachers')) return 3;
    if (location.startsWith('/hod/reports')) return 4;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    const paths = ['/hod', '/hod/courses', '/hod/students', '/hod/teachers', '/hod/reports'];
    context.go(paths[index]);
  }
}

class TeacherScaffold extends StatelessWidget {
  final Widget child;
  const TeacherScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (i) => _navigate(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Timetable'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/teacher/attendance')) return 1;
    if (loc.startsWith('/teacher/timetable')) return 2;
    if (loc.startsWith('/teacher/notifications')) return 3;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    const paths = ['/teacher', '/teacher', '/teacher/timetable', '/teacher/notifications'];
    context.go(paths[index]);
  }
}

class StudentScaffold extends StatelessWidget {
  final Widget child;
  const StudentScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (i) => _navigate(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Timetable'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/student/timetable')) return 1;
    if (loc.startsWith('/student/notifications')) return 2;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    const paths = ['/student', '/student/timetable', '/student/notifications'];
    context.go(paths[index]);
  }
}
