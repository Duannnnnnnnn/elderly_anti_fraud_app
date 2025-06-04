# 銀髮防詐小幫手 - Flutter App 開發指南

## 專案概述

這是一個專為銀髮族設計的防詐騙Flutter應用程式，整合了政府防詐資訊、AI聊天助手、一鍵查詢功能等多項防詐功能。

## 主要功能

1. **整合政府防詐資訊** - 顯示最新詐騙警示和官方防詐資源
2. **一鍵查詢功能** - 查詢可疑電話號碼和LINE ID
3. **AI聊天機器人** - 整合ChatGPT API的防詐諮詢助手
4. **圖片識別功能** - 上傳可疑文件進行AI分析
5. **語音輸入** - 支援語音轉文字功能
6. **用戶回報** - 回報可疑號碼和詐騙資訊
7. **每日推播通知** - 定期推送防詐提醒

## 環境設置

### 1. Flutter 環境
確保已安裝Flutter 3.0或更高版本：
```bash
flutter --version
flutter doctor
```

### 2. 專案初始化
```bash
flutter create elderly_anti_fraud_app
cd elderly_anti_fraud_app
```

### 3. 依賴套件安裝
將提供的`pubspec.yaml`內容複製到您的專案中，然後執行：
```bash
flutter pub get
```

## Firebase 設置

### 1. 創建 Firebase 專案
1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 點擊「新增專案」
3. 輸入專案名稱「elderly-anti-fraud-app」
4. 完成專案創建

### 2. 配置 Android
1. 在Firebase專案中點擊Android圖示
2. 輸入包名：`com.example.elderly_anti_fraud_app`
3. 下載`google-services.json`檔案
4. 將檔案放置到`android/app/`目錄下

### 3. 配置 iOS（如需支援iOS）
1. 在Firebase專案中點擊iOS圖示
2. 輸入包名：`com.example.elderlyAntiFraudApp`
3. 下載`GoogleService-Info.plist`檔案
4. 將檔案放置到`ios/Runner/`目錄下

### 4. 啟用 Firebase 服務
在Firebase Console中啟用以下服務：
- **Cloud Firestore** - 用於儲存用戶回報資料
- **Cloud Messaging** - 用於推播通知
- **Authentication**（選用）- 如需用戶認證

## OpenAI API 設置

1. 前往 [OpenAI官網](https://openai.com/)註冊帳號
2. 在API Keys頁面創建新的API Key
3. 將API Key更新到`lib/providers/chat_provider.dart`中：
```dart
static const String _apiKey = 'YOUR_OPENAI_API_KEY_HERE';
```

## 專案結構

```
lib/
├── main.dart                 # 應用入口點
├── screens/                  # 頁面檔案
│   ├── home_screen.dart      # 首頁（防詐資訊）
│   ├── query_screen.dart     # 一鍵查詢頁面
│   ├── chat_screen.dart      # AI聊天頁面
│   └── report_screen.dart    # 回報頁面
├── providers/                # 狀態管理
│   ├── chat_provider.dart    # AI聊天狀態
│   └── query_provider.dart   # 查詢狀態
├── models/                   # 資料模型
│   └── chat_message.dart     # 聊天訊息模型
└── services/                 # 服務類
    └── notification_service.dart # 推播通知服務
```

## 權限設置

### Android 權限 (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS 權限 (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>此應用需要相機權限以拍攝可疑文件</string>
<key>NSMicrophoneUsageDescription</key>
<string>此應用需要麥克風權限以使用語音輸入功能</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>此應用需要相簿權限以選擇圖片</string>
```

## 建置和執行

### 開發模式
```bash
flutter run
```

### 建置APK
```bash
flutter build apk --release
```

### 建置iOS（需要macOS）
```bash
flutter build ios --release
```

## 功能測試

### 1. 基本功能測試
- 啟動應用，確認底部導航正常
- 測試各頁面切換功能
- 檢查UI顯示是否正確

### 2. AI聊天功能測試
- 確保OpenAI API Key已正確設置
- 測試文字訊息發送和接收
- 測試語音輸入功能
- 測試圖片上傳和分析

### 3. 查詢功能測試
- 測試電話號碼查詢
- 測試LINE ID查詢
- 驗證查詢結果顯示

### 4. 回報功能測試
- 測試回報表單提交
- 確認Firebase Firestore資料儲存
- 檢查回報歷史顯示

### 5. 推播通知測試
- 確認Firebase設置正確
- 測試推播權限申請
- 驗證推播接收功能

## 部署注意事項

### 1. API金鑰安全
- 生產環境中應將API金鑰存放在環境變數或安全的配置服務中
- 考慮實作API金鑰的輪換機制

### 2. 資料隱私
- 確保用戶資料符合隱私法規
- 實作適當的資料加密和保護措施

### 3. 效能優化
- 優化圖片處理效能
- 實作適當的快取機制
- 考慮離線功能的實作

## 常見問題解決

### 1. Firebase初始化失敗
- 檢查`google-services.json`是否正確放置
- 確認包名是否一致
- 檢查Firebase專案設置

### 2. OpenAI API請求失敗
- 確認API Key是否正確
- 檢查網路連線
- 確認API配額是否充足

### 3. 語音輸入無法使用
- 檢查麥克風權限
- 確認裝置語音功能正常
- 檢查speech_to_text套件設置

### 4. 圖片上傳失敗
- 檢查相機和相簿權限
- 確認圖片大小限制
- 檢查網路連線狀態

## 進階功能擴展

### 1. 離線功能
- 實作本地資料庫（SQLite）
- 快取常用的防詐資訊
- 離線狀態下的基本功能

### 2. 多語言支援
- 實作國際化（i18n）
- 支援英文、台語等
- 語音輸入多語言支援

### 3. 無障礙功能
- 增加字體大小調整
- 實作語音播報功能
- 優化對比度和可讀性

## 聯絡支援

如有開發問題或需要協助，請：
1. 檢查本文件的常見問題部分
2. 查看Flutter官方文檔
3. 參考Firebase和OpenAI的官方文檔

## 版本更新記錄

### v1.0.0
- 初始版本發布
- 基本防詐功能實作
- AI聊天和查詢功能
- 推播通知支援