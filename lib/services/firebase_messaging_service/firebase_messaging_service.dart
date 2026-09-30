import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:belwork/firebase_options.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/services/repository/auth_repository.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_snack_bar.dart';

/// Top-level background message handler for FCM (required by Firebase)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    appLog(
      'FCM: Background message received: ${message.messageId} | Data: ${message.data}',
    );
  } catch (e) {
    errorLog('FCM: Background handler error', e);
  }
}

class FirebaseMessagingService {
  FirebaseMessagingService._privateConstructor();
  static final FirebaseMessagingService instance =
      FirebaseMessagingService._privateConstructor();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StorageServices _storage = StorageServices.instance;
  final AuthRepository _authRepo = AuthRepository.instance;

  bool _isInitialized = false;
  Map<String, dynamic>? _pendingNotificationData;

  /// Detect platform deviceType matching backend enum: ANDROID, IOS, WEB
  String get deviceType {
    if (kIsWeb) return 'WEB';
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    return 'ANDROID';
  }

  /// Check if there is any pending notification data (e.g. from terminated state launch)
  Map<String, dynamic>? get pendingNotificationData => _pendingNotificationData;

  /// Clear pending notification data once handled
  void clearPendingNotification() {
    _pendingNotificationData = null;
  }

  /// Initialize Firebase Messaging, permissions, listeners, and token sync
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Request notification permissions
      await _requestPermission();

      // 2. Set iOS foreground notification presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 4. Setup listeners for foreground, background, and terminated states
      _setupMessageListeners();

      // 5. Setup token refresh listener
      _setupTokenRefreshListener();

      // 6. Initial token fetch and sync if user is already logged in
      await syncDeviceToken();

