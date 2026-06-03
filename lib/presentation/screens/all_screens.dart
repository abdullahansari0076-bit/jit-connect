// lib/presentation/screens/hod/hod_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_repository.dart';

class HodDashboardScreen extends ConsumerWidget {
  const HodDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).asData?.value;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Container(
          color: AppColors.primary,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16, right: 16, bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Welcome back,', style: TextStyle(color: AppColors.primaryAccent, fontSize: 11)),
                Text(user?.name ?? 'HOD', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
                const Text(AppConstants.collegeName, style: TextStyle(color: AppColors.primaryAccent, fontSize: 10)),
              ]),
              IconButton(icon: const Icon(Icons.logout, color: AppColors.primaryAccent),
                onPressed: () => ref.read(authRepositoryProvider).signOut()),
            ]),
          ]),
        )),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(10),
          child: GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.6,
            children: [
              _StatCard(label: 'Total Students', value: '487', sub: 'Across all courses', icon: Icons.people_outline),
              _StatCard(label: 'Teachers', value: '24', sub: 'Active faculty', icon: Icons.person_outline),
              _StatCard(label: 'Courses', value: '22', sub: 'Sems & years active', icon: Icons.book_outlined),
              _StatCard(label: 'Low Attendance', value: '31', sub: 'Students below 75%', icon: Icons.warning_amber_outlined, isWarn: true),
            ],
          ),
        )),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.5,
            children: [
              _ActionCard(icon: Icons.book_outlined, label: 'Manage Courses', count: '22 active', onTap: () => context.go('/hod/courses')),
              _ActionCard(icon: Icons.people_outline, label: 'Manage Students', count: '487 enrolled', onTap: () => context.go('/hod/students')),
              _ActionCard(icon: Icons.person_outline, label: 'Manage Teachers', count: '24 faculty', onTap: () => context.go('/hod/teachers')),
              _ActionCard(icon: Icons.calendar_month_outlined, label: 'Build Timetable', count: 'Mon–Sat', onTap: () => context.go('/hod/timetable/bpharm_sem3')),
              _ActionCard(icon: Icons.bar_chart_outlined, label: 'View Reports', count: 'Export PDF/Excel', onTap: () => context.go('/hod/reports')),
              _ActionCard(icon: Icons.notifications_outlined, label: 'Notifications', count: 'Send alerts', onTap: () => context.go('/hod/notifications')),
            ],
          ),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final bool isWarn;
  const _StatCard({required this.label, required this.value, required this.sub, required this.icon, this.isWarn = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: isWarn ? AppColors.warning : AppColors.primary),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: isWarn ? AppColors.warning : AppColors.primary)),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
    ]),
  );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label, count;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.count, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        Text(count, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/screens/hod/manage_courses_screen.dart
class ManageCoursesScreen extends StatelessWidget {
  const ManageCoursesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final programs = ['B.Pharm', 'D.Pharm', 'M.Pharm', 'Pharm.D'];
    return Scaffold(
      appBar: AppBar(title: const Text('Course & Subject Management'), actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: () {}),
      ]),
      body: ListView(children: programs.map((prog) {
        final courses = AppConstants.allCourses.where((c) => c['program'] == prog).toList();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(12,12,12,6),
            child: Text(prog, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.5))),
          Card(margin: const EdgeInsets.symmetric(horizontal: 10), child: Column(
            children: courses.asMap().entries.map((e) => Column(children: [
              ListTile(
                dense: true,
                title: Text(e.value['name'] as String, style: const TextStyle(fontSize: 13)),
                trailing: _Badge(label: '5 subjects', color: AppColors.infoLight, textColor: AppColors.info),
                onTap: () {},
              ),
              if (e.key < courses.length - 1) const Divider(height: 0, indent: 16),
            ])).toList(),
          )),
        ]);
      }).toList()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add Subject'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/screens/hod/manage_students_screen.dart
