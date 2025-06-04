import 'dart:io';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final File? imageFile;
  final String? imageUrl;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageFile,
    this.imageUrl,
  });

  // 轉換為JSON格式（用於儲存到本地或資料庫）
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      // 注意：File物件無法直接序列化，需要另外處理
    };
  }

  // 從JSON創建ChatMessage物件
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      imageUrl: json['imageUrl'],
    );
  }

  // 複製並修改某些屬性
  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    File? imageFile,
    String? imageUrl,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // 判斷是否包含圖片
  bool get hasImage => imageFile != null || imageUrl != null;

  // 獲取顯示用的時間字串
  String get timeString {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // 獲取顯示用的日期字串
  String get dateString {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return '今天';
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return '昨天';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  @override
  String toString() {
    return 'ChatMessage(text: $text, isUser: $isUser, timestamp: $timestamp, hasImage: $hasImage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ChatMessage &&
        other.text == text &&
        other.isUser == isUser &&
        other.timestamp == timestamp &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        isUser.hashCode ^
        timestamp.hashCode ^
        imageUrl.hashCode;
  }
}