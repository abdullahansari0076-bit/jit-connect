// lib/presentation/screens/teacher/teacher_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/app_models.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../../data/repositories/timetable_repository.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) => user == null
          ? const Scaffold(body: Center(child: Text('Not logged in')))
          : _DashboardBody(user: user),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  final AppUser user;
  const _DashboardBody({required this.user});

  String get _todayDay => DateFormat('EEEE').format(DateTime.now()).toLowerCase();
  String get _todayStr => DateFormat('EEE, d MMM').format(DateTime.now());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(
      StreamProvider((ref) => ref.read(timetableRepositoryProvider)
          .getTeacherSlotsForDay(teacherId: user.uid, dayOfWeek: _todayDay))
    );
    final sessionsAsync = ref.watch(
      StreamProvider((ref) => ref.read(attendanceRepositoryProvider)
          .getTodaySessions(user.uid))
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16, right: 16, bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Good morning,',
                            style: TextStyle(color: AppColors.primaryAccent, fontSize: 12)),
                          Text(user.name,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                          Text(_todayStr,
                            style: const TextStyle(color: AppColors.primaryAccent, fontSize: 11)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.go('/teacher/notifications'),
                        child: const Icon(Icons.notifications_outlined, color: AppColors.primaryAccent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: sessionsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => const SizedBox.shrink(),
                data: (sessions) {
                  final done = sessions.where((s) => s.status == AttendanceStatus.submitted).length;
                  final pending = (slotsAsync.asData?.value.where((s) => !s.isBreak).length ?? 0) - done;
                  return Row(
                    children: [
                      _StatCard(label: "Today's classes", value: '${slotsAsync.asData?.value.where((s) => !s.isBreak).length ?? 0}', sub: '$done done · $pending pending'),
                      const SizedBox(width: 8),
                      _StatCard(label: 'Low attendance', value: '—', sub: 'students below 75%', isWarn: true),
                    ],
                  );
                },
              ),
            ),
          ),

          // Today's schedule
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text("Today's Schedule",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13)),
                        ],
                      ),
                    ),
                    const Divider(height: 0),
                    slotsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Error loading timetable: $e'),
                      ),
                      data: (slots) {
                        if (slots.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: Text('No classes scheduled today',
                              style: TextStyle(color: AppColors.textHint))),
                          );
                        }
                        return Column(
                          children: slots.map((slot) => _PeriodRow(
                            slot: slot,
                            sessions: sessionsAsync.asData?.value ?? [],
                            onMark: () => _openAttendance(context, ref, slot),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Quick actions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      letterSpacing: 0.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8, crossAxisSpacing: 8,
                    childAspectRatio: 2.4,
                    children: [
                      _QuickAction(icon: Icons.check_circle_outline, label: 'Mark Attendance', onTap: () {}),
                      _QuickAction(icon: Icons.calendar_month_outlined, label: 'View Timetable', onTap: () => context.go('/teacher/timetable')),
                      _QuickAction(icon: Icons.add_circle_outline, label: 'Extra / Arrangement', onTap: () => context.go('/teacher/extra-class')),
                      _QuickAction(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => context.go('/teacher/notifications')),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Future<void> _openAttendance(BuildContext context, WidgetRef ref, TimetableSlot slot) async {
    if (!slot.isAttendanceWindowOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance window is not open for this period yet.')),
      );
      return;
    }
    final session = await ref.read(attendanceRepositoryProvider).createSession(
      slotId: slot.slotId,
      subjectId: slot.subjectId,
      teacherId: slot.teacherId,
      courseId: slot.courseId,
    );
    if (context.mounted) context.go('/teacher/attendance/${session.sessionId}');
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final bool isWarn;
  const _StatCard({required this.label, required this.value, required this.sub, this.isWarn = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500,
            color: isWarn ? AppColors.warning : AppColors.primary)),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
        ]),
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  final TimetableSlot slot;
  final List<AttendanceSession> sessions;
  final VoidCallback onMark;
  const _PeriodRow({required this.slot, required this.sessions, required this.onMark});

  @override
  Widget build(BuildContext context) {
    if (slot.isBreak) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(children: [
          SizedBox(width: 56, child: Text('${slot.startTime}–${slot.endTime}',
            style: const TextStyle(fontSize: 10, color: AppColors.textHint))),
          const SizedBox(width: 8),
          Container(width: 8, height: 8, decoration: BoxDecoration(
            color: AppColors.border, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text('Lunch Break', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
        ]),
      );
    }

    final session = sessions.where((s) => s.slotId == slot.slotId).firstOrNull;
    final isDone = session?.status == AttendanceStatus.submitted;
    final isNow = slot.isAttendanceWindowOpen;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surface, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(children: [
        SizedBox(width: 56, child: Text('${slot.startTime}–${slot.endTime}',
          style: const TextStyle(fontSize: 10, color: AppColors.textHint))),
        const SizedBox(width: 8),
        Container(width: 8, height: 8, decoration: BoxDecoration(
          color: isDone ? AppColors.success : isNow ? AppColors.warning : AppColors.primary,
          shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(slot.subjectId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(slot.room, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
        ])),
        if (isDone)
          const Text('Done', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w500))
        else if (isNow)
          GestureDetector(
            onTap: onMark,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Mark', style: TextStyle(fontSize: 10, color: Colors.white)),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Soon', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ),
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            maxLines: 2)),
        ]),
      ),
    );
  }
}