class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Management'), actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
      ]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(10), child: TextField(
          decoration: const InputDecoration(hintText: 'Search by name or roll no...', prefixIcon: Icon(Icons.search, size: 18)),
        )),
        Expanded(child: ListView.separated(
          itemCount: 10,
          separatorBuilder: (_, __) => const Divider(height: 0, indent: 12, endIndent: 12),
          itemBuilder: (_, i) => ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.infoLight, child: Text('S$i', style: const TextStyle(fontSize: 11, color: AppColors.info))),
            title: Text('Student Name $i'),
            subtitle: Text('BP3-00$i · B.Pharm Sem 3', style: const TextStyle(fontSize: 11)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              TextButton(onPressed: () {}, child: const Text('Edit', style: TextStyle(fontSize: 11))),
            ]),
          ),
        )),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, icon: const Icon(Icons.person_add), label: const Text('Add Student'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/screens/hod/manage_teachers_screen.dart
class ManageTeachersScreen extends StatelessWidget {
  const ManageTeachersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Management'), actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: () {}),
      ]),
      body: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (_, i) => Card(child: ListTile(
          leading: CircleAvatar(backgroundColor: AppColors.surface, child: Text('T$i', style: const TextStyle(color: AppColors.primary, fontSize: 12))),
          title: Text('Dr. Teacher $i'),
          subtitle: Text('Pharmaceutics · B.Pharm Sem ${i+1}', style: const TextStyle(fontSize: 11)),
          trailing: TextButton(onPressed: () {}, child: const Text('View', style: TextStyle(fontSize: 11))),
        )),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, icon: const Icon(Icons.person_add), label: const Text('Add Teacher'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/screens/hod/timetable_builder_screen.dart
class TimetableBuilderScreen extends StatefulWidget {
  final String courseId;
  const TimetableBuilderScreen({super.key, required this.courseId});
  @override State<TimetableBuilderScreen> createState() => _TimetableBuilderScreenState();
}
class _TimetableBuilderScreenState extends State<TimetableBuilderScreen> {
  String _day = 'monday';
  final days = AppConstants.workingDays;
  final periods = [
    {'time': '9:10–10:00', 'subject': 'Pharmaceutics – III', 'teacher': 'Dr. Ravi Kumar', 'room': 'Room 201'},
    {'time': '10:00–10:50', 'subject': 'Physical Pharmacy', 'teacher': 'Dr. Ravi Kumar', 'room': 'Room 201'},
    {'time': '10:50–11:40', 'subject': 'Pharmacology – I', 'teacher': 'Dr. S. Mishra', 'room': 'Room 305'},
    {'time': '11:40–12:30', 'subject': 'Pharm. Chemistry', 'teacher': 'Dr. A. Gupta', 'room': 'Room 102'},
    {'time': '1:20–2:10', 'subject': 'LUNCH BREAK', 'teacher': '', 'room': ''},
    {'time': '2:10–4:00', 'subject': 'Pharmaceutics Lab', 'teacher': 'Dr. Ravi Kumar', 'room': 'Lab 1'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Timetable · ${widget.courseId}')),
      body: Column(children: [
        Container(color: AppColors.primary, child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: days.map((d) => GestureDetector(
            onTap: () => setState(() => _day = d),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _day == d ? AppColors.surface : Colors.transparent,
                borderRadius: _day == d ? const BorderRadius.vertical(top: Radius.circular(8)) : null,
              ),
              child: Text(d[0].toUpperCase() + d.substring(1, 3),
                style: TextStyle(color: _day == d ? AppColors.primary : AppColors.primaryAccent, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          )).toList()),
        )),
        Expanded(child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: periods.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (_, i) {
            if (i == periods.length) return Padding(
              padding: const EdgeInsets.all(8),
              child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Add period')),
            );
            final p = periods[i];
            final isBreak = p['subject'] == 'LUNCH BREAK';
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isBreak ? AppColors.surface : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 0.5),
                borderLeft: isBreak ? null : BorderSide(color: AppColors.primary, width: 3),
              ),
              child: Row(children: [
                SizedBox(width: 70, child: Text(p['time']!, style: const TextStyle(fontSize: 10, color: AppColors.textHint))),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p['subject']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isBreak ? AppColors.textHint : AppColors.textPrimary)),
                  if (!isBreak) Text('${p['teacher']} · ${p['room']}', style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                ])),
                if (!isBreak) IconButton(icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textHint), onPressed: () {}),
              ]),
            );
          },
        )),
        Padding(padding: const EdgeInsets.all(10), child: Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_outlined, size: 16), label: const Text('Upload Image/PDF'))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Timetable saved and published!'))),
            icon: const Icon(Icons.check, size: 16), label: const Text('Save & Publish'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
          )),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/screens/hod/reports_screen.dart
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: ListView(padding: const EdgeInsets.all(10), children: [
        Row(children: [
          Expanded(child: _StatCard2(label: 'Avg. attendance', value: '78%', sub: 'All courses')),
          const SizedBox(width: 8),
          Expanded(child: _StatCard2(label: 'Defaulters', value: '31', sub: 'Below 75%', isWarn: true)),
        ]),
        const SizedBox(height: 12),
        Card(child: Column(children: [
          _ReportTile(icon: Icons.warning_amber_outlined, iconBg: AppColors.dangerLight, iconColor: AppColors.danger,
            title: 'Defaulter list', sub: 'Students below 75% — all courses', onTap: () {}),
          const Divider(height: 0, indent: 56),
          _ReportTile(icon: Icons.bar_chart_outlined, iconBg: AppColors.successLight, iconColor: AppColors.success,
            title: 'Course-wise summary', sub: 'Attendance % per course/semester', onTap: () {}),
          const Divider(height: 0, indent: 56),
          _ReportTile(icon: Icons.person_outline, iconBg: AppColors.infoLight, iconColor: AppColors.info,
            title: 'Teacher-wise report', sub: 'Classes held vs scheduled', onTap: () {}),
          const Divider(height: 0, indent: 56),
          _ReportTile(icon: Icons.calendar_month_outlined, iconBg: AppColors.warningLight, iconColor: AppColors.warning,
            title: 'Monthly report', sub: 'May 2026 — all departments', onTap: () {}),
        ])),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.table_chart_outlined, size: 16), label: const Text('Export Excel'))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf_outlined, size: 16), label: const Text('Export PDF'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)))),
        ]),
      ]),
    );
  }
}
class _StatCard2 extends StatelessWidget {
  final String label, value, sub; final bool isWarn;
  const _StatCard2({required this.label, required this.value, required this.sub, this.isWarn = false});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: isWarn ? AppColors.warning : AppColors.primary)),
      Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
    ]),
  );
}
class _ReportTile extends StatelessWidget {
  final IconData icon; final Color iconBg, iconColor;
  final String title, sub; final VoidCallback onTap;
  const _ReportTile({required this.icon, required this.iconBg, required this.iconColor, required this.title, required this.sub, required this.onTap});
  @override Widget build(BuildContext context) => ListTile(
    leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: iconColor, size: 18)),
    title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
    trailing: const Icon(Icons.download_outlined, size: 18, color: AppColors.textHint),
    onTap: onTap,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/screens/teacher/extra_class_screen.dart
