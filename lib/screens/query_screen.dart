import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/query_provider.dart';

class QueryScreen extends StatefulWidget {
  @override
  _QueryScreenState createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _lineIdController = TextEditingController();
  bool _isSearching = false;
  String _queryType = 'phone'; // 'phone' 或 'lineId'

  @override
  void dispose() {
    _phoneController.dispose();
    _lineIdController.dispose();
    super.dispose();
  }

  Future<void> _submitQuery() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSearching = true;
      });

      try {
        final queryProvider = Provider.of<QueryProvider>(context, listen: false);
        
        if (_queryType == 'phone') {
          await queryProvider.checkPhoneNumber(_phoneController.text);
        } else {
          await queryProvider.checkLineId(_lineIdController.text);
        }
        
        // 顯示結果
        _showResultDialog(queryProvider.isSuspicious, queryProvider.resultMessage);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('查詢失敗: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _showResultDialog(bool isSuspicious, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isSuspicious ? '⚠️ 可疑號碼警告' : '✅ 查詢結果',
            style: TextStyle(
              color: isSuspicious ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              SizedBox(height: 16),
              Text(
                '提醒：即使查詢結果安全，仍請保持警惕，勿輕易相信來路不明的訊息。',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('了解'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('一鍵查詢'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 頁面說明
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '查詢說明',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('透過本功能，您可以查詢可疑的電話號碼或LINE ID是否曾被回報為詐騙。'),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // 查詢類型選擇
              Text(
                '請選擇查詢類型：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('電話號碼'),
                      value: 'phone',
                      groupValue: _queryType,
                      onChanged: (value) {
                        setState(() {
                          _queryType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('LINE ID'),
                      value: 'lineId',
                      groupValue: _queryType,
                      onChanged: (value) {
                        setState(() {
                          _queryType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // 電話號碼輸入欄位
              if (_queryType == 'phone')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '請輸入要查詢的電話號碼：',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        hintText: '例：0912345678',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入電話號碼';
                        }
                        // 簡單的台灣手機號碼驗證
                        if (!RegExp(r'^09\d{8}$').hasMatch(value)) {
                          return '請輸入有效的台灣手機號碼';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              
              // LINE ID輸入欄位
              if (_queryType == 'lineId')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '請輸入要查詢的LINE ID：',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _lineIdController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.alternate_email),
                        hintText: '例：user123',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入LINE ID';
                        }
                        if (value.length < 3) {
                          return 'LINE ID至少需要3個字元';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              
              SizedBox(height: 24),
              
              // 查詢按鈕
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _submitQuery,
                    child: _isSearching
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('立即查詢', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // 小提示區域
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '小提示',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• 即使查詢結果顯示安全，也請保持警覺'),
                    Text('• 不要聽信陌生人的來電或訊息'),
                    Text('• 不要輕易點擊不明連結'),
                    Text('• 如有疑問，請撥打165反詐騙專線'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}