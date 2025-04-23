#!/bin/bash
# BitNet.cpp 설치 및 설정 스크립트

# 색상 설정
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}BitNet.cpp 설치 및 설정 스크립트${NC}"
echo "==============================="

# 작업 디렉토리 설정
WORK_DIR="bitnet-cpp"
mkdir -p $WORK_DIR
cd $WORK_DIR

# 필수 도구 체크
echo -e "${YELLOW}필수 도구 확인 중...${NC}"
command -v git >/dev/null 2>&1 || { echo -e "${RED}오류: git이 설치되어 있지 않습니다.${NC}"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo -e "${RED}오류: python3가 설치되어 있지 않습니다.${NC}"; exit 1; }
command -v pip >/dev/null 2>&1 || { echo -e "${RED}오류: pip가 설치되어 있지 않습니다.${NC}"; exit 1; }
command -v cmake >/dev/null 2>&1 || { echo -e "${RED}오류: cmake가 설치되어 있지 않습니다.${NC}"; exit 1; }

echo -e "${GREEN}필수 도구가 설치되어 있습니다.${NC}"

# BitNet 저장소 클론
echo -e "${YELLOW}BitNet 저장소 클론 중...${NC}"
if [ ! -d "BitNet" ]; then
    git clone --recursive https://github.com/microsoft/BitNet.git
    if [ $? -ne 0 ]; then
        echo -e "${RED}BitNet 저장소 클론에 실패했습니다.${NC}"
        exit 1
    fi
    echo -e "${GREEN}BitNet 저장소 클론 완료.${NC}"
else
    echo -e "${GREEN}BitNet 저장소가 이미 존재합니다.${NC}"
    cd BitNet
    git pull
    cd ..
fi

# Python 가상 환경 설정
echo -e "${YELLOW}Python 가상 환경 설정 중...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}가상 환경 생성 완료.${NC}"
else
    echo -e "${GREEN}가상 환경이 이미 존재합니다.${NC}"
fi

# 가상 환경 활성화
echo -e "${YELLOW}가상 환경 활성화 중...${NC}"
source venv/bin/activate
if [ $? -ne 0 ]; then
    echo -e "${RED}가상 환경 활성화에 실패했습니다.${NC}"
    exit 1
fi
echo -e "${GREEN}가상 환경 활성화 완료.${NC}"

# 의존성 설치
echo -e "${YELLOW}필요한 패키지 설치 중...${NC}"
cd BitNet
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo -e "${RED}패키지 설치에 실패했습니다.${NC}"
    exit 1
fi
echo -e "${GREEN}패키지 설치 완료.${NC}"

# 테스트용 모델 다운로드
echo -e "${YELLOW}테스트용 더미 모델 생성 중...${NC}"
mkdir -p models
python utils/generate-dummy-bitnet-model.py models/bitnet_b1_58-large --outfile models/dummy-bitnet-125m.i2_s.gguf --outtype i2_s --model-size 125M
if [ $? -ne 0 ]; then
    echo -e "${RED}더미 모델 생성에 실패했습니다.${NC}"
    exit 1
fi
echo -e "${GREEN}더미 모델 생성 완료.${NC}"

# 벤치마크 실행
echo -e "${YELLOW}벤치마크 실행 중...${NC}"
python utils/e2e_benchmark.py -m models/dummy-bitnet-125m.i2_s.gguf -p 64 -n 32 -t 2
if [ $? -ne 0 ]; then
    echo -e "${RED}벤치마크 실행에 실패했습니다.${NC}"
    exit 1
fi
echo -e "${GREEN}벤치마크 실행 완료.${NC}"

# 마무리
cd ../..
echo -e "${BLUE}BitNet.cpp 설치 및 설정이 완료되었습니다.${NC}"
echo -e "${YELLOW}사용 방법:${NC}"
echo "  cd $WORK_DIR/BitNet"
echo "  source ../venv/bin/activate"
echo "  python run_inference.py -m models/dummy-bitnet-125m.i2_s.gguf -p \"안녕하세요, 당신은 누구인가요?\" -n 100"
echo ""
echo -e "${YELLOW}실제 모델 다운로드:${NC}"
echo "  huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf --local-dir models/BitNet-b1.58-2B-4T"
echo "" 