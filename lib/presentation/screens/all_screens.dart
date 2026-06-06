// lib/presentation/screens/all_screens.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../data/models/app_models.dart';

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
              child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('
