import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _lineIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _reportType = 'phone'; // 'phone' 或 'lineId'
  String _fraudType = 'investment'; // 詐騙類型
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _fraudTypes = [
    {'value': 'investment', 'label': '假投資詐騙'},
    {'value': 'government', 'label': '假冒政府機關'},
    {'value': 'shopping', 'label': '假購物網站'},
    {'value': 'loan', 'label': '假貸款'},
    {'value': 'romance', 'label': '感情詐騙'},
    {'value': 'other', 'label': '其他詐騙'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _lineIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // 構建要提交的數據
        final reportData = {
          'type': _reportType,
          'fraudType': _fraudType,
          'phoneNumber': _reportType == 'phone' ? _phoneController.text : null,
          'lineId': _reportType == 'lineId' ? _lineIdController.text : null,
          'description': _descriptionController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending', // 待審核
        };

        // 提交到Firebase
        await FirebaseFirestore.instance
            .collection('fraud_reports')
            .add(reportData);

        // 顯示成功訊息
        _showSuccessDialog();

        // 清空表單
        _clearForm();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('提交失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearForm() {
    _phoneController.clear();
    _lineIdController.clear();
    _descriptionController.clear();
    setState(() {
      _reportType = 'phone';
      _fraudType = 'investment';
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('✅ 回報成功'),
          content: Text('感謝您的回報！我們會審核您提供的資訊，協助其他用戶避免詐騙。'),
          actions: [
            TextButton(
              child: Text('確定'),
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
        title: Text('回報可疑號碼'),
        backgroundColor: Colors.orange[700],
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
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '回報說明',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('如果您遇到可疑的電話號碼或LINE ID，請協助回報。您的回報將幫助其他用戶避免詐騙。'),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // 回報類型選擇
              Text(
                '請選擇回報類型：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('電話號碼'),
                      value: 'phone',
                      groupValue: _reportType,
                      onChanged: (value) {
                        setState(() {
                          _reportType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('LINE ID'),
                      value: 'lineId',
                      groupValue: _reportType,
                      onChanged: (value) {
                        setState(() {
                          _reportType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // 電話號碼輸入欄位
              if (_reportType == 'phone')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '可疑電話號碼：',
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
                        return null;
                      },
                    ),
                  ],
                ),
              
              // LINE ID輸入欄位
              if (_reportType == 'lineId')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '可疑LINE ID：',
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
                        return null;
                      },
                    ),
                  ],
                ),
              
              SizedBox(height: 20),
              
              // 詐騙類型選擇
              Text(
                '詐騙類型：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _fraudType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _fraudTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(type['label']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _fraudType = value!;
                  });
                },
              ),
              
              SizedBox(height: 20),
              
              // 詳細描述
              Text(
                '詳細描述（選填）：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '請描述詐騙經過、手法或其他相關資訊...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              
              SizedBox(height: 24),
              
              // 提交按鈕
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    child: _isSubmitting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('提交回報', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // 注意事項
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '注意事項',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• 請確保提供的資訊真實準確'),
                    Text('• 我們會對所有回報進行審核'),
                    Text('• 您的回報將協助建立防詐資料庫'),
                    Text('• 如有緊急情況，請直接撥打165或110'),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // 已提交的回報歷史
              _buildReportHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '我的回報歷史',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          height: 200,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('fraud_reports')
                .orderBy('timestamp', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Card(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '尚無回報記錄',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        data['type'] == 'phone' ? Icons.phone : Icons.alternate_email,
                        color: Colors.orange,
                      ),
                      title: Text(
                        data['type'] == 'phone' 
                          ? data['phoneNumber'] ?? '電話號碼'
                          : data['lineId'] ?? 'LINE ID',
                      ),
                      subtitle: Text(
                        _fraudTypes.firstWhere(
                          (type) => type['value'] == data['fraudType'],
                          orElse: () => {'label': '其他詐騙'},
                        )['label'],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: data['status'] == 'approved' 
                            ? Colors.green 
                            : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['status'] == 'approved' ? '已審核' : '審核中',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}