class ExtraClassScreen extends StatefulWidget {
  const ExtraClassScreen({super.key});
  @override State<ExtraClassScreen> createState() => _ExtraClassScreenState();
}
class _ExtraClassScreenState extends State<ExtraClassScreen> {
  String _type = 'extra';
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Extra / Arrangement Class')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(12), child: Column(children: [
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Class type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _TypeBtn(label: 'Extra Class', selected: _type == 'extra', onTap: () => setState(() => _type = 'extra'))),
            const SizedBox(width: 8),
            Expanded(child: _TypeBtn(label: 'Arrangement Class', selected: _type == 'arrangement', onTap: () => setState(() => _type = 'arrangement'))),
          ]),
        ]))),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _FormField(label: 'Date', child: TextField(decoration: const InputDecoration(hintText: 'Select date'))),
          _FormField(label: 'Time slot', child: DropdownButtonFormField(
            decoration: const InputDecoration(), value: '9:10–10:00',
            items: ['9:10–10:00','10:00–10:50','10:50–11:40','2:10–3:00','3:00–3:50']
                .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (_) {},
          )),
          _FormField(label: 'Course & Semester', child: DropdownButtonFormField(
            decoration: const InputDecoration(), value: 'B.Pharm Sem 3',
            items: ['B.Pharm Sem 1','B.Pharm Sem 3','D.Pharm Year 1','M.Pharm (Pharmacology) Sem 1']
                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (_) {},
          )),
          _FormField(label: 'Subject', child: DropdownButtonFormField(
            decoration: const InputDecoration(), value: 'Physical Pharmacy',
            items: ['Pharmaceutics – III','Physical Pharmacy','Pharmaceutics Lab']
                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (_) {},
          )),
          if (_type == 'arrangement') ...[
            _FormField(label: 'Original faculty (arranging for)', child: DropdownButtonFormField(
              decoration: const InputDecoration(), value: 'Dr. S. Mishra',
              items: ['Dr. S. Mishra','Dr. A. Gupta','Dr. N. Singh']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (_) {},
            )),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(8)),
              child: const Row(children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                SizedBox(width: 8),
                Expanded(child: Text('Approval request will be sent to original faculty. Attendance marking enabled only after approval.',
                  style: TextStyle(fontSize: 11, color: AppColors.warning))),
              ])),
          ],
          _FormField(label: 'Room / Location', child: const TextField(decoration: InputDecoration(hintText: 'e.g. Room 201'))),
          _FormField(label: 'Reason / Note', child: const TextField(decoration: InputDecoration(hintText: 'Reason for extra class...'), maxLines: 2)),
        ]))),
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted! Awaiting approval.'))),
          child: const Text('Submit Request'),
        ),
      ])),
    );
  }
}
class _TypeBtn extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _TypeBtn({required this.label, required this.selected, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: selected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(8),
      border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 0.5)),
    child: Text(label, textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppColors.textSecondary)),
  ));
}
class _FormField extends StatelessWidget {
  final String label; final Widget child;
  const _FormField({required this.label, required this.child});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 10),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    const SizedBox(height: 4),
    child,
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/screens/shared/notifications_screen.dart
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), actions: [
        IconButton(icon: const Icon(Icons.done_all), onPressed: () {}),
      ]),
      body: ListView(children: [
        _SectionHeader(label: 'Today'),
        _NotifTile(icon: Icons.alarm, iconBg: AppColors.infoLight, iconColor: AppColors.info, isUnread: true,
          title: 'Class reminder — Physical Pharmacy', body: 'Starts in 10 minutes · Room 305 · B.Pharm Sem 3', time: '10:40 AM'),
        _NotifTile(icon: Icons.warning_amber_outlined, iconBg: AppColors.warningLight, iconColor: AppColors.warning, isUnread: true,
          title: 'Low attendance alert', body: 'Priya Sharma (Roll 21) — Pharmacology–I is at 62%. Below 75% threshold.', time: '9:30 AM'),
        _SectionHeader(label: 'Yesterday'),
        _NotifTile(icon: Icons.check_circle_outline, iconBg: AppColors.successLight, iconColor: AppColors.success, isUnread: false,
          title: 'Arrangement class approved', body: 'Dr. S. Mishra approved your arrangement request for Pharmacology–I on 27 May.', time: 'Yesterday, 4:15 PM'),
        _NotifTile(icon: Icons.calendar_today_outlined, iconBg: AppColors.infoLight, iconColor: AppColors.info, isUnread: false,
          title: 'Timetable updated', body: 'HOD updated Thursday schedule for B.Pharm Sem 3. Please review.', time: 'Yesterday, 2:00 PM'),
      ]),
    );
  }
}
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.5)),
  );
}
class _NotifTile extends StatelessWidget {
  final IconData icon; final Color iconBg, iconColor;
  final bool isUnread; final String title, body, time;
  const _NotifTile({required this.icon, required this.iconBg, required this.iconColor, required this.isUnread, required this.title, required this.body, required this.time});
  @override Widget build(BuildContext context) => Container(
    color: isUnread ? const Color(0xFFEEF3FB) : Colors.white,
    child: ListTile(
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(body, style: const TextStyle(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
      ]),
      trailing: isUnread ? Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)) : null,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/screens/auth/change_password_screen.dart
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});
  @override ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}
