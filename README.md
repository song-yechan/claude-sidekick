# BookScan 📚

> AI 기반 독서 기록 및 문장 수집 앱

독서하며 마음에 드는 문장을 사진으로 찍으면 자동으로 텍스트를 추출하고 AI가 요약해주는 스마트한 독서 관리 앱입니다.

## 목차

- [주요 기능](#주요-기능)
- [기술 스택](#기술-스택)
- [시작하기](#시작하기)
- [주요 기능 상세 설명](#주요-기능-상세-설명)
- [프로젝트 구조](#프로젝트-구조)
- [문제 해결](#문제-해결)
- [라이선스](#라이선스)

## 주요 기능

### 📖 책 관리
- **책 검색 및 등록**: 제목, 저자, ISBN으로 책 검색 및 라이브러리에 추가
- **카테고리 분류**: 사용자 정의 카테고리로 책 정리 (소설, 에세이, 자기계발 등)
- **서재 관리**: 등록한 모든 책을 카테고리별로 확인

### 📸 AI 기반 문장 수집
- **OCR 텍스트 추출**: 책의 문장을 사진으로 찍으면 자동으로 텍스트 추출
- **AI 요약**: Lovable AI를 활용한 자동 문장 요약
- **메모 기능**: 추출한 문장에 대한 개인적인 생각 기록
- **페이지 번호 기록**: 문장이 위치한 페이지 번호 저장
- **요약/원문 토글**: AI 요약과 원문을 선택적으로 확인 가능

### 📊 독서 활동 추적
- **활동 캘린더**: GitHub 스타일의 연간 독서 활동 히트맵
- **연도별 조회**: 가입일 이후의 독서 활동을 연도별로 확인
- **통계**: 등록한 책 수와 작성한 노트 수 실시간 확인

### 🔐 사용자 인증
- **회원가입/로그인**: 이메일 기반 사용자 인증
- **개인 데이터 보호**: 사용자별 독립적인 데이터 관리

## 기술 스택

### Frontend
- **React 18** - UI 라이브러리
- **TypeScript** - 타입 안전성
- **Vite** - 빌드 도구
- **Tailwind CSS** - 스타일링
- **shadcn/ui** - UI 컴포넌트
- **React Router** - 라우팅
- **TanStack Query** - 서버 상태 관리

### Backend (Lovable Cloud)
- **Supabase** - 백엔드 서비스
  - Database - PostgreSQL 데이터베이스
  - Authentication - 사용자 인증
  - Edge Functions - 서버리스 함수
- **Lovable AI** - AI 기반 텍스트 처리
  - OCR 이미지 텍스트 추출
  - 문장 요약 생성

### 주요 라이브러리
- `@tanstack/react-query` - 데이터 fetching 및 캐싱
- `react-hook-form` - 폼 관리
- `zod` - 스키마 검증
- `sonner` - 토스트 알림
- `date-fns` - 날짜 처리
- `lucide-react` - 아이콘

## 시작하기

### 요구 사항

- Node.js 18.0 이상
- npm 또는 yarn

### 설치 방법

1. **저장소 클론**
```bash
git clone <YOUR_GIT_URL>
cd <YOUR_PROJECT_NAME>
```

2. **의존성 설치**
```bash
npm install
```

3. **개발 서버 실행**
```bash
npm run dev
```

4. **브라우저에서 접속**
```
http://localhost:5173
```

### 빌드

프로덕션 빌드를 생성하려면:
```bash
npm run build
```

빌드된 파일은 `dist` 폴더에 생성됩니다.

## 주요 기능 상세 설명

### 1. 책 검색 및 등록

사용자는 검색 탭에서 책을 검색하고 자신의 라이브러리에 추가할 수 있습니다.

**작동 방식:**
- 제목, 저자, ISBN으로 책 검색
- 외부 도서 API를 통한 책 정보 조회
- 표지 이미지, 출판사, 출판일 등 상세 정보 자동 수집
- 카테고리 지정하여 추가 가능

**주요 파일:**
- `src/pages/Search.tsx` - 검색 UI
- `src/services/bookApi.ts` - 도서 검색 API
- `supabase/functions/book-search/index.ts` - 도서 검색 Edge Function

### 2. 카테고리 관리

책을 체계적으로 정리할 수 있는 사용자 정의 카테고리 기능입니다.

**작동 방식:**
- 카테고리 생성, 수정, 삭제
- 각 카테고리에 고유한 색상 자동 할당
- 책을 여러 카테고리에 동시 소속 가능
- 카테고리별 책 목록 확인

**주요 파일:**
- `src/pages/Categories.tsx` - 카테고리 목록 UI
- `src/pages/CategoryDetail.tsx` - 카테고리 상세 페이지
- `src/hooks/useCategories.ts` - 카테고리 상태 관리

### 3. 문장 수집 및 AI 분석

BookScan의 핵심 기능으로, 책의 문장을 사진으로 찍어 자동으로 텍스트를 추출하고 요약합니다.

**작동 방식:**
1. 사용자가 책 페이지 사진 촬영
2. OCR Edge Function이 이미지에서 텍스트 추출
3. AI가 추출된 텍스트를 요약
4. 사용자가 페이지 번호와 개인 메모 추가
5. 데이터베이스에 저장

**주요 파일:**
- `src/pages/BookDetail.tsx` - 문장 수집 UI
- `src/pages/NoteDetail.tsx` - 노트 상세 보기
- `supabase/functions/ocr-image/index.ts` - OCR Edge Function
- `supabase/functions/summarize-text/index.ts` - 텍스트 요약 Edge Function
- `src/hooks/useNotes.ts` - 노트 상태 관리

**Edge Functions 상세:**

**OCR Image Function**
- Lovable AI의 Vision 모델 사용
- 이미지를 base64로 인코딩하여 전송
- 한글 텍스트 추출 최적화

**Summarize Text Function**
- Lovable AI의 텍스트 모델 사용
- 긴 문장을 핵심 내용으로 요약
- 문맥을 고려한 지능형 요약

### 4. 독서 활동 캘린더

GitHub의 contribution 그래프 스타일로 독서 활동을 시각화합니다.

**작동 방식:**
- 날짜별 수집한 문장 개수를 히트맵으로 표시
- 활동량에 따라 5단계 색상 강도로 구분
- 연도 토글로 과거 활동 기록 조회
- 가입일 이전 데이터는 접근 불가
- 현재 날짜로 자동 스크롤

**시각화 기준:**
- 0개: 회색 (활동 없음)
- 1-3개: 연한 주황
- 4-8개: 중간 주황
- 9-15개: 진한 주황
- 16-30개: 더 진한 주황
- 31개 이상: 가장 진한 주황

**주요 파일:**
- `src/pages/Home.tsx` - ActivityCalendar 컴포넌트

### 5. 반응형 모바일 UI

모바일 우선으로 설계된 직관적인 사용자 인터페이스입니다.

**주요 특징:**
- 하단 네비게이션 바
- 터치 친화적인 버튼 크기
- 다크/라이트 테마 지원
- 스크롤 최적화

**주요 파일:**
- `src/components/layout/BottomNav.tsx` - 하단 네비게이션
- `src/components/layout/MobileLayout.tsx` - 모바일 레이아웃

## 프로젝트 구조

```
src/
├── components/          # 재사용 가능한 컴포넌트
│   ├── layout/         # 레이아웃 컴포넌트
│   ├── ui/             # shadcn/ui 컴포넌트
│   ├── ProtectedRoute.tsx
│   └── ScrollToTop.tsx
├── contexts/           # React Context
│   └── AuthContext.tsx # 인증 컨텍스트
├── hooks/              # 커스텀 훅
│   ├── useBooks.ts    # 책 관리
│   ├── useCategories.ts # 카테고리 관리
│   ├── useNotes.ts    # 노트 관리
│   └── useLocalStorage.ts # 로컬 스토리지
├── integrations/       # 외부 서비스 통합
│   └── supabase/      # Supabase 클라이언트
├── pages/              # 페이지 컴포넌트
│   ├── Home.tsx       # 홈 페이지 (활동 캘린더)
│   ├── Search.tsx     # 책 검색
│   ├── Library.tsx    # 내 서재
│   ├── Categories.tsx # 카테고리 목록
│   ├── CategoryDetail.tsx # 카테고리 상세
│   ├── BookDetail.tsx # 책 상세 (문장 수집)
│   ├── NoteDetail.tsx # 노트 상세
│   └── Auth.tsx       # 로그인/회원가입
├── services/           # API 서비스
│   └── bookApi.ts     # 도서 검색 API
├── types/              # TypeScript 타입 정의
│   └── book.ts
└── lib/                # 유틸리티 함수
    └── utils.ts

supabase/
└── functions/          # Edge Functions
    ├── book-search/   # 도서 검색 API
    ├── ocr-image/     # OCR 텍스트 추출
    └── summarize-text/ # AI 텍스트 요약
```

## 문제 해결

### 일반적인 문제

**Q: 개발 서버가 시작되지 않습니다**
```bash
# node_modules 삭제 후 재설치
rm -rf node_modules
npm install
```

**Q: 타입 에러가 발생합니다**
```bash
# TypeScript 타입 체크
npm run type-check
```

**Q: 빌드가 실패합니다**
```bash
# 캐시 삭제 후 재빌드
npm run clean
npm run build
```

### AI 기능 관련

**Q: OCR이 제대로 작동하지 않습니다**
- 이미지의 밝기와 선명도를 확인하세요
- 텍스트가 명확하게 보이는 사진을 사용하세요
- 이미지 크기가 너무 크지 않은지 확인하세요

**Q: 요약 결과가 만족스럽지 않습니다**
- 추출된 원문을 직접 수정한 후 다시 저장할 수 있습니다
- AI 요약 토글을 OFF하여 원문을 확인할 수 있습니다

### 데이터 관련

**Q: 데이터가 동기화되지 않습니다**
- 인터넷 연결을 확인하세요
- 로그아웃 후 다시 로그인해보세요
- 브라우저 캐시를 삭제해보세요

**Q: 활동 캘린더에 데이터가 표시되지 않습니다**
- 노트를 저장한 날짜의 연도가 선택되어 있는지 확인하세요
- 페이지를 새로고침해보세요

## 배포

### Lovable을 통한 배포

1. Lovable 에디터에서 우측 상단의 **Publish** 버튼 클릭
2. 자동으로 프로덕션 배포가 진행됩니다
3. 배포된 URL로 앱에 접속 가능

### 커스텀 도메인 연결

1. Lovable에서 **Project > Settings > Domains** 이동
2. **Connect Domain** 클릭
3. 도메인 설정 안내에 따라 진행

자세한 내용은 [Lovable 커스텀 도메인 문서](https://docs.lovable.dev/features/custom-domain)를 참고하세요.

## 기여하기

이 프로젝트는 개인 프로젝트이지만, 제안이나 버그 리포트는 언제나 환영합니다.

## 지원

- 📧 이메일: [프로젝트 관리자 이메일]
- 🐛 버그 리포트: GitHub Issues
- 💡 기능 제안: GitHub Discussions

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 관련 문서

- [Lovable 공식 문서](https://docs.lovable.dev/)
- [Supabase 문서](https://supabase.com/docs)
- [React 문서](https://react.dev/)
- [Tailwind CSS 문서](https://tailwindcss.com/docs)

---

**Made with ❤️ using Lovable**
