import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  
  // OpenAI API設定（需要替換為實際的API Key）
  static const String _apiKey = 'sk-iDsoqqwO8XgSrH2GJPcamt8Mviz10ZoAPGskm5raYHrVasOz';
  static const String _apiUrl = 'https://api.chatanywhere.tech/v1/chat/completions';

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  // 添加訊息
  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  // 設定輸入狀態
  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  // 獲取AI回應
  Future<void> getAIResponse(String userMessage, [File? imageFile]) async {
    setTyping(true);

    try {
      String aiResponse;
      
      // 如果有圖片，使用GPT-4V處理圖片
      if (imageFile != null) {
        aiResponse = await _getImageAnalysisResponse(userMessage, imageFile);
      } else {
        aiResponse = await _getTextResponse(userMessage);
      }

      // 添加AI回應訊息
      addMessage(
        ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      // 錯誤處理
      addMessage(
        ChatMessage(
          text: '抱歉，我現在無法回應您的問題。請稍後再試，或撥打165反詐騙專線尋求協助。',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      setTyping(false);
    }
  }

  // 獲取文字回應
  Future<String> _getTextResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''你是一位專業的防詐顧問，專門協助台灣的銀髮族識別和預防詐騙。請用以下準則回應：

1. 使用台灣繁體中文回答
2. 保持友善、耐心的語調
3. 提供具體、實用的建議
4. 參考台灣最新的詐騙案例和政府資料
5. 如果用戶描述的情況可能是詐騙，要明確警告並建議撥打165
6. 回答要簡潔易懂，適合銀髮族理解
7. 如果不確定是否為詐騙，建議保持警覺並尋求專業協助

你的目標是幫助長輩學會識別詐騙、保護自己的財產安全。'''
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else if (response.statusCode == 401) {
        return '抱歉，AI服務目前無法使用。請檢查API設定或聯繫開發人員。如有詐騙疑問，請直接撥打165專線。';
      } else {
        throw Exception('API請求失敗: ${response.statusCode}');
      }
    } catch (e) {
      // 如果API無法使用，提供基本的回應
      return _getOfflineResponse(userMessage);
    }
  }

  // 獲取圖片分析回應
  Future<String> _getImageAnalysisResponse(String userMessage, File imageFile) async {
    try {
      // 將圖片轉為base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-vision-preview',
          'messages': [
            {
              'role': 'system',
              'content': '''你是一位專業的防詐顧問，專門協助台灣的銀髮族識別詐騙文件和信件。請分析用戶上傳的圖片，並判斷是否有詐騙風險：

1. 仔細檢查文件內容、格式、語法
2. 注意可疑的聯絡方式、網址、QR Code
3. 識別常見的詐騙話術和手法
4. 檢查是否有政府機關或知名企業的偽造標誌
5. 提供明確的風險評估和建議

請用台灣繁體中文回答，語調要親切友善，適合銀髮族理解。'''
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': userMessage.isEmpty ? '請幫我分析這份文件是否有詐騙風險' : userMessage,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        throw Exception('圖片分析失敗: ${response.statusCode}');
      }
    } catch (e) {
      return '''我無法分析這張圖片，但您可以注意以下詐騙警示：

🚨 常見詐騙文件特徵：
• 要求立即匯款或轉帳
• 聲稱中獎、退稅、補助款
• 假冒政府機關或知名企業
• 語法錯誤或格式異常
• 可疑的聯絡方式

建議：
如果您對任何文件有疑慮，請撥打165反詐騙專線，或前往相關機關官網查證。''';
    }
  }

  // 離線回應（當API無法使用時的基本回應）
  String _getOfflineResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('投資') || lowerMessage.contains('理財') || lowerMessage.contains('股票')) {
      return '''⚠️ 投資詐騙警告

常見手法：
• 保證獲利、穩賺不賠
• 要求加入投資群組
• 要求下載不明APP
• 聲稱有內線消息

建議：
請記住「天下沒有穩賺不賠的投資」！如有疑慮，請撥打165反詐騙專線。''';
    }
    
    if (lowerMessage.contains('政府') || lowerMessage.contains('國稅局') || lowerMessage.contains('健保')) {
      return '''⚠️ 假冒政府機關警告

重要提醒：
• 政府機關不會要求操作ATM
• 不會透過電話要求提供個人資料
• 退稅不會用電話通知

建議：
如接到自稱政府機關的電話，請掛斷後主動撥打該機關電話查證。''';
    }
    
    if (lowerMessage.contains('line') || lowerMessage.contains('臉書') || lowerMessage.contains('網購')) {
      return '''⚠️ 網路詐騙警告

常見手法：
• 假賣家、假買家
• 要求私下交易
• 價格異常便宜
• 要求先付款後發貨

建議：
網路購物請使用有保障的平台，避免私下交易。''';
    }
    
    return '''感謝您的詢問！雖然我現在無法提供詳細分析，但請記住防詐三要原則：

1. 要冷靜：遇到可疑狀況先冷靜思考
2. 要查證：主動查證對方身分和資訊
3. 要報警：發現詐騙立即撥打165或110

如有任何疑慮，請直接撥打165反詐騙專線。''';
  }

  // 清除所有訊息
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}