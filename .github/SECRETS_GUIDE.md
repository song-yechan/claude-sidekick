# GitHub Secrets 설정 가이드

CI/CD 파이프라인이 정상적으로 동작하려면 아래 Secrets를 GitHub 저장소에 설정해야 합니다.

**설정 위치**: Repository → Settings → Secrets and variables → Actions → New repository secret

---

## 공통 (필수)

| Secret Name | 설명 | 예시 |
|-------------|------|------|
| `SUPABASE_URL` | Supabase 프로젝트 URL | `https://xxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase Anonymous Key | `eyJhbGciOiJIUzI1NiIs...` |

---

## Android 빌드용

| Secret Name | 설명 | 생성 방법 |
|-------------|------|----------|
| `ANDROID_KEYSTORE_BASE64` | Keystore 파일 (Base64 인코딩) | `base64 -i upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore 비밀번호 | keytool 생성 시 설정한 값 |
| `ANDROID_KEY_PASSWORD` | Key 비밀번호 | keytool 생성 시 설정한 값 |
| `ANDROID_KEY_ALIAS` | Key 별칭 | `upload` |

### Keystore Base64 인코딩 방법

```bash
# macOS/Linux
base64 -i app/android/app/upload-keystore.jks | pbcopy

# 또는 파일로 저장
base64 -i app/android/app/upload-keystore.jks > keystore_base64.txt
```

---

## iOS 빌드용

| Secret Name | 설명 | 생성 방법 |
|-------------|------|----------|
| `IOS_P12_CERTIFICATE_BASE64` | 배포 인증서 (.p12) Base64 | Keychain에서 내보내기 후 인코딩 |
| `IOS_P12_PASSWORD` | P12 파일 비밀번호 | 내보내기 시 설정한 값 |
| `IOS_KEYCHAIN_PASSWORD` | 임시 키체인 비밀번호 | 임의 문자열 (예: `temp123`) |
| `IOS_PROVISIONING_PROFILE_BASE64` | Provisioning Profile Base64 | Apple Developer에서 다운로드 후 인코딩 |
| `IOS_PROVISIONING_PROFILE_NAME` | Provisioning Profile 이름 | Apple Developer에서 확인 |
| `IOS_CODE_SIGN_IDENTITY` | 코드 서명 ID | `Apple Distribution: Your Name (TEAM_ID)` |
| `IOS_TEAM_ID` | Apple Developer Team ID | Apple Developer 계정에서 확인 |

### iOS 인증서 Base64 인코딩 방법

```bash
# P12 인증서 인코딩
base64 -i Certificates.p12 | pbcopy

# Provisioning Profile 인코딩
base64 -i YourApp.mobileprovision | pbcopy
```

### P12 인증서 내보내기 (Keychain Access)

1. Keychain Access 실행
2. "로그인" 키체인 → "나의 인증서" 선택
3. 배포 인증서 우클릭 → "내보내기"
4. .p12 형식으로 저장 (비밀번호 설정)

### Provisioning Profile 다운로드

1. [Apple Developer](https://developer.apple.com) 접속
2. Certificates, Identifiers & Profiles → Profiles
3. App Store 배포용 프로필 다운로드

---

## 워크플로우 트리거

### CI (자동)
- `main`, `develop` 브랜치에 push 시
- PR 생성 시

### Build (수동/태그)
- Git 태그 push 시 (`v1.0.0` 형식)
- GitHub Actions에서 수동 실행 (workflow_dispatch)

```bash
# 릴리스 태그 생성 및 푸시
git tag v1.0.0
git push origin v1.0.0
```

---

## 문제 해결

### Android 빌드 실패
- Keystore Base64가 올바르게 인코딩되었는지 확인
- `key.properties` 값들이 정확한지 확인

### iOS 빌드 실패
- 인증서가 만료되지 않았는지 확인
- Provisioning Profile이 앱 번들 ID와 일치하는지 확인
- Team ID가 정확한지 확인
