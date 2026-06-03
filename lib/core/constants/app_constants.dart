// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'JIT Connect';
  static const String collegeName = 'Jahangirabad Institute of Technology';
  static const String collegeShort = 'JIT';

  // Timing
  static const String classStartTime = '09:10';
  static const String lunchStart = '13:20';
  static const String lunchEnd = '14:10';
  static const int periodDurationMinutes = 50;
  static const int attendanceOpenBeforeMinutes = 15;
  static const int attendanceCloseAfterMinutes = 30;
  static const int defaultReminderMinutes = 10;

  // Attendance
  static const double minAttendancePct = 75.0;
  static const int attendanceEditWindowMinutes = 30;

  // Working Days
  static const List<String> workingDays = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'
  ];

  // Courses
  static const List<Map<String, dynamic>> allCourses = [
    // B.Pharm
    {'id': 'bpharm_sem1', 'name': 'B.Pharm Sem 1', 'program': 'B.Pharm', 'semYear': 'Sem 1'},
    {'id': 'bpharm_sem2', 'name': 'B.Pharm Sem 2', 'program': 'B.Pharm', 'semYear': 'Sem 2'},
    {'id': 'bpharm_sem3', 'name': 'B.Pharm Sem 3', 'program': 'B.Pharm', 'semYear': 'Sem 3'},
    {'id': 'bpharm_sem4', 'name': 'B.Pharm Sem 4', 'program': 'B.Pharm', 'semYear': 'Sem 4'},
    {'id': 'bpharm_sem5', 'name': 'B.Pharm Sem 5', 'program': 'B.Pharm', 'semYear': 'Sem 5'},
    {'id': 'bpharm_sem6', 'name': 'B.Pharm Sem 6', 'program': 'B.Pharm', 'semYear': 'Sem 6'},
    {'id': 'bpharm_sem7', 'name': 'B.Pharm Sem 7', 'program': 'B.Pharm', 'semYear': 'Sem 7'},
    {'id': 'bpharm_sem8', 'name': 'B.Pharm Sem 8', 'program': 'B.Pharm', 'semYear': 'Sem 8'},
    // D.Pharm
    {'id': 'dpharm_year1', 'name': 'D.Pharm Year 1', 'program': 'D.Pharm', 'semYear': 'Year 1'},
    {'id': 'dpharm_year2', 'name': 'D.Pharm Year 2', 'program': 'D.Pharm', 'semYear': 'Year 2'},
    // M.Pharm Pharmacology
    {'id': 'mpharm_phcol_sem1', 'name': 'M.Pharm (Pharmacology) Sem 1', 'program': 'M.Pharm', 'specialization': 'Pharmacology', 'semYear': 'Sem 1'},
    {'id': 'mpharm_phcol_sem2', 'name': 'M.Pharm (Pharmacology) Sem 2', 'program': 'M.Pharm', 'specialization': 'Pharmacology', 'semYear': 'Sem 2'},
    {'id': 'mpharm_phcol_sem3', 'name': 'M.Pharm (Pharmacology) Sem 3', 'program': 'M.Pharm', 'specialization': 'Pharmacology', 'semYear': 'Sem 3'},
    {'id': 'mpharm_phcol_sem4', 'name': 'M.Pharm (Pharmacology) Sem 4', 'program': 'M.Pharm', 'specialization': 'Pharmacology', 'semYear': 'Sem 4'},
    // M.Pharm Pharmaceutics
    {'id': 'mpharm_phceu_sem1', 'name': 'M.Pharm (Pharmaceutics) Sem 1', 'program': 'M.Pharm', 'specialization': 'Pharmaceutics', 'semYear': 'Sem 1'},
    {'id': 'mpharm_phceu_sem2', 'name': 'M.Pharm (Pharmaceutics) Sem 2', 'program': 'M.Pharm', 'specialization': 'Pharmaceutics', 'semYear': 'Sem 2'},
    {'id': 'mpharm_phceu_sem3', 'name': 'M.Pharm (Pharmaceutics) Sem 3', 'program': 'M.Pharm', 'specialization': 'Pharmaceutics', 'semYear': 'Sem 3'},
    {'id': 'mpharm_phceu_sem4', 'name': 'M.Pharm (Pharmaceutics) Sem 4', 'program': 'M.Pharm', 'specialization': 'Pharmaceutics', 'semYear': 'Sem 4'},
    // M.Pharm Pharmaceutical Chemistry
    {'id': 'mpharm_phche_sem1', 'name': 'M.Pharm (Pharmaceutical Chemistry) Sem 1', 'program': 'M.Pharm', 'specialization': 'Pharmaceutical Chemistry', 'semYear': 'Sem 1'},
    {'id': 'mpharm_phche_sem2', 'name': 'M.Pharm (Pharmaceutical Chemistry) Sem 2', 'program': 'M.Pharm', 'specialization': 'Pharmaceutical Chemistry', 'semYear': 'Sem 2'},
    {'id': 'mpharm_phche_sem3', 'name': 'M.Pharm (Pharmaceutical Chemistry) Sem 3', 'program': 'M.Pharm', 'specialization': 'Pharmaceutical Chemistry', 'semYear': 'Sem 3'},
    {'id': 'mpharm_phche_sem4', 'name': 'M.Pharm (Pharmaceutical Chemistry) Sem 4', 'program': 'M.Pharm', 'specialization': 'Pharmaceutical Chemistry', 'semYear': 'Sem 4'},
    // Pharm.D
    {'id': 'pharmd_year1', 'name': 'Pharm.D Year 1', 'program': 'Pharm.D', 'semYear': 'Year 1'},
    {'id': 'pharmd_year2', 'name': 'Pharm.D Year 2', 'program': 'Pharm.D', 'semYear': 'Year 2'},
    {'id': 'pharmd_year3', 'name': 'Pharm.D Year 3', 'program': 'Pharm.D', 'semYear': 'Year 3'},
    {'id': 'pharmd_year4', 'name': 'Pharm.D Year 4', 'program': 'Pharm.D', 'semYear': 'Year 4'},
    {'id': 'pharmd_year5', 'name': 'Pharm.D Year 5', 'program': 'Pharm.D', 'semYear': 'Year 5'},
    {'id': 'pharmd_year6', 'name': 'Pharm.D Year 6', 'program': 'Pharm.D', 'semYear': 'Year 6'},
  ];

  // Firestore Collections
  static const String colUsers = 'users';
  static const String colCourses = 'courses';
  static const String colSubjects = 'subjects';
  static const String colStudents = 'students';
  static const String colTeachers = 'teachers';
  static const String colTimetable = 'timetable';
  static const String colAttendance = 'attendance';
  static const String colAttRecords = 'records';
  static const String colExtraClasses = 'extra_classes';
  static const String colNotifications = 'notifications';
}
