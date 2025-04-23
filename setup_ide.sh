#!/bin/bash
# IDE 설정 스크립트 - 종속성 다운로드

# 색상 설정
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}IDE 설정 스크립트 - 종속성 다운로드${NC}"
echo "========================================"

# 필수 도구 체크
echo -e "${YELLOW}필수 도구 확인 중...${NC}"
command -v git >/dev/null 2>&1 || { echo -e "${RED}오류: git이 설치되어 있지 않습니다.${NC}"; exit 1; }
command -v mkdir >/dev/null 2>&1 || { echo -e "${RED}오류: 기본 명령어가 누락되었습니다.${NC}"; exit 1; }

echo -e "${GREEN}필수 도구가 설치되어 있습니다.${NC}"

# 작업 디렉토리 생성
DEPS_DIR="./deps"
mkdir -p ${DEPS_DIR}

# BitNet 저장소 클론
if [ ! -d "BitNet" ]; then
    echo -e "${YELLOW}BitNet 저장소 클론 중...${NC}"
    git clone --recursive https://github.com/microsoft/BitNet.git
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}BitNet 저장소 클론에 실패했습니다.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}BitNet 저장소 클론 완료${NC}"
else
    echo -e "${GREEN}BitNet 저장소가 이미 존재합니다.${NC}"
fi

# nlohmann/json 라이브러리 클론
if [ ! -d "${DEPS_DIR}/json" ]; then
    echo -e "${YELLOW}nlohmann/json 라이브러리 클론 중...${NC}"
    git clone https://github.com/nlohmann/json.git ${DEPS_DIR}/json
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}nlohmann/json 라이브러리 클론에 실패했습니다.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}nlohmann/json 라이브러리 클론 완료${NC}"
else
    echo -e "${GREEN}nlohmann/json 라이브러리가 이미 존재합니다.${NC}"
fi

# cpp-httplib 라이브러리 클론
if [ ! -d "${DEPS_DIR}/httplib" ]; then
    echo -e "${YELLOW}cpp-httplib 라이브러리 클론 중...${NC}"
    git clone https://github.com/yhirose/cpp-httplib.git ${DEPS_DIR}/httplib
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}cpp-httplib 라이브러리 클론에 실패했습니다.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}cpp-httplib 라이브러리 클론 완료${NC}"
else
    echo -e "${GREEN}cpp-httplib 라이브러리가 이미 존재합니다.${NC}"
fi

# Include 경로 링크 (심볼릭 링크 생성)
echo -e "${YELLOW}IDE를 위한 include 디렉토리 생성 중...${NC}"
mkdir -p include

# nlohmann/json 헤더 링크
mkdir -p include/nlohmann
cp ${DEPS_DIR}/json/include/nlohmann/json.hpp include/nlohmann/

# cpp-httplib 헤더 링크
cp ${DEPS_DIR}/httplib/httplib.h include/

# BitNet 헤더 링크
cp BitNet/llamacpp/llama.h include/
cp BitNet/llamacpp/common/common.h include/
cp BitNet/llamacpp/common/grammar-parser.h include/

echo -e "${GREEN}IDE 설정 완료!${NC}"
echo -e "${BLUE}이제 IDE에서 헤더 파일을 찾을 수 있습니다.${NC}" 