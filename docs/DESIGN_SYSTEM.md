# BookScribe Design System

Vercel Design Guidelines + UI Skills 기반의 Flutter 디자인 시스템입니다.

> **파일 위치**: `app/lib/core/design_system.dart`

---

## 목차

1. [설계 원칙](#설계-원칙)
2. [애니메이션](#애니메이션)
3. [그림자 시스템](#그림자-시스템)
4. [타이포그래피](#타이포그래피)
5. [컴포넌트](#컴포넌트)
6. [접근성](#접근성)
7. [사용 예시](#사용-예시)

---

## 설계 원칙

| 원칙 | 내용 |
|------|------|
| **애니메이션** | 200ms 이하, transform/opacity만 사용 (GPU 최적화) |
| **그림자** | 두 계층 (ambient + direct) - 자연스러운 깊이감 |
| **로딩** | 스켈레톤 UI 사용 (스피너 X) |
| **빈 상태** | 단일 CTA 버튼만 제공 |
| **숫자** | Tabular figures로 정렬 일관성 유지 |
| **터치** | 최소 44px 터치 타겟 |
| **접근성** | prefers-reduced-motion 존중 |

---

## 애니메이션

### `DSAnimations`

모든 애니메이션은 200ms 이하로 제한하여 즉각적인 피드백을 제공합니다.

```dart
abstract final class DSAnimations {
  /// 빠른 피드백 (탭, 호버)
  static const Duration fast = Duration(milliseconds: 100);

  /// 기본 전환
  static const Duration normal = Duration(milliseconds: 150);

  /// 느린 전환 (모달, 페이지)
  static const Duration slow = Duration(milliseconds: 200);

  /// 기본 커브
  static const Curve defaultCurve = Curves.easeOut;

  /// 진입 커브
  static const Curve enterCurve = Curves.easeOutCubic;

  /// 퇴장 커브
  static const Curve exitCurve = Curves.easeInCubic;
}
```

### 사용 가이드

| 상황 | Duration | Curve |
|------|----------|-------|
| 버튼 탭 피드백 | `fast` (100ms) | `defaultCurve` |
| 카드 등장 | `normal` (150ms) | `enterCurve` |
| 모달 열기/닫기 | `slow` (200ms) | `enterCurve` / `exitCurve` |
| 페이지 전환 | `slow` (200ms) | `enterCurve` |

---

## 그림자 시스템

### `DSShadows`

두 계층 그림자 (주변광 + 직광)로 자연스러운 깊이감을 표현합니다.

```dart
abstract final class DSShadows {
  /// 낮은 고도 (카드 기본)
  static List<BoxShadow> low(BuildContext context);

  /// 중간 고도 (호버, 포커스)
  static List<BoxShadow> medium(BuildContext context);

  /// 높은 고도 (모달, 드롭다운)
  static List<BoxShadow> high(BuildContext context);
}
```

### 그림자 레벨별 상세

| 레벨 | 용도 | Ambient | Direct |
|------|------|---------|--------|
| `low` | 카드 기본 상태 | blur 8, offset (0, 2) | blur 3, offset (0, 1) |
| `medium` | 호버, 포커스 상태 | blur 16, offset (0, 4) | blur 6, offset (0, 2) |
| `high` | 모달, 드롭다운 | blur 24, offset (0, 8) | blur 8, offset (0, 4) |

### 다크모드 대응

모든 그림자 함수는 `BuildContext`를 받아 자동으로 다크모드를 감지합니다.

```dart
// 라이트 모드: 투명도 낮음 (0.04 ~ 0.12)
// 다크 모드: 투명도 높음 (0.2 ~ 0.5)
final isDark = Theme.of(context).brightness == Brightness.dark;
```

---

## 타이포그래피

### `DSTypography` Extension

숫자가 포함된 UI에서 정렬 일관성을 위한 tabular figures 확장입니다.

```dart
extension DSTypography on TextStyle {
  /// 테이블 숫자 (고정폭 숫자)
  TextStyle get tabularFigures => copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// 숫자 + 볼드
  TextStyle get tabularBold => copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
    fontWeight: FontWeight.bold,
  );
}
```

### 사용 예시

```dart
// 스트릭 카운터
Text(
  '365',
  style: context.textTheme.titleLarge?.tabularFigures,
)

// 통계 숫자
Text(
  '1,234',
  style: context.textTheme.headlineMedium?.tabularBold,
)
```

---

## 컴포넌트

### `DSInteractive`

터치 피드백을 제공하는 래퍼 위젯입니다.

```dart
DSInteractive(
  onTap: () => print('Tapped!'),
  onLongPress: () => print('Long pressed!'),
  borderRadius: BorderRadius.circular(12),
  child: MyCard(),
)
```

**특징:**
- Scale 애니메이션 (1.0 → 0.98)
- Haptic feedback (lightImpact)
- prefers-reduced-motion 존중

---

### `DSSkeleton`

로딩 상태를 위한 스켈레톤 위젯입니다.

```dart
// 기본 사용
DSSkeleton(
  width: 120,
  height: 20,
  borderRadius: BorderRadius.circular(4),
)

// 원형 스켈레톤
DSSkeleton.circle(size: 48)
```

**특징:**
- Shimmer 애니메이션 (1.5초 주기)
- 다크모드 자동 대응
- prefers-reduced-motion 존중

---

### `DSEmptyState`

빈 상태를 표시하는 위젯입니다.

```dart
DSEmptyState(
  icon: Icons.book_outlined,
  title: '아직 책이 없어요',
  description: '첫 번째 책을 추가해보세요',
  actionLabel: '책 추가하기',
  onAction: () => Navigator.push(...),
)
```

**특징:**
- 단일 CTA 버튼 원칙
- 선택적 description
- 선택적 action

---

### `DSFadeIn`

등장 애니메이션을 제공하는 래퍼 위젯입니다.

```dart
DSFadeIn(
  delay: Duration(milliseconds: 100),  // 선택적 지연
  duration: DSAnimations.normal,       // 기본 150ms
  child: MyWidget(),
)
```

**특징:**
- Fade + Scale (0.95 → 1.0) 조합
- 지연 시작 지원
- prefers-reduced-motion 존중

---

### `DSAccessible`

접근성을 위한 Semantics 래퍼입니다.

```dart
DSAccessible(
  label: '연속 7일 독서 중',
  hint: '오늘 독서 완료',
  isButton: false,
  isHeader: false,
  child: StreakCard(),
)
```

**특징:**
- Semantics 간편 적용
- 스크린 리더 지원
- 선택적 onTap 핸들러

---

## 접근성

### prefers-reduced-motion

모든 애니메이션 컴포넌트는 시스템의 "동작 줄이기" 설정을 존중합니다.

```dart
@override
Widget build(BuildContext context) {
  final reduceMotion = MediaQuery.of(context).disableAnimations;

  if (reduceMotion) {
    return widget.child;  // 애니메이션 없이 바로 표시
  }

  return AnimatedWidget(...);
}
```

### 터치 타겟

모든 인터랙티브 요소는 최소 44x44px 터치 타겟을 유지합니다.

```dart
FilledButton.tonal(
  style: FilledButton.styleFrom(
    minimumSize: const Size(44, 44),  // 최소 터치 타겟
  ),
  child: Text('시작'),
)
```

---

## 사용 예시

### 카드 컴포넌트

```dart
class MyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DSFadeIn(
      child: DSAccessible(
        label: '내 카드',
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: DSShadows.low(context),
          ),
          child: Column(
            children: [
              Text(
                '1,234',
                style: context.textTheme.headlineMedium?.tabularBold,
              ),
              Text('총 독서량'),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 로딩 상태

```dart
Widget build(BuildContext context) {
  return dataAsync.when(
    loading: () => DSSkeleton(
      width: double.infinity,
      height: 100,
      borderRadius: BorderRadius.circular(16),
    ),
    error: (_, __) => const SizedBox.shrink(),
    data: (data) => DSFadeIn(
      child: MyDataWidget(data: data),
    ),
  );
}
```

### 인터랙티브 카드

```dart
DSInteractive(
  onTap: () => navigateToDetail(),
  borderRadius: BorderRadius.circular(16),
  child: Container(
    decoration: BoxDecoration(
      boxShadow: DSShadows.low(context),
    ),
    child: MyCardContent(),
  ),
)
```

---

## 적용 현황

| 위젯 | 상태 | 적용 항목 |
|------|------|----------|
| `StreakCard` | ✅ 완료 | DSShadows, DSSkeleton, DSFadeIn, DSAccessible, tabularFigures |
| `BookCard` | ⏳ 미적용 | - |
| `NoteCard` | ⏳ 미적용 | - |
| `ActivityCalendar` | ⏳ 미적용 | - |

---

## 참고 자료

- [Vercel Design Guidelines](https://vercel.com/design/guidelines)
- [UI Skills](https://www.ui-skills.com/)
- [Material 3 Design](https://m3.material.io/)