class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        const SizedBox(height: 40),
        const Icon(Icons.lock_reset, color: AppColors.primaryAccent, size: 48),
        const SizedBox(height: 16),
        const Text('Set New Password', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('You must change your password before continuing.', style: TextStyle(color: AppColors.primaryAccent, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Form(key: _formKey, child: Column(children: [
            TextFormField(controller: _currentCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Current password'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New password'), validator: (v) => v!.length < 6 ? 'Min 6 characters' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm new password'),
              validator: (v) => v != _newCtrl.text ? 'Passwords do not match' : null),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : () async {
                if (!_formKey.currentState!.validate()) return;
                setState(() => _loading = true);
                try {
                  await ref.read(authRepositoryProvider).changePassword(currentPwd: _currentCtrl.text, newPwd: _newCtrl.text);
                  if (mounted) context.go('/teacher');
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.danger));
                } finally { if (mounted) setState(() => _loading = false); }
              },
              child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Update Password'),
            ),
          ]))),
      ]))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/screens/shared/timetable_screen.dart
class TimetableScreen extends StatefulWidget {
  final UserRole role;
  const TimetableScreen({super.key, required this.role});
  @override State<TimetableScreen> createState() => _TimetableScreenState();
}
class _TimetableScreenState extends State<TimetableScreen> {
  String _day = 'monday';
  final days = AppConstants.workingDays;
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: Column(children: [
        Container(color: AppColors.primary, child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: days.map((d) => GestureDetector(
            onTap: () => setState(() => _day = d),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _day == d ? AppColors.surface : Colors.transparent,
                borderRadius: _day == d ? const BorderRadius.vertical(top: Radius.circular(8)) : null),
              child: Text(d[0].toUpperCase() + d.substring(1, 3),
                style: TextStyle(color: _day == d ? AppColors.primary : AppColors.primaryAccent, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          )).toList()),
        )),
        Expanded(child: ListView(padding: const EdgeInsets.all(8), children: [
          _PeriodCard(time: '9:10–10:00', subject: 'Pharmaceutics – III', teacher: 'Dr. Ravi Kumar', room: 'Room 201', type: 'Theory'),
          _PeriodCard(time: '10:00–10:50', subject: 'Physical Pharmacy', teacher: 'Dr. Ravi Kumar', room: 'Room 201', type: 'Theory'),
          _PeriodCard(time: '10:50–11:40', subject: 'Pharmacology – I', teacher: 'Dr. S. Mishra', room: 'Room 305', type: 'Theory'),
          _PeriodCard(time: '11:40–12:30', subject: 'Pharm. Chemistry', teacher: 'Dr. A. Gupta', room: 'Room 102', type: 'Theory'),
          _PeriodCard(time: '1:20–2:10', subject: 'Lunch Break', teacher: '', room: '', type: 'break'),
          _PeriodCard(time: '2:10–4:00', subject: 'Pharmaceutics Lab', teacher: 'Dr. Ravi Kumar', room: 'Lab 1', type: 'Practical'),
        ])),
      ]),
    );
  }
}
class _PeriodCard extends StatelessWidget {
  final String time, subject, teacher, room, type;
  const _PeriodCard({required this.time, required this.subject, required this.teacher, required this.room, required this.type});
  @override Widget build(BuildContext context) {
    final isBreak = type == 'break';
    final isPrac = type == 'Practical';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isBreak ? AppColors.surface : isPrac ? const Color(0xFFDCFCE7) : const Color(0xFFE0EAF6),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: isBreak ? AppColors.border : isPrac ? AppColors.success : AppColors.primary, width: 3)),
      ),
      child: Row(children: [
        SizedBox(width: 70, child: Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textHint))),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(subject, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
            color: isBreak ? AppColors.textHint : isPrac ? const Color(0xFF166534) : AppColors.primary)),
          if (!isBreak) Text('$teacher · $room', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared badge widget
class _Badge extends StatelessWidget {
  final String label; final Color color, textColor;
  const _Badge({required this.label, required this.color, required this.textColor});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textColor)),
  );
}
