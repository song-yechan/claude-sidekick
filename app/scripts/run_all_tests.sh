#!/bin/bash
# 통합 테스트 러너 스크립트
#
# Flutter 단위 테스트와 Edge Function 통합 테스트를 모두 실행합니다.
#
# 사용법: ./scripts/run_all_tests.sh [options]
#
# 옵션:
#   --unit-only      Flutter 단위 테스트만 실행
#   --edge-only      Edge Function 테스트만 실행
#   --verbose        상세 출력
#   --help           도움말

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 프로젝트 루트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 기본 옵션
RUN_UNIT=true
RUN_EDGE=true
VERBOSE=false

# 명령줄 인자 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        --unit-only)
            RUN_EDGE=false
            shift
            ;;
        --edge-only)
            RUN_UNIT=false
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            echo "사용법: ./scripts/run_all_tests.sh [options]"
            echo ""
            echo "옵션:"
            echo "  --unit-only      Flutter 단위 테스트만 실행"
            echo "  --edge-only      Edge Function 테스트만 실행"
            echo "  --verbose        상세 출력"
            echo "  --help           도움말"
            exit 0
            ;;
        *)
            echo "알 수 없는 옵션: $1"
            echo "./scripts/run_all_tests.sh --help 로 도움말을 확인하세요."
            exit 1
            ;;
    esac
done

# 결과 저장
UNIT_RESULT=0
EDGE_RESULT=0

echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      BookScribe 통합 테스트 러너       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "프로젝트: $PROJECT_ROOT"
echo "시간: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ========================================
# Flutter 단위 테스트
# ========================================
if [ "$RUN_UNIT" = true ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  1. Flutter 단위 테스트${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    cd "$PROJECT_ROOT"

    if [ "$VERBOSE" = true ]; then
        flutter test --reporter expanded || UNIT_RESULT=$?
    else
        flutter test || UNIT_RESULT=$?
    fi

    echo ""
    if [ $UNIT_RESULT -eq 0 ]; then
        echo -e "${GREEN}✓ Flutter 단위 테스트 통과${NC}"
    else
        echo -e "${RED}✗ Flutter 단위 테스트 실패${NC}"
    fi
    echo ""
fi

# ========================================
# Edge Function 통합 테스트
# ========================================
if [ "$RUN_EDGE" = true ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  2. Edge Function 통합 테스트${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ -f "$SCRIPT_DIR/test_edge_functions.sh" ]; then
        bash "$SCRIPT_DIR/test_edge_functions.sh" || EDGE_RESULT=$?
    else
        echo -e "${YELLOW}⚠ test_edge_functions.sh 파일을 찾을 수 없습니다${NC}"
        EDGE_RESULT=1
    fi

    echo ""
    if [ $EDGE_RESULT -eq 0 ]; then
        echo -e "${GREEN}✓ Edge Function 테스트 통과${NC}"
    else
        echo -e "${RED}✗ Edge Function 테스트 실패${NC}"
    fi
    echo ""
fi

# ========================================
# 최종 결과 요약
# ========================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  최종 결과 요약${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$RUN_UNIT" = true ]; then
    if [ $UNIT_RESULT -eq 0 ]; then
        echo -e "  Flutter 단위 테스트:    ${GREEN}✓ PASS${NC}"
    else
        echo -e "  Flutter 단위 테스트:    ${RED}✗ FAIL${NC}"
    fi
fi

if [ "$RUN_EDGE" = true ]; then
    if [ $EDGE_RESULT -eq 0 ]; then
        echo -e "  Edge Function 테스트:   ${GREEN}✓ PASS${NC}"
    else
        echo -e "  Edge Function 테스트:   ${RED}✗ FAIL${NC}"
    fi
fi

echo ""

# 최종 종료 코드 결정
FINAL_RESULT=$((UNIT_RESULT + EDGE_RESULT))
if [ $FINAL_RESULT -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         모든 테스트 통과!              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║         일부 테스트 실패               ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    exit 1
fi
