// lib/data/models/app_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// ─── USER ───────────────────────────────────────────────────────────────────
enum UserRole { hod, teacher, student }

class AppUser {
  final String uid;
  final UserRole role;
  final String name;
  final String employeeId;
  final String email;
  final String phone;
  final String? fcmToken;
  final bool isActive;
  final bool mustChangePassword;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.role,
    required this.name,
    required this.employeeId,
    required this.email,
    required this.phone,
    this.fcmToken,
    this.isActive = true,
    this.mustChangePassword = true,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      role: UserRole.values.firstWhere((r) => r.name == d['role'], orElse: () => UserRole.student),
      name: d['name'] ?? '',
      employeeId: d['employeeId'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      fcmToken: d['fcmToken'],
      isActive: d['isActive'] ?? true,
      mustChangePassword: d['mustChangePassword'] ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'role': role.name,
    'name': name,
    'employeeId': employeeId,
    'email': email,
    'phone': phone,
    'fcmToken': fcmToken,
    'isActive': isActive,
    'mustChangePassword': mustChangePassword,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

// ─── COURSE ──────────────────────────────────────────────────────────────────
class Course {
  final String courseId;
  final String name;
  final String program;
  final String? specialization;
  final String semesterOrYear;
  final double minAttendancePct;
  final String academicYear;
  final bool isActive;
  final int totalStudents;

  Course({
    required this.courseId,
    required this.name,
    required this.program,
    this.specialization,
    required this.semesterOrYear,
    this.minAttendancePct = 75.0,
    required this.academicYear,
    this.isActive = true,
    this.totalStudents = 0,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Course(
      courseId: doc.id,
      name: d['name'] ?? '',
      program: d['program'] ?? '',
      specialization: d['specialization'],
      semesterOrYear: d['semesterOrYear'] ?? '',
      minAttendancePct: (d['minAttendancePct'] ?? 75).toDouble(),
      academicYear: d['academicYear'] ?? '2025-26',
      isActive: d['isActive'] ?? true,
      totalStudents: d['totalStudents'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'program': program,
    'specialization': specialization,
    'semesterOrYear': semesterOrYear,
    'minAttendancePct': minAttendancePct,
    'academicYear': academicYear,
    'isActive': isActive,
    'totalStudents': totalStudents,
  };
}

// ─── SUBJECT ─────────────────────────────────────────────────────────────────
enum SubjectType { theory, practical, tutorial }

class Subject {
  final String subjectId;
  final String name;
  final String courseId;
  final String teacherId;
  final SubjectType type;
  final int periodsPerWeek;
  final double minAttendancePct;
  final bool isActive;

  Subject({
    required this.subjectId,
    required this.name,
    required this.courseId,
    required this.teacherId,
    required this.type,
    required this.periodsPerWeek,
    this.minAttendancePct = 75.0,
    this.isActive = true,
  });

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Subject(
      subjectId: doc.id,
      name: d['name'] ?? '',
      courseId: d['courseId'] ?? '',
      teacherId: d['teacherId'] ?? '',
      type: SubjectType.values.firstWhere((t) => t.name == d['type'], orElse: () => SubjectType.theory),
      periodsPerWeek: d['periodsPerWeek'] ?? 2,
      minAttendancePct: (d['minAttendancePct'] ?? 75).toDouble(),
      isActive: d['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'courseId': courseId,
    'teacherId': teacherId,
    'type': type.name,
    'periodsPerWeek': periodsPerWeek,
    'minAttendancePct': minAttendancePct,
    'isActive': isActive,
  };
}

// ─── STUDENT ─────────────────────────────────────────────────────────────────
class Student {
  final String studentId;
  final String enrollmentNo;
  final String name;
  final String courseId;
  final String rollNumber;
  final String dob;
  final String phone;
  final String email;
  final Map<String, AttendanceSummary> attendanceSummary;
  final bool isActive;
  final DateTime createdAt;

  Student({
    required this.studentId,
    required this.enrollmentNo,
    required this.name,
    required this.courseId,
    required this.rollNumber,
    required this.dob,
    required this.phone,
    required this.email,
    this.attendanceSummary = const {},
    this.isActive = true,
    required this.createdAt,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final summaryRaw = d['attendanceSummary'] as Map<String, dynamic>? ?? {};
    return Student(
      studentId: doc.id,
      enrollmentNo: d['enrollmentNo'] ?? '',
      name: d['name'] ?? '',
      courseId: d['courseId'] ?? '',
      rollNumber: d['rollNumber'] ?? '',
      dob: d['dob'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
      attendanceSummary: summaryRaw.map(
        (k, v) => MapEntry(k, AttendanceSummary.fromMap(v as Map<String, dynamic>)),
      ),
      isActive: d['isActive'] ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'enrollmentNo': enrollmentNo,
    'name': name,
    'courseId': courseId,
    'rollNumber': rollNumber,
    'dob': dob,
    'phone': phone,
    'email': email,
    'attendanceSummary': attendanceSummary.map((k, v) => MapEntry(k, v.toMap())),
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  double get overallAttendancePct {
    if (attendanceSummary.isEmpty) return 0;
    final total = attendanceSummary.values.fold(0, (s, a) => s + a.held);
    final attended = attendanceSummary.values.fold(0, (s, a) => s + a.attended);
    if (total == 0) return 0;
    return (attended / total) * 100;
  }
}

class AttendanceSummary {
  final int held;
  final int attended;
  final double pct;

  AttendanceSummary({required this.held, required this.attended, required this.pct});

  factory AttendanceSummary.fromMap(Map<String, dynamic> m) => AttendanceSummary(
    held: m['held'] ?? 0,
    attended: m['attended'] ?? 0,
    pct: (m['pct'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toMap() => {'held': held, 'attended': attended, 'pct': pct};

  int get classesNeededFor75 {
    if (pct >= 75) return 0;
    // Formula: (attended + x) / (held + x) >= 0.75
    if (held == 0) return 0;
    final needed = ((0.75 * held) - attended) / 0.25;
    return needed.ceil().clamp(0, 999);
  }
}

// ─── TEACHER ─────────────────────────────────────────────────────────────────
class Teacher {
  final String teacherId;
  final String employeeId;
  final String name;
  final String department;
  final String phone;
  final String email;
  final List<String> subjectIds;
  final List<String> courseIds;
  final int reminderMinutes;
  final bool isActive;

  Teacher({
    required this.teacherId,
    required this.employeeId,
    required this.name,
    required this.department,
    required this.phone,
    required this.email,
    this.subjectIds = const [],
    this.courseIds = const [],
    this.reminderMinutes = 10,
    this.isActive = true,
  });

  factory Teacher.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Teacher(
      teacherId: doc.id,
      employeeId: d['employeeId'] ?? '',
      name: d['name'] ?? '',
      department: d['department'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
      subjectIds: List<String>.from(d['subjectIds'] ?? []),
      courseIds: List<String>.from(d['courseIds'] ?? []),
      reminderMinutes: d['reminderMinutes'] ?? 10,
      isActive: d['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'employeeId': employeeId,
    'name': name,
    'department': department,
    'phone': phone,
    'email': email,
    'subjectIds': subjectIds,
    'courseIds': courseIds,
    'reminderMinutes': reminderMinutes,
    'isActive': isActive,
  };
}

// ─── TIMETABLE SLOT ──────────────────────────────────────────────────────────
class TimetableSlot {
  final String slotId;
  final String courseId;
  final String subjectId;
  final String teacherId;
  final String dayOfWeek;
  final int periodNumber;
  final String startTime;
  final String endTime;
  final String room;
  final bool isBreak;
  final String? uploadedImageUrl;
  final DateTime effectiveFrom;

  TimetableSlot({
    required this.slotId,
    required this.courseId,
    required this.subjectId,
    required this.teacherId,
    required this.dayOfWeek,
    required this.periodNumber,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.isBreak = false,
    this.uploadedImageUrl,
    required this.effectiveFrom,
  });

  factory TimetableSlot.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TimetableSlot(
      slotId: doc.id,
      courseId: d['courseId'] ?? '',
      subjectId: d['subjectId'] ?? '',
      teacherId: d['teacherId'] ?? '',
      dayOfWeek: d['dayOfWeek'] ?? '',
      periodNumber: d['periodNumber'] ?? 1,
      startTime: d['startTime'] ?? '',
      endTime: d['endTime'] ?? '',
      room: d['room'] ?? '',
      isBreak: d['isBreak'] ?? false,
      uploadedImageUrl: d['uploadedImageUrl'],
      effectiveFrom: (d['effectiveFrom'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'courseId': courseId,
    'subjectId': subjectId,
    'teacherId': teacherId,
    'dayOfWeek': dayOfWeek,
    'periodNumber': periodNumber,
    'startTime': startTime,
    'endTime': endTime,
    'room': room,
    'isBreak': isBreak,
    'uploadedImageUrl': uploadedImageUrl,
    'effectiveFrom': Timestamp.fromDate(effectiveFrom),
  };

  bool get isAttendanceWindowOpen {
    final now = DateTime.now();
    final start = _parseTime(startTime).subtract(Duration(minutes: 15));
    final end = _parseTime(endTime).add(Duration(minutes: 30));
    return now.isAfter(start) && now.isBefore(end);
  }

  DateTime _parseTime(String t) {
    final parts = t.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }
}

// ─── ATTENDANCE SESSION ───────────────────────────────────────────────────────
enum AttendanceStatus { open, submitted, locked }

class AttendanceSession {
  final String sessionId;
  final String slotId;
  final String subjectId;
  final String teacherId;
  final String courseId;
  final String date;
  final AttendanceStatus status;
  final DateTime? submittedAt;
  final bool isExtraClass;
  final String? extraClassId;

  AttendanceSession({
    required this.sessionId,
    required this.slotId,
    required this.subjectId,
    required this.teacherId,
    required this.courseId,
    required this.date,
    required this.status,
    this.submittedAt,
    this.isExtraClass = false,
    this.extraClassId,
  });

  factory AttendanceSession.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AttendanceSession(
      sessionId: doc.id,
      slotId: d['slotId'] ?? '',
      subjectId: d['subjectId'] ?? '',
      teacherId: d['teacherId'] ?? '',
      courseId: d['courseId'] ?? '',
      date: d['date'] ?? '',
      status: AttendanceStatus.values.firstWhere(
        (s) => s.name == d['status'], orElse: () => AttendanceStatus.open,
      ),
      submittedAt: (d['submittedAt'] as Timestamp?)?.toDate(),
      isExtraClass: d['isExtraClass'] ?? false,
      extraClassId: d['extraClassId'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'slotId': slotId,
    'subjectId': subjectId,
    'teacherId': teacherId,
    'courseId': courseId,
    'date': date,
    'status': status.name,
    'submittedAt': submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
    'isExtraClass': isExtraClass,
    'extraClassId': extraClassId,
  };
}

// ─── ATTENDANCE RECORD (per student per session) ──────────────────────────────
enum AttendanceMark { present, absent, late }

class AttendanceRecord {
  final String studentId;
  final AttendanceMark mark;
  final DateTime markedAt;

  AttendanceRecord({
    required this.studentId,
    required this.mark,
    required this.markedAt,
  });

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      studentId: doc.id,
      mark: AttendanceMark.values.firstWhere(
        (m) => m.name == d['status'], orElse: () => AttendanceMark.absent,
      ),
      markedAt: (d['markedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'studentId': studentId,
    'status': mark.name,
    'markedAt': Timestamp.fromDate(markedAt),
  };
}

// ─── EXTRA CLASS ─────────────────────────────────────────────────────────────
enum ExtraClassType { extra, arrangement }
enum ApprovalStatus { pending, approved, rejected }

class ExtraClass {
  final String requestId;
  final ExtraClassType type;
  final String requestedBy;
  final String? originalTeacherId;
  final String subjectId;
  final String courseId;
  final String date;
  final String startTime;
  final String endTime;
  final String room;
  final String reason;
  final ApprovalStatus approvalStatus;
  final DateTime? approvedAt;
  final bool attendanceEnabled;
  final DateTime createdAt;

  ExtraClass({
    required this.requestId,
    required this.type,
    required this.requestedBy,
    this.originalTeacherId,
    required this.subjectId,
    required this.courseId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.reason,
    this.approvalStatus = ApprovalStatus.pending,
    this.approvedAt,
    this.attendanceEnabled = false,
    required this.createdAt,
  });

  factory ExtraClass.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ExtraClass(
      requestId: doc.id,
      type: ExtraClassType.values.firstWhere((t) => t.name == d['type'], orElse: () => ExtraClassType.extra),
      requestedBy: d['requestedBy'] ?? '',
      originalTeacherId: d['originalTeacherId'],
      subjectId: d['subjectId'] ?? '',
      courseId: d['courseId'] ?? '',
      date: d['date'] ?? '',
      startTime: d['startTime'] ?? '',
      endTime: d['endTime'] ?? '',
      room: d['room'] ?? '',
      reason: d['reason'] ?? '',
      approvalStatus: ApprovalStatus.values.firstWhere(
        (s) => s.name == d['approvalStatus'], orElse: () => ApprovalStatus.pending,
      ),
      approvedAt: (d['approvedAt'] as Timestamp?)?.toDate(),
      attendanceEnabled: d['attendanceEnabled'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'type': type.name,
    'requestedBy': requestedBy,
    'originalTeacherId': originalTeacherId,
    'subjectId': subjectId,
    'courseId': courseId,
    'date': date,
    'startTime': startTime,
    'endTime': endTime,
    'room': room,
    'reason': reason,
    'approvalStatus': approvalStatus.name,
    'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    'attendanceEnabled': attendanceEnabled,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

// ─── NOTIFICATION ─────────────────────────────────────────────────────────────
enum NotificationType {
  classReminder, lowAttendance, arrangementRequest, approval, broadcast, timetableChange
}

class AppNotification {
  final String notifId;
  final String recipientId;
  final String recipientRole;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.notifId,
    required this.recipientId,
    required this.recipientRole,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppNotification(
      notifId: doc.id,
      recipientId: d['recipientId'] ?? '',
      recipientRole: d['recipientRole'] ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == d['type'], orElse: () => NotificationType.broadcast,
      ),
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      data: Map<String, dynamic>.from(d['data'] ?? {}),
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'recipientId': recipientId,
    'recipientRole': recipientRole,
    'type': type.name,
    'title': title,
    'body': body,
    'data': data,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
