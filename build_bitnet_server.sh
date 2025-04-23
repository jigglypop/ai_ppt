#!/bin/bash
# BitNet REST API 서버 빌드 및 실행 스크립트

# 색상 설정
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}BitNet REST API 서버 빌드 스크립트${NC}"
echo "========================================"

# 필수 도구 체크
echo -e "${YELLOW}필수 도구 확인 중...${NC}"
command -v git >/dev/null 2>&1 || { echo -e "${RED}오류: git이 설치되어 있지 않습니다.${NC}"; exit 1; }
command -v cmake >/dev/null 2>&1 || { echo -e "${RED}오류: cmake가 설치되어 있지 않습니다.${NC}"; exit 1; }
command -v make >/dev/null 2>&1 || { echo -e "${RED}오류: make가 설치되어 있지 않습니다.${NC}"; exit 1; }
command -v g++ >/dev/null 2>&1 || { echo -e "${RED}오류: g++이 설치되어 있지 않습니다.${NC}"; exit 1; }

echo -e "${GREEN}필수 도구가 설치되어 있습니다.${NC}"

# 현재 디렉토리 저장
CURRENT_DIR=$(pwd)

# 빌드 디렉토리 생성
BUILD_DIR="${CURRENT_DIR}/build"
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

# CMake 프로젝트 설정
echo -e "${YELLOW}CMake 프로젝트 설정 중...${NC}"
cmake -DCMAKE_BUILD_TYPE=Release ..

if [ $? -ne 0 ]; then
    echo -e "${RED}CMake 구성에 실패했습니다.${NC}"
    cd ${CURRENT_DIR}
    exit 1
fi

# 빌드 시작
echo -e "${YELLOW}빌드 중...${NC}"
make -j$(nproc) bitnet_server

if [ $? -ne 0 ]; then
    echo -e "${RED}빌드에 실패했습니다.${NC}"
    cd ${CURRENT_DIR}
    exit 1
fi

echo -e "${GREEN}BitNet REST API 서버 빌드에 성공했습니다!${NC}"

# 서버 정보 표시
echo -e "${BLUE}서버 실행 방법:${NC}"
echo "./bitnet_server [--port 포트번호] [--model 모델경로] [--threads 스레드수]"
echo ""
echo -e "${YELLOW}기본 옵션:${NC}"
echo "- 포트: 8080"
echo "- 모델: models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf"
echo "- 스레드: $(nproc)"
echo ""
echo -e "${YELLOW}예시:${NC}"
echo "./bitnet_server --port 8080 --model ../models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf --threads 4"
echo ""

# 사용자에게 서버 실행 여부 묻기
read -p "서버를 지금 실행할까요? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}BitNet REST API 서버 실행 중...${NC}"
    ./bitnet_server
else
    echo -e "${BLUE}빌드 디렉토리에서 './bitnet_server'를 실행하여 서버를 시작할 수 있습니다.${NC}"
fi

# 원래 디렉토리로 돌아가기
cd ${CURRENT_DIR} 