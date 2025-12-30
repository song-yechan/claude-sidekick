/// 앱 상수 정의
///
/// 앱 전역에서 사용되는 상수값들을 정의합니다.
/// 색상, 크기, 문자열 등의 상수를 중앙에서 관리합니다.
library;

/// 책 한 권당 최대 카테고리 개수
///
/// 사용자가 책에 할당할 수 있는 카테고리의 최대 개수입니다.
const int maxCategoriesPerBook = 4;

/// 카테고리 색상 팔레트
///
/// 새 카테고리 생성 시 순서대로 자동 할당되는 색상들입니다.
/// Tailwind CSS 색상 팔레트를 기반으로 합니다.
/// 색상은 HEX 형식의 문자열로 저장됩니다.
const List<String> categoryColors = [
  '#ef4444', // red-500
  '#f97316', // orange-500
  '#f59e0b', // amber-500
  '#84cc16', // lime-500
  '#10b981', // emerald-500
  '#06b6d4', // cyan-500
  '#3b82f6', // blue-500
  '#8b5cf6', // violet-500
  '#ec4899', // pink-500
];