      _isInitialized = true;
      appLog('FirebaseMessagingService initialized successfully');
    } catch (e) {
      errorLog('FirebaseMessagingService.init failed', e);
    }
  }

  /// Request notification permission across platforms
  Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    appLog(
      'FCM: Notification authorization status: ${settings.authorizationStatus}',
    );
    return settings;
  }

  /// Setup foreground and background notification listeners
  void _setupMessageListeners() {
    // A. Foreground message listener (App is open and active)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      appLog(
        'FCM [Foreground]: Received message: ${message.notification?.title} - ${message.notification?.body}',
      );
      appLog('FCM [Foreground] Data: ${message.data}');
      _handleForegroundMessage(message);
    });

    // B. Background click listener (App is in background and user clicks notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      appLog(
        'FCM [Background Click]: User opened notification: ${message.data}',
      );
      _handleNotificationClick(message);
    });

    // C. Terminated click listener (App was terminated and user clicked notification to open)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        appLog(
          'FCM [Terminated Click]: App launched from notification: ${message.data}',
        );
        _pendingNotificationData = message.data;
        _handleNotificationClick(message);
      }
    });
  }

  /// Listen for FCM token refresh events and sync immediately if logged in
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((String newToken) async {
      appLog('FCM: Token refreshed by Firebase: $newToken');
      await syncDeviceToken(newToken: newToken, force: true);
    });
  }

  /// Get current FCM Token
  Future<String?> getDeviceToken() async {
    try {
      if (Platform.isIOS) {
        // On iOS, FCM token requires APNs token to be generated first.
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          // Wait for iOS APNs registration (up to 6 retries, 1 sec each)
          for (int i = 0; i < 6; i++) {
            await Future.delayed(const Duration(seconds: 1));
            apnsToken = await _messaging.getAPNSToken();
            if (apnsToken != null) break;
          }
        }

        if (apnsToken == null) {
          appLog(
            'FCM: APNS token is not ready yet on iOS. Token will sync via onTokenRefresh when available.',
          );
          return null;
        }
      }

      final token = await _messaging.getToken();
      appLog('FCM Device Token: $token');
      return token;
    } catch (e) {
      errorLog('FirebaseMessagingService.getDeviceToken error', e);
      return null;
    }
  }

  Future<bool> syncDeviceToken({String? newToken, bool force = false}) async {
    try {
      // 1. Check if user is logged in
      final authToken = await _storage.getToken();
      if (authToken.isEmpty) {
        appLog('FCM Sync: User is not logged in. Skipping backend sync.');
        return false;
      }

      // 2. Obtain current FCM token
      final fcmToken = newToken ?? await getDeviceToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        appLog('FCM Sync: No valid FCM token available at the moment.');
        // On iOS, schedule a background retry after 4 seconds to catch APNs registration if delayed
        if (Platform.isIOS && newToken == null && force) {
          Future.delayed(const Duration(seconds: 4), () {
            syncDeviceToken();
          });
        }
        return false;
      }

      // 3. Deduplication check: skip if token has already been synced and force is false
      final lastSyncedToken = await _storage.getLastSyncedFcmToken();
      if (!force && lastSyncedToken == fcmToken) {
        appLog('FCM Sync: Token already synced to backend with latest value.');
        return true;
      }

      // 4. Send token to backend
      final isSuccess = await _authRepo.updateDeviceToken(
        token: fcmToken,
        deviceType: deviceType,
      );

      if (isSuccess) {
        await _storage.setLastSyncedFcmToken(fcmToken);
        appLog('FCM Sync: Successfully synced token to backend ($deviceType).');
        return true;
      } else {
        errorLog(
          'FCM Sync: Backend returned error when syncing device token',
          null,
        );
        return false;
      }
    } catch (e) {
      errorLog('FirebaseMessagingService.syncDeviceToken error', e);
      return false;
    }
  }

  /// Handle incoming foreground messages (shows top in-app notification banner)
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      final title =
          message.notification?.title ??
          message.data['title'] ??
          'Notification';
      final body = message.notification?.body ?? message.data['body'] ?? '';
      appLog('FCM Foreground Notification: $title - $body');

      // Show top interactive notification banner
      AppSnackBar.instance.showNotificationBanner(
        title: title,
        body: body,
        onTap: () => _handleNotificationClick(message),
      );
    } catch (e) {
      errorLog('FCM: Error displaying foreground banner', e);
    }
  }

  /// Extract Job ID from notification payload data:
  /// Handles { "jobId": "..." }, { "job_id": "..." }, or { "link": ".../user/jobs/{jobId}" }
  String? extractJobId(Map<String, dynamic> data) {
    if (data.containsKey('jobId') && data['jobId'] != null) {
      return data['jobId'].toString();
    }
    if (data.containsKey('job_id') && data['job_id'] != null) {
      return data['job_id'].toString();
    }
    if (data.containsKey('link') && data['link'] != null) {
      final linkStr = data['link'].toString();
      final uri = Uri.tryParse(linkStr);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    }
    return null;
  }

  /// Handle notification clicks for smart deep linking / in-app navigation
  Future<void> _handleNotificationClick(RemoteMessage message) async {
    try {
      final data = message.data;
      final title = (message.notification?.title ?? data['title'] ?? '')
          .toString()
          .toLowerCase();
      final body = (message.notification?.body ?? data['body'] ?? '')
          .toString()
          .toLowerCase();
      final link = (data['link'] ?? '').toString().toLowerCase();

      final jobId = extractJobId(data);
      appLog(
        'FCM Notification tapped! Title: "$title", Body: "$body", Link: "$link", Job ID: $jobId',
      );

      // 1. Check if user is authenticated
      final token = await _storage.getToken();
      if (token.isEmpty) {
        appLog('FCM: User not logged in, redirecting to Sign In screen');
        AppRoutes.instance.pushNamed(AppRoutesKey.instance.signInScreen);
        return;
      }

      final userRole = (await _storage.getAppRoll()).toUpperCase();
      appLog('FCM Click routing: Role=$userRole');

      // 2. Scenario 1: Customer accepts/rejects quotation in chat -> Technician gets notification
      // Backend: title: "${status}", body: "Your quotation has been ${status}", link: ".../user/jobs/${jobId}"
      if (body.contains('quotation has been') ||
          body.contains('has been accepted') ||
          body.contains('has been approved') ||
          title.contains('accept') ||
          title.contains('approved') ||
          title.contains('reject') ||
          link.contains('planner')) {
        appLog(
          'FCM Routing [Quotation Status Updated] -> Technician Planner Screen',
        );
        AppRoutes.instance.pushNamed(
          AppRoutesKey.instance.technicianPlannerScreen,
        );
        return;
      }

      // 3. Scenario 2: Technician submits evidence from Planner -> Customer gets notification
      // Backend: title: "Evidence Submitted", body: "Evidence has been submitted for ${job.title}", link: ".../professional/task-evidence/${jobEvidence.id}"
      if (link.contains('task-evidence') ||
          link.contains('evidence') ||
          title.contains('evidence') ||
          body.contains('evidence')) {
        appLog('FCM Routing [Evidence Submitted] -> Customer Activity Screen');
        AppRoutes.instance.pushNamed(
          AppRoutesKey.instance.customerActivityScreen,
        );
        return;
      }

      // 4. Scenario 3: Technician sends Quotation -> Customer gets notification
      // Backend: title: "${job.title}", body: "Got a new Quotation on ${job.title}", link: ".../user/jobs/${jobId}"
      if (body.contains('got a new quotation') ||
          body.contains('new quotation') ||
          body.contains('quotation on') ||
          body.contains('proposal') ||
          link.contains('job-proposal') ||
          link.contains('quotation')) {
        appLog('FCM Routing [New Quotation Received] -> Message / Chat Screen');
        AppRoutes.instance.pushNamed(AppRoutesKey.instance.messageScreen);
        return;
      }

      // 5. Scenario 4: Customer creates a Job -> Technician gets notification
      // Backend: title: "...", body: "...", link: ".../user/jobs/${job.id}"
      if (userRole.contains('PROFESSIONAL') ||
          userRole.contains('TECHNICIAN') ||
          link.contains('/user/jobs') ||
          link.contains('/user/job') ||
          link.contains('all-job-list') ||
          title.contains('job') ||
          body.contains('job')) {
        appLog('FCM Routing [New Job Created] -> Technician Home Screen');
        AppRoutes.instance.pushNamed(AppRoutesKey.instance.appNavigationScreen);
        return;
      }

      // 6. General Chat Message / Fallback
      if (link.contains('message') || link.contains('chat')) {
        AppRoutes.instance.pushNamed(AppRoutesKey.instance.messageScreen);
        return;
      }

      // 7. Default Role Navigation
      AppRoutes.instance.pushNamed(AppRoutesKey.instance.appNavigationScreen);
    } catch (e) {
      errorLog('FCM: _handleNotificationClick error', e);
    }
  }
}
