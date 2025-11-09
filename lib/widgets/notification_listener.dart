import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';

class NotificationListenerWidget extends StatefulWidget {
  final Widget child;

  const NotificationListenerWidget({
    super.key,
    required this.child,
  });

  @override
  State<NotificationListenerWidget> createState() => _NotificationListenerWidgetState();
}

class _NotificationListenerWidgetState extends State<NotificationListenerWidget> {
  final NotificationService _notificationService = NotificationService();
  String? _lastNotificationId;
  bool _popupsEnabled = true;
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _preferencesSubscription;
  String? _currentUserId;

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _preferencesSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationListener(String userId) {
    // Listen to preferences
    _preferencesSubscription?.cancel();
    _preferencesSubscription = _notificationService
        .streamNotificationPreferences(userId)
        .listen((enabled) {
      if (mounted) {
        setState(() {
          _popupsEnabled = enabled;
        });
      }
    });

    // Listen to notifications
    _notificationSubscription?.cancel();
    _notificationSubscription = _notificationService
        .streamNotifications(userId)
        .listen((notifications) {
      if (!mounted || !_popupsEnabled) return;
      
      // Find the most recent unread notification
      final unreadNotifications = notifications.where((n) => !(n['read'] ?? false)).toList();
      if (unreadNotifications.isEmpty) return;
      
      final latestNotification = unreadNotifications.first;
      final notificationId = latestNotification['id'] as String;
      
      // Only show popup if it's a new notification
      if (notificationId != _lastNotificationId) {
        _lastNotificationId = notificationId;
        
        // Show snackbar popup
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    _getIcon(latestNotification['type'] ?? ''),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          latestNotification['title'] ?? 'Notification',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          latestNotification['message'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: _getColor(latestNotification['type'] ?? ''),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
                  // Mark as read
                  _notificationService.markAsRead(notificationId);
                  // Navigate to notifications screen
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
            ),
          );
        }
      }
    });
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'swap_accepted':
        return Icons.check_circle;
      case 'swap_declined':
        return Icons.cancel;
      case 'swap_request':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'swap_accepted':
        return Colors.green;
      case 'swap_declined':
        return Colors.red;
      case 'swap_request':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.user != null && auth.user!.uid != _currentUserId) {
          // New user logged in or user changed
          _currentUserId = auth.user!.uid;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final enabled = await _notificationService.getNotificationPreferences(_currentUserId!);
            if (mounted) {
              setState(() {
                _popupsEnabled = enabled;
              });
              _setupNotificationListener(_currentUserId!);
            }
          });
        } else if (auth.user == null && _currentUserId != null) {
          // User logged out
          _notificationSubscription?.cancel();
          _preferencesSubscription?.cancel();
          _notificationSubscription = null;
          _preferencesSubscription = null;
          _lastNotificationId = null;
          _currentUserId = null;
        }
        
        return widget.child;
      },
    );
  }
}

