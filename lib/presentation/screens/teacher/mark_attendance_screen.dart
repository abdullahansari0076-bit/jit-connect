// lib/presentation/screens/teacher/mark_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/app_models.dart';
import '../../../data/repositories/attendance_repository.dart';

final _sessionProvider = StreamProvider.family<AttendanceSession?, String>((ref, sessionId) {
  return ref.watch(attendanceRepositoryProvider).getSessionRecords(sessionId).map((_) => null);
});

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const MarkAttendanceScreen({super.key, required this.sessionId});

  @override
  ConsumerState<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  List<Student> _students = [];
  Map<String, AttendanceMark> _marks = {};
  bool _loading = true;
  bool _submitting = false;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    // In production, get courseId from sessionId → session doc → courseId
    // For now, load via session
    setState(() => _loading = false);
  }

  Future<void> _loadStudentsForCourse(String courseId) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final students = await repo.getStudentsForCourse(courseId);
    setState(() {
      _students = students;
      // Default all present
      _marks = {for (final s in students) s.studentId: AttendanceMark.present};
      _loading = false;
    });
  }

  void _setMark(String studentId, AttendanceMark mark) {
    setState(() => _marks[studentId] = mark);
    // Save in real-time
    ref.read(attendanceRepositoryProvider).markStudent(
      sessionId: widget.sessionId,
      studentId: studentId,
      mark: mark,
    );
  }

  Future<void> _submit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Submit attendance?'),
        content: Text(
          'Present: ${_count(AttendanceMark.present)}  '
          'Absent: ${_count(AttendanceMark.absent)}  '
          'Late: ${_count(AttendanceMark.late)}\n\n'
          'You have 30 minutes to request corrections after submission.',
        ),
        actions: [
          TextButton(onPressed: () => c.pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => c.pop(true),
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      await ref.read(attendanceRepositoryProvider).submitSession(widget.sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance submitted successfully!'),
            backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  int _count(AttendanceMark mark) => _marks.values.where((m) => m == mark).length;

  List<Student> get _filteredStudents {
    if (_filter == 'all') return _students;
    final mark = AttendanceMark.values.firstWhere((m) => m.name == _filter);
    return _students.where((s) => _marks[s.studentId] == mark).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 8, right: 8, bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text('Mark Attendance',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.primaryAccent),
                    onPressed: () {},
                  ),
                ]),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Physical Pharmacy · Theory',
                        style: TextStyle(color: AppColors.primaryAccent, fontSize: 11)),
                      Text('B.Pharm Semester 3',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('10:50 AM – 11:40 AM · Room 305',
                        style: TextStyle(color: AppColors.primaryAccent, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _FilterChip(label: 'All (${_students.length})', value: 'all', current: _filter, onTap: (v) => setState(() => _filter = v)),
                const SizedBox(width: 6),
                _FilterChip(label: 'P (${_count(AttendanceMark.present)})', value: 'present', current: _filter, onTap: (v) => setState(() => _filter = v)),
                const SizedBox(width: 6),
                _FilterChip(label: 'A (${_count(AttendanceMark.absent)})', value: 'absent', current: _filter, onTap: (v) => setState(() => _filter = v)),
                const SizedBox(width: 6),
                _FilterChip(label: 'L (${_count(AttendanceMark.late)})', value: 'late', current: _filter, onTap: (v) => setState(() => _filter = v)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    _marks = {for (final s in _students) s.studentId: AttendanceMark.present};
                  }),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('All P', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),

          const Divider(height: 0),

          // Student list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(child: Text('No students found', style: TextStyle(color: AppColors.textHint)))
                    : ListView.separated(
                        itemCount: _filteredStudents.length,
                        separatorBuilder: (_, __) => const Divider(height: 0, indent: 12, endIndent: 12),
                        itemBuilder: (_, i) {
                          final student = _filteredStudents[i];
                          final mark = _marks[student.studentId] ?? AttendanceMark.absent;
                          return _StudentRow(
                            student: student,
                            mark: mark,
                            onMark: (m) => _setMark(student.studentId, m),
                          );
                        },
                      ),
          ),

          // Submit bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryTag(label: 'Present', count: _count(AttendanceMark.present), color: AppColors.success),
                    _SummaryTag(label: 'Absent', count: _count(AttendanceMark.absent), color: AppColors.danger),
                    _SummaryTag(label: 'Late', count: _count(AttendanceMark.late), color: AppColors.lateColor),
                    _SummaryTag(label: 'Total', count: _students.length, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Attendance'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final Student student;
  final AttendanceMark mark;
  final void Function(AttendanceMark) onMark;
  const _StudentRow({required this.student, required this.mark, required this.onMark});

  String get _initials {
    final parts = student.name.split(' ');
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.infoLight, shape: BoxShape.circle),
          child: Center(child: Text(_initials,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.info))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(student.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(student.rollNumber, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
        ])),
        Row(children: [
          _MarkBtn(label: 'P', selected: mark == AttendanceMark.present,
            color: AppColors.success, lightColor: AppColors.successLight,
            onTap: () => onMark(AttendanceMark.present)),
          const SizedBox(width: 4),
          _MarkBtn(label: 'A', selected: mark == AttendanceMark.absent,
            color: AppColors.danger, lightColor: AppColors.dangerLight,
            onTap: () => onMark(AttendanceMark.absent)),
          const SizedBox(width: 4),
          _MarkBtn(label: 'L', selected: mark == AttendanceMark.late,
            color: AppColors.lateColor, lightColor: AppColors.warningLight,
            onTap: () => onMark(AttendanceMark.late)),
        ]),
      ]),
    );
  }
}

class _MarkBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color, lightColor;
  final VoidCallback onTap;
  const _MarkBtn({required this.label, required this.selected, required this.color, required this.lightColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: selected ? lightColor : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? color : AppColors.border, width: 1.5),
        ),
        child: Center(child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
            color: selected ? color : AppColors.textSecondary))),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, value, current;
  final void Function(String) onTap;
  const _FilterChip({required this.label, required this.value, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOn = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isOn ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isOn ? AppColors.primary : AppColors.border, width: 0.5),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: isOn ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _SummaryTag extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryTag({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    ]);
  }
}
