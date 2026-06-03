// functions/index.js
// Firebase Cloud Functions for JIT Connect
// Deploy: firebase deploy --only functions

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 1: onAttendanceSubmit
// Triggers when a teacher submits an attendance session (status → "submitted")
// Recalculates each student's attendanceSummary map in /students/{id}
// ─────────────────────────────────────────────────────────────────────────────
exports.onAttendanceSubmit = functions.firestore
  .document('attendance/{sessionId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger when status changes to "submitted"
    if (before.status === after.status || after.status !== 'submitted') return null;

    const sessionId = context.params.sessionId;
    const subjectId = after.subjectId;

    // Get all attendance records for this session
    const recordsSnap = await db
      .collection('attendance')
      .doc(sessionId)
      .collection('records')
      .get();

    const batch = db.batch();

    for (const recordDoc of recordsSnap.docs) {
      const record = recordDoc.data();
      const studentId = record.studentId;
      const isPresent = record.status === 'present' || record.status === 'late';

      const studentRef = db.collection('students').doc(studentId);

      // Increment held count always, attended only if present/late
      batch.update(studentRef, {
        [`attendanceSummary.${subjectId}.held`]: admin.firestore.FieldValue.increment(1),
        [`attendanceSummary.${subjectId}.attended`]: admin.firestore.FieldValue.increment(isPresent ? 1 : 0),
      });
    }

    await batch.commit();

    // Recalculate percentages for all affected students
    for (const recordDoc of recordsSnap.docs) {
      const studentId = recordDoc.data().studentId;
      const studentRef = db.collection('students').doc(studentId);
      const studentDoc = await studentRef.get();
      const summary = studentDoc.data().attendanceSummary || {};

      // Recalculate pct for this subject
      const subjectSummary = summary[subjectId] || { held: 0, attended: 0 };
      const pct = subjectSummary.held > 0
        ? (subjectSummary.attended / subjectSummary.held) * 100
        : 0;

      await studentRef.update({
        [`attendanceSummary.${subjectId}.pct`]: Math.round(pct * 10) / 10,
      });

      // Check if below 75% and send alert
      if (pct < 75) {
        await _sendLowAttendanceAlert(studentId, subjectId, pct);
      }
    }

    return null;
  });

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 2: scheduleClassReminders
// Runs every 5 minutes — checks timetable and sends FCM push to teachers
// whose class starts within their reminderMinutes window
// ─────────────────────────────────────────────────────────────────────────────
exports.scheduleClassReminders = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async () => {
    const now = new Date();
    const dayNames = ['sunday','monday','tuesday','wednesday','thursday','friday','saturday'];
    const todayDay = dayNames[now.getDay()];

    // Skip Sunday
    if (todayDay === 'sunday') return null;

    // Get all timetable slots for today
    const slotsSnap = await db.collection('timetable')
      .where('dayOfWeek', '==', todayDay)
      .where('isBreak', '==', false)
      .get();

    for (const slotDoc of slotsSnap.docs) {
      const slot = slotDoc.data();
      const teacherId = slot.teacherId;

      // Get teacher's reminder preference
      const teacherDoc = await db.collection('teachers').doc(teacherId).get();
      if (!teacherDoc.exists) continue;
      const teacher = teacherDoc.data();
      const reminderMinutes = teacher.reminderMinutes || 10;

      // Parse slot start time
      const [hours, minutes] = slot.startTime.split(':').map(Number);
      const classTime = new Date(now);
      classTime.setHours(hours, minutes, 0, 0);

      // Check if we're in the reminder window (within ±2.5 min of reminder time)
      const reminderTime = new Date(classTime.getTime() - reminderMinutes * 60 * 1000);
      const diffMs = Math.abs(now.getTime() - reminderTime.getTime());
      if (diffMs > 2.5 * 60 * 1000) continue; // not in window

      // Check not already sent today
      const alreadySent = await db.collection('reminder_log')
        .where('slotId', '==', slotDoc.id)
        .where('date', '==', _dateStr(now))
        .limit(1)
        .get();
      if (!alreadySent.empty) continue;

      // Send FCM push to teacher
      const userDoc = await db.collection('users').doc(teacherId).get();
      const fcmToken = userDoc.data()?.fcmToken;
      if (!fcmToken) continue;

      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: `Class starting in ${reminderMinutes} min`,
          body: `${slot.subjectId} · ${slot.room}`,
        },
        data: {
          type: 'class_reminder',
          slotId: slotDoc.id,
          subjectId: slot.subjectId,
          courseId: slot.courseId,
        },
        android: { priority: 'high', notification: { sound: 'class_bell', channelId: 'class_reminders' } },
        apns: { payload: { aps: { sound: 'class_bell.aiff', badge: 1 } } },
      });

      // Save notification to Firestore
      await db.collection('notifications').add({
        recipientId: teacherId,
        recipientRole: 'teacher',
        type: 'classReminder',
        title: `Class starting in ${reminderMinutes} min`,
        body: `${slot.subjectId} · ${slot.room}`,
        data: { slotId: slotDoc.id, subjectId: slot.subjectId },
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Log reminder sent
      await db.collection('reminder_log').add({
        slotId: slotDoc.id,
        teacherId,
        date: _dateStr(now),
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return null;
  });

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 3: onExtraClassApproved
// Triggers when originalTeacher/HOD approves an arrangement request
// Sets attendanceEnabled=true and notifies the requesting teacher
// ─────────────────────────────────────────────────────────────────────────────
exports.onExtraClassApproved = functions.firestore
  .document('extra_classes/{requestId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.approvalStatus === after.approvalStatus) return null;

    const requestingTeacherId = after.requestedBy;

    // Get requesting teacher's FCM token
    const userDoc = await db.collection('users').doc(requestingTeacherId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (after.approvalStatus === 'approved') {
      // Enable attendance marking
      await change.after.ref.update({ attendanceEnabled: true });

      // Notify requesting teacher
      const notifData = {
        recipientId: requestingTeacherId,
        recipientRole: 'teacher',
        type: 'approval',
        title: 'Arrangement class approved',
        body: `Your request for ${after.subjectId} on ${after.date} has been approved. You can now mark attendance.`,
        data: { extraClassId: context.params.requestId },
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      await db.collection('notifications').add(notifData);

      if (fcmToken) {
        await admin.messaging().send({
          token: fcmToken,
          notification: { title: notifData.title, body: notifData.body },
          data: { type: 'approval', extraClassId: context.params.requestId },
        });
      }

    } else if (after.approvalStatus === 'rejected') {
      // Notify rejection
      const notifData = {
        recipientId: requestingTeacherId,
        recipientRole: 'teacher',
        type: 'approval',
        title: 'Arrangement class rejected',
        body: `Your arrangement request for ${after.subjectId} on ${after.date} was not approved.`,
        data: { extraClassId: context.params.requestId },
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      await db.collection('notifications').add(notifData);

      if (fcmToken) {
        await admin.messaging().send({
          token: fcmToken,
          notification: { title: notifData.title, body: notifData.body },
        });
      }
    }

    return null;
  });

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 4: dailyDefaulterCheck
// Runs every day at 8:00 PM IST
// Finds all students below 75% and sends them a low attendance warning
// ─────────────────────────────────────────────────────────────────────────────
exports.dailyDefaulterCheck = functions.pubsub
  .schedule('0 14 * * *') // 8 PM IST = 14:00 UTC
  .timeZone('Asia/Kolkata')
  .onRun(async () => {
    const studentsSnap = await db.collection('students')
      .where('isActive', '==', true)
      .get();

    for (const studentDoc of studentsSnap.docs) {
      const student = studentDoc.data();
      const summary = student.attendanceSummary || {};

      // Calculate overall attendance
      let totalHeld = 0, totalAttended = 0;
      const lowSubjects = [];

      for (const [subjectId, s] of Object.entries(summary)) {
        totalHeld += s.held || 0;
        totalAttended += s.attended || 0;
        if ((s.pct || 0) < 75) {
          lowSubjects.push({ subjectId, pct: s.pct });
        }
      }

      const overallPct = totalHeld > 0 ? (totalAttended / totalHeld) * 100 : 100;
      if (overallPct >= 75 && lowSubjects.length === 0) continue;

      // Check if already notified today
      const today = _dateStr(new Date());
      const alreadyNotified = await db.collection('notifications')
        .where('recipientId', '==', studentDoc.id)
        .where('type', '==', 'lowAttendance')
        .orderBy('createdAt', 'desc')
        .limit(1)
        .get();

      if (!alreadyNotified.empty) {
        const lastNotif = alreadyNotified.docs[0].data();
        const lastDate = lastNotif.createdAt?.toDate();
        if (lastDate && _dateStr(lastDate) === today) continue;
      }

      const subjectList = lowSubjects.map(s => `${s.subjectId}: ${s.pct.toFixed(0)}%`).join(', ');
      const notifBody = lowSubjects.length > 0
        ? `Low attendance in: ${subjectList}. Please attend more classes to avoid shortage.`
        : `Your overall attendance is ${overallPct.toFixed(0)}%. Minimum required: 75%.`;

      // Save notification
      await db.collection('notifications').add({
        recipientId: studentDoc.id,
        recipientRole: 'student',
        type: 'lowAttendance',
        title: '⚠️ Low attendance warning',
        body: notifBody,
        data: {},
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // FCM push to student
      const userDoc = await db.collection('users').doc(studentDoc.id).get();
      const fcmToken = userDoc.data()?.fcmToken;
      if (fcmToken) {
        await admin.messaging().send({
          token: fcmToken,
          notification: { title: '⚠️ Low attendance warning', body: notifBody },
          android: { notification: { channelId: 'attendance_alerts' } },
        });
      }
    }

    return null;
  });

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 5: onStudentCreated
// Triggers when HOD adds a new student to /students
// Creates Firebase Auth account with dob as default password
// Sends credentials notification
// ─────────────────────────────────────────────────────────────────────────────
exports.onStudentCreated = functions.firestore
  .document('students/{studentId}')
  .onCreate(async (snap, context) => {
    const student = snap.data();

    // Only process if no Firebase Auth uid exists yet (bulk import case)
    // For manual adds via app, Auth account is created first
    if (!student.email || !student.dob) return null;

    try {
      // Create Firebase Auth account (dob = default password)
      const userRecord = await admin.auth().createUser({
        uid: context.params.studentId,
        email: student.email,
        password: student.dob, // DDMMYYYY format
        displayName: student.name,
      });

      // Create user document
      await db.collection('users').doc(userRecord.uid).set({
        uid: userRecord.uid,
        role: 'student',
        name: student.name,
        employeeId: student.enrollmentNo,
        email: student.email,
        phone: student.phone || '',
        isActive: true,
        mustChangePassword: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Notify HOD of successful creation
      const hodSnap = await db.collection('users').where('role', '==', 'hod').limit(1).get();
      if (!hodSnap.empty) {
        await db.collection('notifications').add({
          recipientId: hodSnap.docs[0].id,
          recipientRole: 'hod',
          type: 'broadcast',
          title: 'Student account created',
          body: `${student.name} (${student.enrollmentNo}) account created. Default password: ${student.dob}`,
          data: { studentId: context.params.studentId },
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

    } catch (error) {
      console.error('Error creating student auth account:', error);
      await snap.ref.update({ authError: error.message });
    }

    return null;
  });

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: Send low attendance alert (used by onAttendanceSubmit)
// ─────────────────────────────────────────────────────────────────────────────
async function _sendLowAttendanceAlert(studentId, subjectId, pct) {
  // Check if HOD was already alerted for this student today
  const today = _dateStr(new Date());
  const existing = await db.collection('notifications')
    .where('recipientId', '==', studentId)
    .where('type', '==', 'lowAttendance')
    .orderBy('createdAt', 'desc')
    .limit(1)
    .get();

  if (!existing.empty) {
    const lastDate = existing.docs[0].data().createdAt?.toDate();
    if (lastDate && _dateStr(lastDate) === today) return;
  }

  await db.collection('notifications').add({
    recipientId: studentId,
    recipientRole: 'student',
    type: 'lowAttendance',
    title: 'Attendance below 75%',
    body: `Your attendance in ${subjectId} is now ${pct.toFixed(0)}%. Please attend more classes.`,
    data: { subjectId },
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Also notify teacher's HOD (find HOD and notify)
  const hodSnap = await db.collection('users').where('role', '==', 'hod').limit(1).get();
  if (!hodSnap.empty) {
    const studentDoc = await db.collection('students').doc(studentId).get();
    await db.collection('notifications').add({
      recipientId: hodSnap.docs[0].id,
      recipientRole: 'hod',
      type: 'lowAttendance',
      title: 'Low attendance alert',
      body: `${studentDoc.data().name} (${studentDoc.data().rollNumber}) — ${subjectId} dropped to ${pct.toFixed(0)}%.`,
      data: { studentId, subjectId },
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
}

function _dateStr(date) {
  return `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}-${String(date.getDate()).padStart(2,'0')}`;
}
