# BitNet.cpp

## 개요
BitNet.cpp는 1비트 LLM(대규모 언어 모델)을 위한 공식 추론 프레임워크입니다. CPU에서 빠르고 손실 없는 1.58비트 모델 추론을 지원하는 최적화된 커널을 제공합니다(NPU 및 GPU 지원 예정).

## 특징
- CPU에서 빠른 추론 속도 (ARM CPU에서 1.37x-5.07x 속도 향상)
- 에너지 소비 감소 (55.4%-70.0%)
- x86 CPU에서 2.37x-6.17x 속도 향상, 71.9%-82.2% 에너지 감소
- 단일 CPU에서 100B BitNet b1.58 모델 실행 가능 (초당 5-7 토큰, 사람 읽기 속도와 유사)

## 설치 방법

### 요구 사항
- python >= 3.9
- cmake >= 3.22
- clang >= 18

### 윈도우 사용자
Visual Studio 2022를 설치하고 다음 옵션을 활성화하세요:
- C++를 사용한 데스크톱 개발
- C++ CMake 도구
- Git for Windows
- C++ Clang 컴파일러
- LLVM 도구셋용 MS-Build 지원

### 리눅스/맥 사용자
자동 설치 스크립트로 설치:
```bash
bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
```

## 빌드 방법

### 1. 저장소 클론
```bash
git clone --recursive https://github.com/microsoft/BitNet.git
cd BitNet
```

### 2. 종속성 설치
```bash
# (권장) 새 conda 환경 생성
conda create -n bitnet-cpp python=3.9
conda activate bitnet-cpp

pip install -r requirements.txt
```

### 3. 프로젝트 빌드
```bash
# 모델 다운로드 및 로컬 경로로 실행
huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf --local-dir models/BitNet-b1.58-2B-4T
python setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
```

## 사용 방법

### 기본 사용법
```bash
# 양자화된 모델로 추론 실행
python run_inference.py -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf -p "당신은 도움이 되는 조수입니다" -cnv
```

### 매개변수 설명
- `-m, --model`: 모델 파일 경로 (필수)
- `-n, --n-predict`: 생성할 토큰 수
- `-p, --prompt`: 생성할 텍스트의 프롬프트
- `-t, --threads`: 사용할 스레드 수
- `-c, --ctx-size`: 프롬프트 컨텍스트 크기
- `-temp, --temperature`: 생성된 텍스트의 무작위성을 제어하는 하이퍼파라미터
- `-cnv, --conversation`: 채팅 모드 활성화 여부 (지시 모델용)

## 벤치마크 실행

```bash
python utils/e2e_benchmark.py -m /모델/경로 -n 200 -p 256 -t 4
```

## 더미 모델 생성 및 벤치마크
```bash
python utils/generate-dummy-bitnet-model.py models/bitnet_b1_58-large --outfile models/dummy-bitnet-125m.tl1.gguf --outtype tl1 --model-size 125M

# 생성된 모델로 벤치마크 실행
python utils/e2e_benchmark.py -m models/dummy-bitnet-125m.tl1.gguf -p 512 -n 128
```

## 지원 모델
| 모델 | 매개변수 | CPU | 커널 |
|------|---------|-----|------|
| BitNet-b1.58-2B-4T | 2.4B | x86 | ✅(I2_S), ❌(TL1), ✅(TL2) |
|                    |      | ARM | ✅(I2_S), ✅(TL1), ❌(TL2) |
| bitnet_b1_58-large | 0.7B | x86 | ✅(I2_S), ❌(TL1), ✅(TL2) |
|                    |      | ARM | ✅(I2_S), ✅(TL1), ❌(TL2) |
| bitnet_b1_58-3B | 3.3B | x86 | ❌(I2_S), ❌(TL1), ✅(TL2) |
|                 |      | ARM | ❌(I2_S), ✅(TL1), ❌(TL2) | 