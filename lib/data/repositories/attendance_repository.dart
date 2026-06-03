// lib/data/repositories/attendance_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../../core/constants/app_constants.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) => AttendanceRepository());

class AttendanceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Teacher: get today's sessions ──────────────────────────────────────────
  Stream<List<AttendanceSession>> getTodaySessions(String teacherId) {
    final today = _dateStr(DateTime.now());
    return _db.collection(AppConstants.colAttendance)
        .where('teacherId', isEqualTo: teacherId)
        .where('date', isEqualTo: today)
        .orderBy('date')
        .snapshots()
        .map((s) => s.docs.map((d) => AttendanceSession.fromFirestore(d)).toList());
  }

  // ── Create a session when teacher opens attendance ─────────────────────────
  Future<AttendanceSession> createSession({
    required String slotId,
    required String subjectId,
    required String teacherId,
    required String courseId,
    bool isExtraClass = false,
    String? extraClassId,
  }) async {
    final today = _dateStr(DateTime.now());
    // Check if session already exists
    final existing = await _db.collection(AppConstants.colAttendance)
        .where('slotId', isEqualTo: slotId)
        .where('date', isEqualTo: today)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return AttendanceSession.fromFirestore(existing.docs.first);
    }
    final session = AttendanceSession(
      sessionId: '',
      slotId: slotId,
      subjectId: subjectId,
      teacherId: teacherId,
      courseId: courseId,
      date: today,
      status: AttendanceStatus.open,
      isExtraClass: isExtraClass,
      extraClassId: extraClassId,
    );
    final ref = await _db.collection(AppConstants.colAttendance).add(session.toFirestore());
    final doc = await ref.get();
    return AttendanceSession.fromFirestore(doc);
  }

  // ── Fetch students for a course ────────────────────────────────────────────
  Future<List<Student>> getStudentsForCourse(String courseId) async {
    final snap = await _db.collection(AppConstants.colStudents)
        .where('courseId', isEqualTo: courseId)
        .where('isActive', isEqualTo: true)
        .orderBy('rollNumber')
        .get();
    return snap.docs.map((d) => Student.fromFirestore(d)).toList();
  }

  // ── Save individual mark (real-time as teacher taps) ───────────────────────
  Future<void> markStudent({
    required String sessionId,
    required String studentId,
    required AttendanceMark mark,
  }) async {
    await _db
        .collection(AppConstants.colAttendance)
        .doc(sessionId)
        .collection(AppConstants.colAttRecords)
        .doc(studentId)
        .set(AttendanceRecord(
          studentId: studentId,
          mark: mark,
          markedAt: DateTime.now(),
        ).toFirestore());
  }

  // ── Fetch current marks for a session ─────────────────────────────────────
  Stream<List<AttendanceRecord>> getSessionRecords(String sessionId) {
    return _db
        .collection(AppConstants.colAttendance)
        .doc(sessionId)
        .collection(AppConstants.colAttRecords)
        .snapshots()
        .map((s) => s.docs.map((d) => AttendanceRecord.fromFirestore(d)).toList());
  }

  // ── Submit (lock) a session ────────────────────────────────────────────────
  Future<void> submitSession(String sessionId) async {
    await _db.collection(AppConstants.colAttendance).doc(sessionId).update({
      'status': AttendanceStatus.submitted.name,
      'submittedAt': Timestamp.fromDate(DateTime.now()),
    });
    // Cloud Function 'onAttendanceSubmit' handles updating attendanceSummary
  }

  // ── Correction request (within 30 min window) ─────────────────────────────
  Future<void> requestCorrection({
    required String sessionId,
    required String reason,
  }) async {
    await _db.collection(AppConstants.colAttendance).doc(sessionId).update({
      'correctionRequested': true,
      'correctionReason': reason,
      'correctionRequestedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ── Student: get attendance summary (from denormalized field) ─────────────
  Stream<Student> getStudentAttendance(String studentId) {
    return _db.collection(AppConstants.colStudents).doc(studentId)
        .snapshots()
        .map((d) => Student.fromFirestore(d));
  }

  // ── HOD: get all sessions for a course on a date range ────────────────────
  Future<List<AttendanceSession>> getSessionsForReport({
    required String courseId,
    required String fromDate,
    required String toDate,
  }) async {
    final snap = await _db.collection(AppConstants.colAttendance)
        .where('courseId', isEqualTo: courseId)
        .where('date', isGreaterThanOrEqualTo: fromDate)
        .where('date', isLessThanOrEqualTo: toDate)
        .orderBy('date')
        .get();
    return snap.docs.map((d) => AttendanceSession.fromFirestore(d)).toList();
  }

  // ── Get defaulters (students below threshold) ──────────────────────────────
  Future<List<Student>> getDefaulters({double threshold = 75.0}) async {
    final snap = await _db.collection(AppConstants.colStudents)
        .where('isActive', isEqualTo: true)
        .get();
    final students = snap.docs.map((d) => Student.fromFirestore(d)).toList();
    return students.where((s) => s.overallAttendancePct < threshold).toList();
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
