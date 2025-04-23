# BitNet 예제 사용 가이드

이 폴더에는 Microsoft의 BitNet.cpp를 사용하여 고효율 1비트 LLM(대규모 언어 모델)을 실행하는 예제가 포함되어 있습니다.

## 개요

BitNet.cpp는 1.58비트 LLM 모델을 위한 공식 추론 프레임워크로, CPU에서 효율적으로 실행할 수 있도록 최적화되어 있습니다. 이 프레임워크를 사용하면 적은 컴퓨팅 자원으로도 강력한 LLM 모델을 실행할 수 있습니다.

## 예제 파일 목록

이 폴더에는 다음 파일이 포함되어 있습니다:

- `bitnet.md`: BitNet.cpp에 대한 상세 설명 문서
- `run_bitnet_example.py`: BitNet 모델을 로드하고 추론을 실행하는 Python 스크립트
- `setup_bitnet.sh`: Linux/Mac에서 BitNet.cpp를 설치하고 설정하는 스크립트
- `setup_bitnet.bat`: Windows에서 BitNet.cpp를 설치하고 설정하는 스크립트

## 설치 방법

### Windows에서 설치

1. Visual Studio 2022가 설치되어 있고 C++ Clang 컴파일러 옵션이 활성화되어 있는지 확인하세요.
2. 비주얼 스튜디오 개발자 명령 프롬프트를 실행하세요.
3. 이 저장소가 있는 디렉토리로 이동합니다.
4. `setup_bitnet.bat` 스크립트를 실행합니다.

```cmd
setup_bitnet.bat
```

### Linux/Mac에서 설치

1. 터미널을 엽니다.
2. 이 저장소가 있는 디렉토리로 이동합니다.
3. `setup_bitnet.sh` 스크립트에 실행 권한을 부여하고 실행합니다.

```bash
chmod +x setup_bitnet.sh
./setup_bitnet.sh
```

## 사용 방법

설치가 완료되면 다음과 같이 BitNet 모델을 실행할 수 있습니다:

### Python 스크립트로 실행

```bash
python run_bitnet_example.py --download --inference --prompt "안녕하세요, 당신은 누구인가요?"
```

### 매개변수 설명

- `--model-dir`: 모델 디렉토리 경로 (기본값: "models/BitNet-b1.58-2B-4T")
- `--quant-type`: 양자화 유형 (기본값: "i2_s", 선택 가능: "i2_s", "tl1", "tl2")
- `--prompt`: 추론에 사용할 프롬프트 (기본값: "안녕하세요, 당신은 누구인가요?")
- `--download`: 모델 다운로드 실행
- `--inference`: 추론 실행
- `--benchmark`: 벤치마크 실행

### 예시 명령어

모델 다운로드:
```bash
python run_bitnet_example.py --download
```

추론 실행:
```bash
python run_bitnet_example.py --inference --prompt "인공지능의 미래에 대해 설명해주세요."
```

벤치마크 실행:
```bash
python run_bitnet_example.py --benchmark
```

## 주의사항

- BitNet.cpp를 실행하려면 최소 Python 3.9 이상이 필요합니다.
- 대형 모델을 실행할 경우 충분한 RAM이 필요합니다.
- Windows에서는 비주얼 스튜디오 개발자 명령 프롬프트에서 실행해야 합니다.

## 더 자세한 정보

더 자세한 정보는 [BitNet.cpp 공식 저장소](https://github.com/microsoft/BitNet)를 참조하세요. 