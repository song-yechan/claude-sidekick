#!/bin/bash
# Coverage Report Generator
# 테스트 커버리지 리포트를 생성합니다.
#
# 사용법:
#   ./scripts/coverage.sh          # 테스트 실행 + HTML 리포트 생성
#   ./scripts/coverage.sh --open   # 리포트 생성 후 브라우저에서 열기
#   ./scripts/coverage.sh --ci     # CI 모드 (HTML 생성 안함, 요약만 출력)

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 스크립트 디렉토리 기준으로 app 디렉토리로 이동
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
cd "$APP_DIR"

# 옵션 파싱
OPEN_BROWSER=false
CI_MODE=false
for arg in "$@"; do
    case $arg in
        --open)
            OPEN_BROWSER=true
            ;;
        --ci)
            CI_MODE=true
            ;;
    esac
done

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}     Flutter Test Coverage Report${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# lcov 설치 확인
if ! command -v lcov &> /dev/null; then
    echo -e "${RED}Error: lcov is not installed${NC}"
    echo "Install with: brew install lcov"
    exit 1
fi

if ! command -v genhtml &> /dev/null; then
    echo -e "${RED}Error: genhtml is not installed${NC}"
    echo "Install with: brew install lcov"
    exit 1
fi

# 기존 coverage 폴더 정리
echo -e "${YELLOW}[1/4] Cleaning previous coverage data...${NC}"
rm -rf coverage/
mkdir -p coverage

# 테스트 실행 및 coverage 수집
echo -e "${YELLOW}[2/4] Running tests with coverage...${NC}"
flutter test --coverage 2>&1 | while IFS= read -r line; do
    # 진행 상황만 간단히 출력
    if [[ "$line" =~ \+([0-9]+): ]]; then
        echo -ne "\r  Tests passed: ${BASH_REMATCH[1]}  "
    fi
done
echo ""

# coverage 파일 존재 확인
if [ ! -f "coverage/lcov.info" ]; then
    echo -e "${RED}Error: coverage/lcov.info not found${NC}"
    echo "Test might have failed. Run 'flutter test' to check."
    exit 1
fi

# 불필요한 파일 필터링 (생성된 파일, 테스트 파일 등)
echo -e "${YELLOW}[3/4] Filtering coverage data...${NC}"
lcov --remove coverage/lcov.info \
    '*/test/*' \
    '*/.dart_tool/*' \
    '*/generated/*' \
    '*.g.dart' \
    '*.freezed.dart' \
    '*.mocks.dart' \
    -o coverage/lcov_filtered.info \
    --ignore-errors unused,unused \
    -q 2>/dev/null || true

# 필터링된 파일 사용
mv coverage/lcov_filtered.info coverage/lcov.info

# Coverage 요약 출력
echo ""
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}          Coverage Summary${NC}"
echo -e "${BLUE}======================================${NC}"

# lcov로 요약 정보 추출
SUMMARY=$(lcov --summary coverage/lcov.info 2>&1)

# Lines 커버리지 추출
LINES_COV=$(echo "$SUMMARY" | grep -E "lines\.*:" | head -1)
if [ -n "$LINES_COV" ]; then
    # 퍼센트 추출
    PERCENT=$(echo "$LINES_COV" | grep -oE '[0-9]+\.[0-9]+%' | head -1)
    PERCENT_NUM=$(echo "$PERCENT" | tr -d '%')

    # 색상 결정 (80% 이상: 녹색, 60% 이상: 노란색, 미만: 빨간색)
    if (( $(echo "$PERCENT_NUM >= 80" | bc -l) )); then
        COLOR=$GREEN
    elif (( $(echo "$PERCENT_NUM >= 60" | bc -l) )); then
        COLOR=$YELLOW
    else
        COLOR=$RED
    fi

    echo -e "  Lines:     ${COLOR}${PERCENT}${NC}"
fi

# Functions 커버리지 추출
FUNCS_COV=$(echo "$SUMMARY" | grep -E "functions\.*:" | head -1)
if [ -n "$FUNCS_COV" ]; then
    PERCENT=$(echo "$FUNCS_COV" | grep -oE '[0-9]+\.[0-9]+%' | head -1)
    echo -e "  Functions: ${PERCENT}"
fi

# Branches 커버리지 추출
BRANCH_COV=$(echo "$SUMMARY" | grep -E "branches\.*:" | head -1)
if [ -n "$BRANCH_COV" ]; then
    PERCENT=$(echo "$BRANCH_COV" | grep -oE '[0-9]+\.[0-9]+%' | head -1)
    echo -e "  Branches:  ${PERCENT}"
fi

echo -e "${BLUE}======================================${NC}"

# CI 모드가 아닌 경우 HTML 리포트 생성
if [ "$CI_MODE" = false ]; then
    echo ""
    echo -e "${YELLOW}[4/4] Generating HTML report...${NC}"
    genhtml coverage/lcov.info \
        -o coverage/html \
        --title "BookScribe Test Coverage" \
        --legend \
        --ignore-errors deprecated \
        -q

    echo -e "${GREEN}HTML report generated: coverage/html/index.html${NC}"

    # 브라우저에서 열기
    if [ "$OPEN_BROWSER" = true ]; then
        echo "Opening in browser..."
        open coverage/html/index.html
    fi
else
    echo ""
    echo -e "${GREEN}[4/4] CI mode - skipping HTML generation${NC}"
fi

echo ""
echo -e "${GREEN}Done!${NC}"
