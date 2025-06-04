import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';

import '../providers/chat_provider.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  // final stt.SpeechToText _speech = stt.SpeechToText();

  // bool _isListening = false;
  bool _isSending = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // _initSpeech();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // // 初始化語音識別
  // Future<void> _initSpeech() async {
  //   bool available = await _speech.initialize(
  //     onStatus: (status) {
  //       if (status == 'done') {
  //         setState(() {
  //           _isListening = false;
  //         });
  //       }
  //     },
  //     onError: (error) {
  //       setState(() {
  //         _isListening = false;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('語音識別錯誤: $error')),
  //       );
  //     },
  //   );
  //
  //   if (!available) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('您的裝置不支援語音識別')),
  //     );
  //   }
  // }
  //
  // // 開始語音輸入
  // void _startListening() async {
  //   if (_speech.isAvailable) {
  //     setState(() {
  //       _isListening = true;
  //     });
  //     await _speech.listen(
  //       onResult: (result) {
  //         setState(() {
  //           _messageController.text = result.recognizedWords;
  //         });
  //       },
  //       localeId: 'zh_TW', // 設定為台灣中文
  //     );
  //   }
  // }
  //
  // // 停止語音輸入
  // void _stopListening() async {
  //   if (_isListening) {
  //     await _speech.stop();
  //     setState(() {
  //       _isListening = false;
  //     });
  //   }
  // }

  // 從相冊選擇圖片
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // 通知用戶已選擇圖片，準備上傳
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已選擇圖片，請輸入問題或直接送出')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('選擇圖片失敗: $e')),
      );
    }
  }

  // 從相機拍攝圖片
  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // 通知用戶已拍攝圖片，準備上傳
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已拍攝圖片，請輸入問題或直接送出')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('拍攝照片失敗: $e')),
      );
    }
  }

  // 顯示圖片來源選擇對話框
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('選擇圖片來源'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue),
                title: Text('從相冊選擇'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.green),
                title: Text('拍攝照片'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // 發送訊息給AI
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('請輸入訊息或選擇圖片')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // 添加用戶訊息
      if (message.isNotEmpty) {
        chatProvider.addMessage(
          ChatMessage(
            text: message,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );
      }

      // 如果有選擇圖片，添加圖片訊息
      if (_selectedImage != null) {
        chatProvider.addMessage(
          ChatMessage(
            text: '已上傳圖片',
            isUser: true,
            timestamp: DateTime.now(),
            imageFile: _selectedImage,
          ),
        );
      }

      // 清空輸入框和圖片
      _messageController.clear();
      setState(() {
        _selectedImage = null;
      });

      // 滾動到對話底部
      _scrollToBottom();

      // 調用API獲取AI回應
      await chatProvider.getAIResponse(message, _selectedImage);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('發送訊息失敗: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  // 滾動到對話底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.messages;

    return Scaffold(
      appBar: AppBar(
        title: Text('AI防詐助手'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 介紹卡片
          if (messages.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '您好！我是AI防詐助手',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('您可以：'),
                      SizedBox(height: 4),
                      Text('• 詢問我有關詐騙的問題'),
                      Text('• 上傳可疑的信件或文件圖片'),
                      Text('• 使用語音輸入您的問題'),
                      SizedBox(height: 8),
                      Text('讓我來幫助您辨識可能的詐騙風險！'),
                    ],
                  ),
                ),
              ),
            ),

          // 聊天訊息列表
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Text(
                '請輸入您的問題',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // 正在輸入指示器
          if (chatProvider.isTyping)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text('AI助手正在輸入', style: TextStyle(color: Colors.grey)),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),

          // 顯示選擇的圖片
          if (_selectedImage != null)
            Container(
              height: 100,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 輸入區域
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 上傳圖片按鈕
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: _isSending ? null : _showImageSourceDialog,
                  color: Colors.blue,
                ),

                // 語音輸入按鈕
                // IconButton(
                //   icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                //   onPressed: _isSending
                //       ? null
                //       : () {
                //     if (_isListening) {
                //       _stopListening();
                //     } else {
                //       _startListening();
                //     }
                //   },
                //   color: _isListening ? Colors.red : Colors.blue,
                // ),

                // 輸入框
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '輸入您的問題...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                    enabled: !_isSending,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if (!_isSending) {
                        _sendMessage();
                      }
                    },
                  ),
                ),

                SizedBox(width: 8),

                // 發送按鈕
                IconButton(
                  icon: _isSending
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Icon(Icons.send),
                  onPressed: _isSending ? null : _sendMessage,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 構建訊息氣泡
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI頭像
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[700],
              child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),

          SizedBox(width: 8),

          // 訊息氣泡
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[100] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 如果有圖片則顯示
                  if (message.imageFile != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          message.imageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // 訊息文字
                  Text(
                    message.text,
                    style: TextStyle(fontSize: 16),
                  ),

                  // 時間戳記
                  SizedBox(height: 4),
                  Text(
                    '${_formatTimestamp(message.timestamp)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 8),

          // 用戶頭像
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[700],
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  // 格式化時間戳記
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}