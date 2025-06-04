# 銀髮防詐小幫手 - 詳細開發步驟

## 步驟一：創建 Flutter 專案

### 1. 創建新專案
```bash
flutter create elderly_anti_fraud_app
cd elderly_anti_fraud_app
```

### 2. 打開 VS Code 或 Android Studio
```bash
code .
```

## 步驟二：設置依賴套件

### 1. 替換 pubspec.yaml 內容
將提供的 pubspec.yaml 檔案內容完全替換原本的內容。

### 2. 安裝依賴套件
```bash
flutter pub get
```

如果遇到版本衝突，可以執行：
```bash
flutter pub deps
flutter pub upgrade
```

## 步驟三：創建目錄結構

在 `lib/` 目錄下創建以下資料夾：
```
lib/
├── screens/
├── providers/
├── models/
└── services/
```

## 步驟四：複製檔案

將所有提供的 Dart 檔案放到對應的目錄：

1. `main.dart` → `lib/main.dart`（替換原檔案）
2. `home_screen.dart` → `lib/screens/home_screen.dart`
3. `query_screen.dart` → `lib/screens/query_screen.dart`
4. `chat_screen.dart` → `lib/screens/chat_screen.dart`
5. `report_screen.dart` → `lib/screens/report_screen.dart`
6. `chat_provider.dart` → `lib/providers/chat_provider.dart`
7. `query_provider.dart` → `lib/providers/query_provider.dart`
8. `chat_message.dart` → `lib/models/chat_message.dart`
9. `notification_service.dart` → `lib/services/notification_service.dart`

## 步驟五：修正 import 路徑

確保所有檔案的 import 路徑正確。如果有錯誤，按照以下格式修正：

```dart
// 正確的 import 格式
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../services/notification_service.dart';
```

## 步驟六：Firebase 設置

### 1. 安裝 Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. 登入 Firebase
```bash
firebase login
```

### 3. 初始化 Firebase 專案
```bash
firebase init
```

### 4. 手動設置（推薦）
1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 創建新專案「elderly-anti-fraud-app」
3. 添加 Android 應用
4. 下載 `google-services.json` 到 `android/app/`

### 5. 啟用必要服務
在 Firebase Console 啟用：
- Cloud Firestore
- Cloud Messaging

## 步驟七：Android 配置

### 1. 修改 android/app/build.gradle
在檔案末尾添加：
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 2. 修改 android/build.gradle
在 dependencies 區塊添加：
```gradle
classpath 'com.google.gms:google-services:4.3.15'
```

### 3. 設置權限
在 `android/app/src/main/AndroidManifest.xml` 添加：
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## 步驟八：OpenAI API 設置

### 1. 註冊 OpenAI 帳號
前往 [OpenAI](https://openai.com/) 註冊並取得 API Key

### 2. 更新 API Key
在 `lib/providers/chat_provider.dart` 中：
```dart
static const String _apiKey = '你的_API_KEY_在這裡';
```

**重要：生產環境中不要直接寫在代碼裡！**

## 步驟九：測試基本功能

### 1. 檢查是否有編譯錯誤
```bash
flutter analyze
```

### 2. 執行應用
```bash
flutter run
```

### 3. 基本測試項目
- [ ] 應用能正常啟動
- [ ] 底部導航能正常切換
- [ ] 各頁面顯示正常
- [ ] 沒有明顯的 UI 錯誤

## 步驟十：功能測試

### 1. 不需要 API 的功能
- 防詐資訊頁面瀏覽
- 查詢頁面 UI
- 回報表單 UI

### 2. 需要 Firebase 的功能
- 用戶回報提交
- 推播通知（需設置後端）

### 3. 需要 OpenAI API 的功能
- AI 聊天功能
- 圖片分析功能

## 步驟十一：解決常見問題

### 1. 依賴版本衝突
```bash
flutter pub deps
flutter clean
flutter pub get
```

### 2. Firebase 初始化錯誤
檢查：
- `google-services.json` 位置是否正確
- 包名是否一致
- Firebase 專案設置是否完整

### 3. 語音輸入無法使用
檢查：
- 權限是否正確設置
- 測試裝置是否支援語音輸入
- 網路連線是否正常

### 4. AI 功能無法使用
檢查：
- OpenAI API Key 是否正確
- 網路連線是否正常
- API 配額是否充足

## 步驟十二：建置發布版本

### 1. Android APK
```bash
flutter build apk --release
```

### 2. Android AAB（Google Play）
```bash
flutter build appbundle --release
```

### 3. 檔案位置
建置完成的檔案會在：
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## 開發提示

### 1. 熱重載
開發時使用 `r` 進行熱重載，`R` 進行熱重啟

### 2. 除錯
使用 `flutter logs` 查看詳細日誌

### 3. 效能分析
使用 `flutter run --profile` 進行效能測試

### 4. 模擬器建議
- Android: 使用 API 30+ 的模擬器
- iOS: 使用 iOS 14+ 的模擬器

## 下一步開發

完成基本功能後，可以考慮：

1. **美化 UI**：改善字體、顏色、動畫
2. **增加功能**：離線模式、多語言支援
3. **效能優化**：圖片壓縮、快取機制
4. **安全性**：API Key 安全存放、資料加密
5. **測試**：單元測試、整合測試
6. **上架準備**：應用圖示、截圖、商店描述

## 需要協助？

如果在開發過程中遇到問題：

1. 檢查 Flutter 官方文檔
2. 查看 Firebase 文檔
3. 參考 OpenAI API 文檔
4. 在 Stack Overflow 搜尋相關問題
5. 檢查 GitHub Issues

記住：開發過程中遇到問題是正常的，耐心除錯和查詢資料是必要的技能！