# TestFlight 배포 가이드

## 사전 준비 완료 현황

| 항목 | 상태 |
|------|------|
| iOS 릴리즈 빌드 | ✅ 성공 |
| 앱 아이콘 | ✅ 모든 사이즈 준비 |
| 스크린샷 6.7인치 | ✅ screenshots/6.7inch/ |
| 스크린샷 6.5인치 | ✅ screenshots/6.5inch/ |
| 개인정보 처리방침 | ✅ privacy_policy.md |
| 스토어 등록 정보 | ✅ store_listing.md |

---

## 1단계: Apple Developer 계정 설정

### 1.1 개발자 계정 가입 완료 후
- https://developer.apple.com 에서 로그인
- Certificates, IDs & Profiles 메뉴 접근

### 1.2 App ID 등록
1. Identifiers > App IDs > 새로 생성
2. Bundle ID: `com.bookscribe.app`
3. 필요한 Capabilities 체크:
   - Push Notifications (필요시)
   - Sign in with Apple (필요시)

### 1.3 인증서 생성
1. Certificates > 새로 생성
2. iOS Distribution (App Store and Ad Hoc) 선택
3. Keychain Access에서 CSR 생성 후 업로드
4. 인증서 다운로드 및 설치

### 1.4 Provisioning Profile 생성
1. Profiles > 새로 생성
2. App Store 선택
3. App ID: `com.bookscribe.app` 선택
4. 인증서 선택
5. 다운로드

---

## 2단계: App Store Connect 설정

### 2.1 앱 생성
1. https://appstoreconnect.apple.com 접속
2. My Apps > 새 앱 생성
3. 정보 입력:
   - 플랫폼: iOS
   - 이름: Bookscribe
   - 기본 언어: 한국어
   - 번들 ID: `com.bookscribe.app`
   - SKU: `bookscribe-ios-001`

### 2.2 앱 정보 입력

**일반 정보**
- 카테고리: Books (기본) / Productivity (보조)
- 콘텐츠 등급: 4+
- 라이선스 계약: 표준 Apple EULA

**버전 정보 (1.0.0)**
- 새로운 기능: store_listing.md의 "새로운 기능" 섹션 참조
- 스크린샷: screenshots/6.7inch/ 및 screenshots/6.5inch/ 업로드
- 설명: store_listing.md 참조
- 키워드: store_listing.md 참조
- 지원 URL: (GitHub Pages 등으로 호스팅)
- 개인정보 처리방침 URL: (GitHub Pages 등으로 호스팅)

---

## 3단계: Xcode에서 아카이브 및 업로드

### 3.1 Xcode 프로젝트 열기
```bash
cd /Users/ab180-yechan-mbp/book-scanner/book-note-scribe/app/ios
open Runner.xcworkspace
```

### 3.2 Signing 설정
1. Runner 타겟 선택
2. Signing & Capabilities 탭
3. Team: 본인의 개발자 계정 선택
4. Automatically manage signing 체크
5. Bundle Identifier: `com.bookscribe.app` 확인

### 3.3 아카이브 생성
1. 상단 메뉴: Product > Archive
2. 빌드 완료까지 대기 (약 5-10분)

### 3.4 App Store Connect에 업로드
1. Organizer 창에서 아카이브 선택
2. "Distribute App" 클릭
3. "App Store Connect" 선택
4. "Upload" 선택
5. 옵션 확인 후 Next
6. 업로드 완료 대기

---

## 4단계: TestFlight 설정

### 4.1 빌드 처리 대기
- 업로드 후 App Store Connect에서 빌드 처리 (15-30분 소요)
- 이메일로 처리 완료 알림

### 4.2 내부 테스터 추가
1. App Store Connect > 앱 선택 > TestFlight
2. Internal Testing > 그룹 생성
3. 테스터 추가 (Apple ID 이메일)

### 4.3 외부 테스터 추가 (선택)
1. External Testing > 그룹 생성
2. 빌드 제출 (App Review 필요, 24-48시간 소요)
3. 테스터 초대

### 4.4 테스트 정보 입력
- 테스트 목적 설명
- 로그인 정보 (필요시)
- 연락처

---

## 5단계: CLI로 빠르게 업로드 (대안)

Xcode 대신 CLI를 사용할 수 있습니다:

### 5.1 IPA 빌드
```bash
cd /Users/ab180-yechan-mbp/book-scanner/book-note-scribe/app

# 서명된 릴리즈 빌드
flutter build ipa --release

# 결과물: build/ios/ipa/bookscribe.ipa
```

### 5.2 업로드
```bash
# Transporter 앱 사용 또는 altool
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/bookscribe.ipa \
  --username "your-apple-id@example.com" \
  --password "@keychain:AC_PASSWORD"
```

---

## 주의사항

1. **개인정보 처리방침 URL 필수**
   - App Store 제출 전 웹에 호스팅 필요
   - GitHub Pages 추천: `https://username.github.io/bookscribe/privacy`

2. **Export Compliance**
   - 앱이 암호화를 사용하는 경우 설정 필요
   - Supabase 사용 시 HTTPS만 사용하므로 "No" 선택 가능

3. **스크린샷 요구사항**
   - 6.7인치 (1290x2796): 필수
   - 6.5인치 (1284x2778): 필수 (또는 6.7인치로 대체)
   - 5.5인치 (1242x2208): 선택

---

## 문제 해결

### 빌드 오류 발생 시
```bash
flutter clean
cd ios && pod deintegrate && pod install
flutter build ios --release
```

### 서명 오류 발생 시
- Xcode > Preferences > Accounts에서 계정 확인
- Provisioning Profile 다시 다운로드

### 업로드 실패 시
- 네트워크 연결 확인
- Apple 서버 상태 확인: https://developer.apple.com/system-status/
