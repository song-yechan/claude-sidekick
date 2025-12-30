#!/bin/bash
# Edge Function 통합 테스트 스크립트
#
# Supabase Edge Functions를 실제로 호출하여 동작을 검증합니다.
# book-search와 ocr-image 함수를 테스트합니다.
#
# 사용법: ./scripts/test_edge_functions.sh

# 모든 테스트 실행 (중간 에러에서 멈추지 않음)
set +e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 프로젝트 루트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# .env 파일에서 환경변수 로드
if [ -f "$PROJECT_ROOT/.env" ]; then
    while IFS='=' read -r key value; do
        # 주석과 빈 줄 무시
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        # 따옴표 제거
        value="${value%\"}"
        value="${value#\"}"
        export "$key=$value"
    done < "$PROJECT_ROOT/.env"
fi

# 필수 환경변수 확인
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}Error: SUPABASE_URL and SUPABASE_ANON_KEY must be set${NC}"
    echo "Please check your .env file"
    exit 1
fi

FUNCTIONS_URL="$SUPABASE_URL/functions/v1"

# 테스트 결과 카운터
PASSED=0
FAILED=0

# 테스트 결과 출력 함수
print_result() {
    local test_name="$1"
    local success="$2"
    local message="$3"

    if [ "$success" = "true" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo -e "  ${YELLOW}$message${NC}"
        ((FAILED++))
    fi
}

# JSON 응답에서 필드 추출
extract_json_field() {
    local json="$1"
    local field="$2"
    echo "$json" | grep -o "\"$field\":[^,}]*" | sed 's/"'"$field"'"://' | tr -d '"' | tr -d ' '
}

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Edge Function 통합 테스트${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Functions URL: $FUNCTIONS_URL"
echo ""

# ========================================
# book-search 함수 테스트
# ========================================
echo -e "${YELLOW}[book-search 함수 테스트]${NC}"
echo ""

# 테스트 1: 정상적인 검색 요청
echo "테스트 1: 정상적인 검색 요청 ('해리포터')..."
RESPONSE=$(curl -s -m 60 -w "\n%{http_code}" -X POST "$FUNCTIONS_URL/book-search" \
    -H "Content-Type: application/json" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    -d "{\"query\":\"해리포터\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    # items 배열이 있는지 확인
    if echo "$BODY" | grep -q '"items"'; then
        print_result "book-search: 정상 검색" "true"
    else
        print_result "book-search: 정상 검색" "false" "응답에 items 필드가 없음: $BODY"
    fi
else
    print_result "book-search: 정상 검색" "false" "HTTP $HTTP_CODE: $BODY"
fi

# 테스트 2: 빈 검색어
echo "테스트 2: 빈 검색어..."
RESPONSE=$(curl -s -m 60 -w "\n%{http_code}" -X POST "$FUNCTIONS_URL/book-search" \
    -H "Content-Type: application/json" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    -d "{\"query\":\"\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# 빈 검색어는 400 에러 또는 빈 결과를 반환해야 함
if [ "$HTTP_CODE" = "400" ] || ([ "$HTTP_CODE" = "200" ] && echo "$BODY" | grep -q '"items":\[\]'); then
    print_result "book-search: 빈 검색어 처리" "true"
else
    print_result "book-search: 빈 검색어 처리" "false" "HTTP $HTTP_CODE: $BODY"
fi

# 테스트 3: 영문 검색어
echo "테스트 3: 영문 검색어 ('Flutter')..."
RESPONSE=$(curl -s -m 60 -w "\n%{http_code}" -X POST "$FUNCTIONS_URL/book-search" \
    -H "Content-Type: application/json" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    -d "{\"query\":\"Flutter\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ] && echo "$BODY" | grep -q '"items"'; then
    print_result "book-search: 영문 검색" "true"
else
    print_result "book-search: 영문 검색" "false" "HTTP $HTTP_CODE: $BODY"
fi

# 테스트 4: API 키 없이 요청 (book-search는 자체 API 키 검증 수행)
echo "테스트 4: API 키 없이 요청..."
RESPONSE=$(curl -s -m 60 -w "\n%{http_code}" -X POST "$FUNCTIONS_URL/book-search" \
    -H "Content-Type: application/json" \
    -d "{\"query\":\"테스트\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# book-search는 알라딘 API 호출을 위해 apikey 헤더 필요
# 401 응답이 정상 (API key required)
if [ "$HTTP_CODE" = "401" ]; then
    print_result "book-search: API 키 검증" "true"
else
    print_result "book-search: API 키 검증" "false" "예상: 401, 실제: HTTP $HTTP_CODE"
fi

echo ""

# ========================================
# ocr-image 함수 테스트
# ========================================
echo -e "${YELLOW}[ocr-image 함수 테스트]${NC}"
echo ""

# 테스트용 간단한 이미지 (1x1 흰색 PNG를 base64로 인코딩)
# 실제 OCR 테스트를 위해서는 텍스트가 포함된 이미지가 필요함
TEST_IMAGE_BASE64="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

# 테스트 5: OCR 요청 (기본)
echo "테스트 5: OCR 함수 호출..."
RESPONSE=$(curl -s -m 60 -w "\n%{http_code}" -X POST "$FUNCTIONS_URL/ocr-image" \
    -H "Content-Type: application/json" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    -d "{\"imageBase64\":\"$TEST_IMAGE_BASE64\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# OCR 함수가 응답하는지 확인 (1x1 이미지라 텍스트는 없을 수 있음)
if [ "$HTTP_CODE" = "200" ]; then
    if echo "$BODY" | grep -q '"text"'; then
        print_result "ocr-image: 함수 호출" "true"
    else
        print_result "ocr-image: 함수 호출" "false" "응답에 text 필드가 없음: $BODY"
    fi
else
    # OCR API 제한으로 인한 에러일 수 있음
    if [ "$HTTP_CODE" = "429" ]; then
        print_result "ocr-image: 함수 호출" "true" "Rate limit (예상된 동작)"
    else
        print_result "ocr-image: 함수 호출" "false" "HTTP $HTTP_CODE: $BODY"
    fi
fi

# 테스트 6: 빈 이미지 데이터
echo "테스트 6: 빈 이미지 데이터..."
RESPONSE=$(curl -s -m 60 -w "\n%{http_code}" -X POST "$FUNCTIONS_URL/ocr-image" \
    -H "Content-Type: application/json" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    -d "{\"imageBase64\":\"\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# 빈 이미지는 400 에러를 반환해야 함
if [ "$HTTP_CODE" = "400" ]; then
    print_result "ocr-image: 빈 이미지 검증" "true"
else
    print_result "ocr-image: 빈 이미지 검증" "false" "HTTP $HTTP_CODE: $BODY"
fi

# 테스트 7: API 키 없이 요청 (--no-verify-jwt로 배포되어 인증 없이 접근 가능)
echo "테스트 7: API 키 없이 요청..."
RESPONSE=$(curl -s -m 60 -w "\n%{http_code}" -X POST "$FUNCTIONS_URL/ocr-image" \
    -H "Content-Type: application/json" \
    -d "{\"imageBase64\":\"$TEST_IMAGE_BASE64\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# Edge Functions은 --no-verify-jwt로 배포되어 인증 없이 접근 가능
if [ "$HTTP_CODE" = "200" ] && echo "$BODY" | grep -q '"text"'; then
    print_result "ocr-image: JWT 미검증 모드" "true"
else
    print_result "ocr-image: JWT 미검증 모드" "false" "HTTP $HTTP_CODE: $BODY"
fi

echo ""

# ========================================
# 테스트 결과 요약
# ========================================
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  테스트 결과 요약${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
TOTAL=$((PASSED + FAILED))
echo -e "총 테스트: $TOTAL"
echo -e "${GREEN}통과: $PASSED${NC}"
echo -e "${RED}실패: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}모든 테스트 통과!${NC}"
    exit 0
else
    echo -e "${RED}일부 테스트 실패${NC}"
    exit 1
fi
