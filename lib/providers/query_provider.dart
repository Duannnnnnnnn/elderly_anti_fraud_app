import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QueryProvider extends ChangeNotifier {
  bool _isSuspicious = false;
  String _resultMessage = '';
  bool _isLoading = false;

  bool get isSuspicious => _isSuspicious;
  String get resultMessage => _resultMessage;
  bool get isLoading => _isLoading;

  // 模擬的詐騙資料庫
  final List<String> _suspiciousPhones = [
    '0912345678',
    '0987654321',
    '0965432198',
    '0932165487',
  ];

  final List<String> _suspiciousLineIds = [
    'fake_investment123',
    'scammer456',
    'government_fake',
    'shopping_scam',
  ];

  // 檢查電話號碼
  Future<void> checkPhoneNumber(String phoneNumber) async {
    _setLoading(true);
    
    try {
      // 模擬網路請求延遲
      await Future.delayed(Duration(seconds: 2));
      
      // 檢查是否在可疑名單中
      if (_suspiciousPhones.contains(phoneNumber)) {
        _setSuspicious(true, '''⚠️ 這個電話號碼已被多人回報為詐騙號碼！

回報內容：
• 假冒投資顧問，聲稱有內線消息
• 要求加入投資群組
• 誘騙下載不明投資APP

建議：
請立即封鎖此號碼，切勿相信任何投資訊息。如已被騙，請立即撥打165或110報案。''');
      } else {
        // 嘗試使用真實API查詢（如Whoscall等）
        final result = await _queryRealDatabase('phone', phoneNumber);
        if (result != null) {
          _setSuspicious(result['isSuspicious'], result['message']);
        } else {
          _setSuspicious(false, '''✅ 查詢結果：此號碼目前沒有詐騙回報記錄

提醒事項：
• 即使查無記錄，仍請保持警覺
• 不要輕信來路不明的投資訊息
• 政府機關不會主動要求操作ATM
• 如有疑慮，請撥打165反詐騙專線

查詢時間：${DateTime.now().toString().substring(0, 16)}''');
        }
      }
    } catch (e) {
      _setSuspicious(false, '查詢失敗，請稍後再試。如有緊急狀況，請直接撥打165反詐騙專線。');
    } finally {
      _setLoading(false);
    }
  }

  // 檢查LINE ID
  Future<void> checkLineId(String lineId) async {
    _setLoading(true);
    
    try {
      // 模擬網路請求延遲
      await Future.delayed(Duration(seconds: 2));
      
      // 檢查是否在可疑名單中
      if (_suspiciousLineIds.contains(lineId)) {
        _setSuspicious(true, '''⚠️ 這個LINE ID已被回報為詐騙帳號！

回報內容：
• 假冒政府機關人員
• 聲稱有退稅或補助款
• 要求提供銀行帳戶資料

建議：
請立即封鎖此帳號，切勿提供任何個人資料。如有疑慮，請主動聯繫相關政府機關查證。''');
      } else {
        // 嘗試使用真實API查詢
        final result = await _queryRealDatabase('lineId', lineId);
        if (result != null) {
          _setSuspicious(result['isSuspicious'], result['message']);
        } else {
          _setSuspicious(false, '''✅ 查詢結果：此LINE ID目前沒有詐騙回報記錄

提醒事項：
• 即使查無記錄，仍請保持警覺
• 不要隨意加入陌生人的LINE
• 不要點擊來路不明的連結
• 不要提供個人資料給陌生人
• 如有疑慮，請撥打165反詐騙專線

查詢時間：${DateTime.now().toString().substring(0, 16)}''');
        }
      }
    } catch (e) {
      _setSuspicious(false, '查詢失敗，請稍後再試。如有緊急狀況，請直接撥打165反詐騙專線。');
    } finally {
      _setLoading(false);
    }
  }

  // 查詢真實資料庫（可以整合Whoscall、165網站等API）
  Future<Map<String, dynamic>?> _queryRealDatabase(String type, String identifier) async {
    try {
      // 這裡可以整合真實的API
      // 例如：165全民防騙網、Whoscall API等
      
      // 模擬API請求
      final response = await http.get(
        Uri.parse('https://api.example-fraud-checker.com/check'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_API_KEY',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'isSuspicious': data['is_suspicious'] ?? false,
          'message': data['message'] ?? '查詢完成',
        };
      }
    } catch (e) {
      // 如果API無法使用，返回null，使用預設邏輯
      print('API查詢失敗: $e');
    }
    
    return null;
  }

  // 設定載入狀態
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 設定查詢結果
  void _setSuspicious(bool suspicious, String message) {
    _isSuspicious = suspicious;
    _resultMessage = message;
    notifyListeners();
  }

  // 重置查詢結果
  void resetQuery() {
    _isSuspicious = false;
    _resultMessage = '';
    _isLoading = false;
    notifyListeners();
  }

  // 回報新的可疑號碼（用於使用者回報後更新本地快取）
  void addSuspiciousPhone(String phoneNumber) {
    if (!_suspiciousPhones.contains(phoneNumber)) {
      _suspiciousPhones.add(phoneNumber);
    }
  }

  // 回報新的可疑LINE ID
  void addSuspiciousLineId(String lineId) {
    if (!_suspiciousLineIds.contains(lineId)) {
      _suspiciousLineIds.add(lineId);
    }
  }

  // 獲取統計資訊
  Map<String, int> getStatistics() {
    return {
      'totalSuspiciousPhones': _suspiciousPhones.length,
      'totalSuspiciousLineIds': _suspiciousLineIds.length,
    };
  }
}