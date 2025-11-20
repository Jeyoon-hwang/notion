# Digital Note - Flutter

태블릿 최적화 디지털 필기 앱 (Flutter 버전)

## 📱 Features

- ✏️ **자연스러운 필기**: 압력 감지 지원 (Apple Pencil, S Pen)
- 🎨 **다양한 색상**: 6가지 프리셋 + 커스텀 색상 선택기
- 🧹 **지우개**: 픽셀 단위 지우기
- ↶↷ **Undo/Redo**: 최대 50단계
- 🌙 **다크 모드**: 눈 편안한 어두운 테마
- 💾 **이미지 저장**: PNG 형식으로 갤러리에 저장
- 📐 **선 두께 조절**: 1-30px
- 💧 **투명도 조절**: 0.1-1.0
- 👆 **제스처 지원**: 
  - 2손가락 탭: Undo
  - 3손가락 탭: Redo
- 📱 **반응형**: 세로/가로 모드 모두 지원

## 🛠 Tech Stack

- **Flutter 3.0+**
- **Dart 3.0+**
- **Provider** (상태 관리)
- **CustomPainter** (고성능 드로잉)
- **path_provider** (파일 저장)
- **image_gallery_saver** (이미지 저장)

## 📂 Project Structure

```
lib/
├── main.dart                      # 앱 진입점
├── models/
│   └── drawing_stroke.dart        # 드로잉 데이터 모델
├── providers/
│   └── drawing_provider.dart      # 상태 관리
├── screens/
│   └── canvas_screen.dart         # 메인 화면
└── widgets/
    ├── drawing_canvas.dart        # CustomPainter 캔버스
    ├── header.dart                # 상단 헤더
    ├── floating_toolbar.dart      # 하단 툴바
    └── slider_panel.dart          # 슬라이더 패널
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode (for platform-specific builds)

### Installation

```bash
# 1. 의존성 설치
flutter pub get

# 2. 개발 서버 실행
flutter run

# 3. Android APK 빌드
flutter build apk --release

# 4. iOS IPA 빌드 (macOS만 가능)
flutter build ios --release
```

### Run on Specific Device

```bash
# 연결된 기기 확인
flutter devices

# 특정 기기에서 실행
flutter run -d <device-id>

# iPad 시뮬레이터에서 실행
flutter run -d "iPad Pro (12.9-inch)"

# Android 에뮬레이터에서 실행
flutter run -d emulator-5554
```

## 🎯 Key Components

### DrawingProvider
상태 관리 클래스로 모든 드로잉 상태를 관리합니다:
- 획(strokes) 저장 및 관리
- Undo/Redo 히스토리
- 도구 설정 (색상, 두께, 투명도)
- 다크 모드 토글

### DrawingCanvas
CustomPainter를 사용하여 고성능 벡터 드로잉을 구현:
- 압력 감지 지원
- 부드러운 선 렌더링
- 실시간 드로잉 업데이트

### UI Components
- **Header**: 상단 액션 버튼 (Undo, Redo, Clear, Save, Dark Mode)
- **FloatingToolbar**: 하단 플로팅 툴바 (펜/지우개, 색상 선택)
- **SliderPanel**: 좌측 패널 (두께, 투명도 조절)

## 📱 Supported Platforms

- ✅ iOS (iPad optimized)
- ✅ Android (Tablet optimized)
- ✅ Web (experimental)
- ✅ macOS
- ✅ Windows

## 🎨 Design System

- **Primary Color**: `#667EEA` (Purple)
- **Secondary Color**: `#764BA2` (Purple)
- **Gradient**: Linear gradient from purple to violet
- **Dark Mode**: Deep blue-gray background
- **Typography**: SF Pro / Roboto

## 🔧 Configuration

### Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save your drawings</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library</string>
```

## 🐛 Known Issues

- 제스처 힌트가 일부 기기에서 표시되지 않을 수 있음
- 매우 긴 획을 그릴 때 성능 저하 가능성

## 🚧 Future Enhancements

- [ ] 레이어 시스템
- [ ] PDF 가져오기/주석
- [ ] 손글씨 인식 (OCR)
- [ ] 클라우드 동기화
- [ ] 페이지 관리
- [ ] 도형 인식 (자동 교정)
- [ ] 텍스트 도구
- [ ] 이미지 삽입

## 📄 License

MIT License

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or support, please open an issue on GitHub.
