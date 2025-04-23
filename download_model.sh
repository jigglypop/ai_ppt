#!/bin/bash
# BitNet 모델 다운로드 스크립트

# 색상 설정
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}BitNet 모델 다운로드 스크립트${NC}"
echo "==============================="

# 모델 저장 디렉토리
MODEL_DIR="models/BitNet-b1.58-2B-4T"

# 디렉토리 생성
mkdir -p ${MODEL_DIR}

# 필수 도구 체크
echo -e "${YELLOW}필수 도구 확인 중...${NC}"
command -v git >/dev/null 2>&1 || { echo -e "${RED}오류: git이 설치되어 있지 않습니다.${NC}"; exit 1; }
command -v python >/dev/null 2>&1 || { echo -e "${RED}오류: python이 설치되어 있지 않습니다.${NC}"; exit 1; }

echo -e "${GREEN}필수 도구가 설치되어 있습니다.${NC}"

# huggingface-cli 설치 확인
if ! command -v huggingface-cli &> /dev/null; then
    echo -e "${YELLOW}huggingface-cli 설치 중...${NC}"
    pip install huggingface_hub
fi

echo -e "${YELLOW}BitNet 모델 다운로드 중...${NC}"
huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf --local-dir ${MODEL_DIR}

if [ $? -ne 0 ]; then
    echo -e "${RED}모델 다운로드에 실패했습니다.${NC}"
    
    echo -e "${YELLOW}BitNet 레퍼런스 저장소에서 더미 모델 생성을 시도합니다...${NC}"
    
    # BitNet 저장소가 없으면 클론
    if [ ! -d "BitNet" ]; then
        echo -e "${YELLOW}BitNet 저장소 클론 중...${NC}"
        git clone --recursive https://github.com/microsoft/BitNet.git
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}BitNet 저장소 클론에 실패했습니다.${NC}"
            exit 1
        fi
    fi
    
    # 더미 모델 생성
    echo -e "${YELLOW}더미 모델 생성 중...${NC}"
    python BitNet/utils/generate-dummy-bitnet-model.py ${MODEL_DIR} --outfile ${MODEL_DIR}/ggml-model-i2_s.gguf --outtype i2_s --model-size 125M
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}더미 모델 생성에 실패했습니다.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}더미 모델 생성 완료: ${MODEL_DIR}/ggml-model-i2_s.gguf${NC}"
else
    echo -e "${GREEN}모델 다운로드 완료: ${MODEL_DIR}${NC}"
fi

echo -e "${BLUE}서버 실행 시 다음 모델 경로를 사용하세요:${NC}"
echo "${MODEL_DIR}/ggml-model-i2_s.gguf"
echo "" 