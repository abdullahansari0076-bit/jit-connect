// lib/data/repositories/timetable_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../../core/constants/app_constants.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) => TimetableRepository());

class TimetableRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Get slots for a course on a specific day ───────────────────────────────
  Stream<List<TimetableSlot>> getSlotsForDay({
    required String courseId,
    required String dayOfWeek,
  }) {
    return _db.collection(AppConstants.colTimetable)
        .where('courseId', isEqualTo: courseId)
        .where('dayOfWeek', isEqualTo: dayOfWeek.toLowerCase())
        .orderBy('periodNumber')
        .snapshots()
        .map((s) => s.docs.map((d) => TimetableSlot.fromFirestore(d)).toList());
  }

  // ── Get teacher's schedule for today ──────────────────────────────────────
  Stream<List<TimetableSlot>> getTeacherSlotsForDay({
    required String teacherId,
    required String dayOfWeek,
  }) {
    return _db.collection(AppConstants.colTimetable)
        .where('teacherId', isEqualTo: teacherId)
        .where('dayOfWeek', isEqualTo: dayOfWeek.toLowerCase())
        .orderBy('periodNumber')
        .snapshots()
        .map((s) => s.docs.map((d) => TimetableSlot.fromFirestore(d)).toList());
  }

  // ── Get full week slots for a course ──────────────────────────────────────
  Future<Map<String, List<TimetableSlot>>> getWeekSlots(String courseId) async {
    final snap = await _db.collection(AppConstants.colTimetable)
        .where('courseId', isEqualTo: courseId)
        .orderBy('periodNumber')
        .get();
    final slots = snap.docs.map((d) => TimetableSlot.fromFirestore(d)).toList();
    final Map<String, List<TimetableSlot>> week = {};
    for (final day in AppConstants.workingDays) {
      week[day] = slots.where((s) => s.dayOfWeek == day).toList();
    }
    return week;
  }

  // ── Add a slot ─────────────────────────────────────────────────────────────
  Future<TimetableSlot> addSlot(TimetableSlot slot) async {
    final ref = await _db.collection(AppConstants.colTimetable).add(slot.toFirestore());
    final doc = await ref.get();
    return TimetableSlot.fromFirestore(doc);
  }

  // ── Update a slot ──────────────────────────────────────────────────────────
  Future<void> updateSlot(TimetableSlot slot) async {
    await _db.collection(AppConstants.colTimetable)
        .doc(slot.slotId)
        .update(slot.toFirestore());
  }

  // ── Delete a slot ──────────────────────────────────────────────────────────
  Future<void> deleteSlot(String slotId) async {
    await _db.collection(AppConstants.colTimetable).doc(slotId).delete();
  }

  // ── Save uploaded timetable image URL ─────────────────────────────────────
  Future<void> saveUploadedTimetable({
    required String courseId,
    required String imageUrl,
  }) async {
    // Store as a single metadata doc per course
    await _db.collection('timetable_uploads').doc(courseId).set({
      'courseId': courseId,
      'imageUrl': imageUrl,
      'uploadedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<String?> getUploadedTimetableUrl(String courseId) async {
    final doc = await _db.collection('timetable_uploads').doc(courseId).get();
    if (!doc.exists) return null;
    return (doc.data() as Map<String, dynamic>)['imageUrl'];
  }
}
