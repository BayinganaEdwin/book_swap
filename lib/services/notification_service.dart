import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type, // 'swap_accepted', 'swap_declined', 'swap_request'
    String? swapId,
    String? bookId,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'swapId': swapId,
      'bookId': bookId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream of notifications for a user
  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      try {
        final notifications = snap.docs.map((d) {
          final data = d.data();
          return {
            'id': d.id,
            ...data,
          };
        }).toList();
        
        // Sort by createdAt descending (client-side to avoid index requirement)
        notifications.sort((a, b) {
          final aTime = a['createdAt'];
          final bTime = b['createdAt'];
          
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime); // Descending
          }
          
          return 0;
        });
        
        return notifications;
      } catch (e) {
        return <Map<String, dynamic>>[];
      }
    });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();
    
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).delete();
  }

  // Delete all notifications
  Future<void> deleteAllNotifications(String userId) async {
    final snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();
    
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Get unread count
  Stream<int> streamUnreadCount(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // Save notification preferences
  Future<void> saveNotificationPreferences(String userId, bool enablePopups) async {
    await _db.collection('users').doc(userId).update({
      'notificationPopupsEnabled': enablePopups,
    });
  }

  // Get notification preferences
  Future<bool> getNotificationPreferences(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data()?['notificationPopupsEnabled'] ?? true; // Default to enabled
  }

  // Stream notification preferences
  Stream<bool> streamNotificationPreferences(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['notificationPopupsEnabled'] ?? true);
  }
}

