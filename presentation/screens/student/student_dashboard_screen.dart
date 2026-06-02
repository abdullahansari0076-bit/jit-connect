// lib/presentation/screens/student/student_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/app_models.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/attendance_repository.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (user) => user == null
          ? const Scaffold(body: Center(child: Text('Not logged in')))
          : _StudentBody(user: user),
    );
  }
}

class _StudentBody extends ConsumerWidget {
  final AppUser user;
  const _StudentBody({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(
      StreamProvider((ref) => ref.read(attendanceRepositoryProvider).getStudentAttendance(user.uid)),
    );

    return Scaffold(
      body: studentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (student) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _AttendanceBanner(student: student, user: user)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Text('SUBJECT-WISE ATTENDANCE',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: 0.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final entry = student.attendanceSummary.entries.toList()[i];
                  return _SubjectRow(subjectId: entry.key, summary: entry.value);
                },
                childCount: student.attendanceSummary.length,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text('Download Attendance Report'),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _AttendanceBanner extends StatelessWidget {
  final Student student;
  final AppUser user;
  const _AttendanceBanner({required this.student, required this.user});

  @override
  Widget build(BuildContext context) {
    final pct = student.overallAttendancePct;
    final isLow = pct < 75;
    final color = pct >= 75 ? AppColors.success : pct >= 65 ? AppColors.warning : AppColors.danger;

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20, left: 16, right: 16,
      ),
      child: Column(children: [
        Text('${user.name} · Roll: ${student.rollNumber}',
          style: const TextStyle(color: AppColors.primaryAccent, fontSize: 12)),
        const SizedBox(height: 14),
        SizedBox(
          width: 100, height: 100,
          child: Stack(alignment: Alignment.center, children: [
            PieChart(PieChartData(
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(value: pct, color: color, radius: 12, title: ''),
                PieChartSectionData(value: 100 - pct, color: AppColors.primaryLight, radius: 12, title: ''),
              ],
              centerSpaceRadius: 38,
              sectionsSpace: 0,
            )),
            Text('${pct.toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('Overall Attendance', style: TextStyle(color: AppColors.primaryAccent, fontSize: 12)),
        if (isLow) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warningLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 14),
              SizedBox(width: 4),
              Text('Below 75% — attend more classes',
                style: TextStyle(color: AppColors.warning, fontSize: 11)),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final String subjectId;
  final AttendanceSummary summary;
  const _SubjectRow({required this.subjectId, required this.summary});

  Color get _color {
    if (summary.pct >= 75) return AppColors.primary;
    if (summary.pct >= 65) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.surface, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(subjectId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: summary.pct / 100,
                minHeight: 5,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation(_color),
              ),
            ),
            const SizedBox(height: 3),
            Row(children: [
              Text('${summary.attended}/${summary.held} classes',
                style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
              if (summary.pct < 75) ...[
                const SizedBox(width: 6),
                Text('Need ${summary.classesNeededFor75} more to reach 75%',
                  style: const TextStyle(fontSize: 10, color: AppColors.danger)),
              ],
            ]),
          ]),
        ),
        const SizedBox(width: 12),
        Text('${summary.pct.toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _color)),
      ]),
    );
  }
}
