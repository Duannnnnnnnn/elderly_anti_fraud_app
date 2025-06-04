import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  // 初始化推播通知
  Future<void> initializeNotifications() async {
    try {
      // 請求推播權限
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('用戶已授權推播通知');
        
        // 獲取FCM Token
        _fcmToken = await _messaging.getToken();
        print('FCM Token: $_fcmToken');
        
        // 監聽Token變更
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _saveTokenToDatabase(newToken);
        });
        
        // 設定前景推播處理
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // 設定背景推播處理
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
        
        // 設定應用終止時的推播處理
        _handleTerminatedMessage();
        
        // 儲存Token到資料庫
        if (_fcmToken != null) {
          await _saveTokenToDatabase(_fcmToken!);
        }
        
        // 設定每日提醒
        await _scheduleDailyReminder();
        
      } else {
        print('用戶拒絕推播通知權限');
      }
    } catch (e) {
      print('初始化推播通知失敗: $e');
    }
  }

  // 處理前景推播
  void _handleForegroundMessage(RemoteMessage message) {
    print('收到前景推播: ${message.notification?.title}');
    
    // 可以在這裡顯示應用內通知
    _showInAppNotification(message);
  }

  // 處理背景推播點擊
  void _handleBackgroundMessage(RemoteMessage message) {
    print('用戶點擊背景推播: ${message.notification?.title}');
    
    // 根據推播內容導航到相應頁面
    _handleNotificationTap(message);
  }

  // 處理應用終止時的推播
  void _handleTerminatedMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    
    if (initialMessage != null) {
      print('應用從終止狀態被推播喚醒: ${initialMessage.notification?.title}');
      _handleNotificationTap(initialMessage);
    }
  }

  // 顯示應用內通知
  void _showInAppNotification(RemoteMessage message) {
    // 這裡可以實作自定義的應用內通知UI
    // 或使用SnackBar、Dialog等方式顯示
  }

  // 處理推播點擊事件
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    
    // 根據推播類型導航到不同頁面
    if (data['type'] == 'fraud_alert') {
      // 導航到防詐資訊頁面
    } else if (data['type'] == 'daily_reminder') {
      // 導航到首頁
    }
  }

  // 儲存FCM Token到資料庫
  Future<void> _saveTokenToDatabase(String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('user_tokens')
          .doc(token)
          .set({
        'token': token,
        'platform': 'flutter',
        'created_at': FieldValue.serverTimestamp(),
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('儲存Token失敗: $e');
    }
  }

  // 設定每日提醒
  Future<void> _scheduleDailyReminder() async {
    try {
      // 訂閱每日提醒主題
      await _messaging.subscribeToTopic('daily_reminder');
      print('已訂閱每日提醒');
    } catch (e) {
      print('訂閱每日提醒失敗: $e');
    }
  }

  // 取消每日提醒
  Future<void> unsubscribeDailyReminder() async {
    try {
      await _messaging.unsubscribeFromTopic('daily_reminder');
      print('已取消訂閱每日提醒');
    } catch (e) {
      print('取消訂閱每日提醒失敗: $e');
    }
  }

  // 訂閱特定類型的警示
  Future<void> subscribeToFraudAlerts() async {
    try {
      await _messaging.subscribeToTopic('fraud_alerts');
      print('已訂閱詐騙警示');
    } catch (e) {
      print('訂閱詐騙警示失敗: $e');
    }
  }

  // 取消訂閱詐騙警示
  Future<void> unsubscribeFromFraudAlerts() async {
    try {
      await _messaging.unsubscribeFromTopic('fraud_alerts');
      print('已取消訂閱詐騙警示');
    } catch (e) {
      print('取消訂閱詐騙警示失敗: $e');
    }
  }

  // 發送測試通知（用於開發測試）
  Future<void> sendTestNotification() async {
    // 這個方法需要後端支援
    // 可以創建一個Cloud Function來發送測試通知
    print('發送測試通知（需要後端實作）');
  }

  // 取得推播設定狀態
  Future<Map<String, bool>> getNotificationSettings() async {
    final settings = await _messaging.getNotificationSettings();
    
    return {
      'enabled': settings.authorizationStatus == AuthorizationStatus.authorized,
      'alert': settings.alert == AppleNotificationSetting.enabled,
      'badge': settings.badge == AppleNotificationSetting.enabled,
      'sound': settings.sound == AppleNotificationSetting.enabled,
    };
  }

  // 處理推播設定變更
  Future<void> updateNotificationSettings({
    bool? dailyReminder,
    bool? fraudAlerts,
  }) async {
    try {
      if (dailyReminder != null) {
        if (dailyReminder) {
          await subscribeToFraudAlerts();
        } else {
          await unsubscribeDailyReminder();
        }
      }
      
      if (fraudAlerts != null) {
        if (fraudAlerts) {
          await subscribeToFraudAlerts();
        } else {
          await unsubscribeFromFraudAlerts();
        }
      }
    } catch (e) {
      print('更新推播設定失敗: $e');
    }
  }
}

// 背景訊息處理函數（必須是頂層函數）
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('背景接收到推播: ${message.notification?.title}');
  
  // 在這裡可以執行背景任務
  // 例如更新本地資料庫、顯示通知等
}