import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _htmlContent = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFraudInfo();
  }

  Future<void> _loadFraudInfo() async {
    // 模擬從政府網站獲取防詐資訊
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _htmlContent = '''
        <div style="padding: 16px;">
          <h2 style="color: #d32f2f;">🚨 最新詐騙警示</h2>
          <div style="background-color: #ffebee; padding: 12px; border-radius: 8px; margin: 8px 0;">
            <h3>假投資詐騙</h3>
            <p>近期有詐騙集團假冒知名投資平台，誘騙民眾投資。請記住：<strong>天下沒有穩賺不賠的投資！</strong></p>
          </div>
          
          <div style="background-color: #e3f2fd; padding: 12px; border-radius: 8px; margin: 8px 0;">
            <h3>假冒政府機關詐騙</h3>
            <p>詐騙集團假冒健保局、國稅局等政府機關，要求民眾操作ATM。政府機關絕不會要求民眾操作ATM！</p>
          </div>

          <h2 style="color: #1976d2;">防詐三不原則</h2>
          <ul style="font-size: 16px;">
            <li><strong>不聽：</strong>不聽信陌生人的投資建議</li>
            <li><strong>不信：</strong>不相信有天上掉餡餅的好事</li>
            <li><strong>不轉帳：</strong>絕不隨意轉帳給陌生人</li>
          </ul>

          <div style="background-color: #e8f5e8; padding: 12px; border-radius: 8px; margin: 16px 0;">
            <h3>遇到疑似詐騙怎麼辦？</h3>
            <p style="font-size: 18px; color: #2e7d32;"><strong>立即撥打 165 反詐騙專線</strong></p>
            <p>或至就近警察局報案</p>
          </div>
        </div>
      ''';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('銀髮防詐小幫手', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: '最新警示'),
            Tab(text: '防詐影片'),
            Tab(text: '官方資源'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 最新警示頁面
          _isLoading 
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Html(
                  data: _htmlContent,
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                  },
                ),
              ),
          
          // 防詐影片頁面
          _buildVideoSection(),
          
          // 官方資源頁面
          _buildOfficialResourcesSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEmergencyDialog();
        },
        backgroundColor: Colors.red[600],
        child: Icon(Icons.phone, color: Colors.white),
        tooltip: '緊急求助',
      ),
    );
  }

  Widget _buildVideoSection() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildVideoCard(
          '如何識別投資詐騙',
          '學會識別常見的投資詐騙手法',
          'https://www.youtube.com/watch?v=example1',
        ),
        _buildVideoCard(
          '假冒政府機關詐騙防範',
          '了解詐騙集團如何假冒政府機關',
          'https://www.youtube.com/watch?v=example2',
        ),
        _buildVideoCard(
          'ATM操作安全須知',
          '學會安全使用ATM，避免被騙',
          'https://www.youtube.com/watch?v=example3',
        ),
      ],
    );
  }

  Widget _buildVideoCard(String title, String description, String url) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(Icons.play_circle_fill, color: Colors.red, size: 40),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        onTap: () {
          // 在這裡可以整合影片播放功能或跳轉到瀏覽器
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('準備播放影片：$title')),
          );
        },
      ),
    );
  }

  Widget _buildOfficialResourcesSection() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildResourceCard(
          '165全民防騙網',
          '警政署官方防詐資源',
          Icons.security,
          () => _openWebView('https://165.npa.gov.tw/'),
        ),
        _buildResourceCard(
          '行政院打詐入口網',
          '政府打詐政策與資源',
          Icons.account_balance,
          () => _openWebView('https://www.ey.gov.tw/'),
        ),
        _buildResourceCard(
          '金管會防詐騙專區',
          '金融詐騙防範資訊',
          Icons.account_balance_wallet,
          () => _openWebView('https://www.fsc.gov.tw/'),
        ),
        _buildResourceCard(
          '內政部防詐專區',
          '最新防詐法規與政策',
          Icons.home,
          () => _openWebView('https://www.moi.gov.tw/'),
        ),
      ],
    );
  }

  Widget _buildResourceCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[700], size: 32),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _openWebView(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            // 只允許初始網址在WebView內開啟，其他外部連結用瀏覽器開啟
            if (request.url == url) {
              return NavigationDecision.navigate;
            } else {
              if (await canLaunchUrl(Uri.parse(request.url))) {
                await launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('官方資源'),
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
          body: WebViewWidget(controller: controller),
        ),
      ),
    );
  }


  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('緊急求助', style: TextStyle(color: Colors.red[700])),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone, color: Colors.red),
                title: Text('165 反詐騙專線'),
                onTap: () {
                  // 這裡可以整合撥號功能
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('撥打 165 反詐騙專線')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.local_police, color: Colors.blue),
                title: Text('110 報案專線'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('撥打 110 報案專線')),
                  );
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}