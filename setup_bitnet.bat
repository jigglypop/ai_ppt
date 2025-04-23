@echo off
REM BitNet.cpp 설치 및 설정 스크립트 (Windows용)

echo BitNet.cpp 설치 및 설정 스크립트
echo ===============================

REM 작업 디렉토리 설정
set WORK_DIR=bitnet-cpp
mkdir %WORK_DIR% 2>nul
cd %WORK_DIR%

REM 필수 도구 체크
echo 필수 도구 확인 중...
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 오류: git이 설치되어 있지 않습니다.
    exit /b 1
)

where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 오류: python이 설치되어 있지 않습니다.
    exit /b 1
)

where pip >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 오류: pip가 설치되어 있지 않습니다.
    exit /b 1
)

where cmake >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 오류: cmake가 설치되어 있지 않습니다.
    exit /b 1
)

echo 필수 도구가 설치되어 있습니다.

REM Visual Studio 개발자 명령 프롬프트 체크 (clang 확인)
where clang >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 경고: clang이 설치되어 있지 않거나 경로에 없습니다.
    echo Visual Studio 2022 설치 및 C++ Clang 컴파일러 옵션이 활성화되어 있는지 확인하세요.
    echo 비주얼 스튜디오 개발자 명령 프롬프트에서 이 스크립트를 다시 실행하세요.
    pause
    exit /b 1
)

REM BitNet 저장소 클론
echo BitNet 저장소 클론 중...
if not exist "BitNet" (
    git clone --recursive https://github.com/microsoft/BitNet.git
    if %ERRORLEVEL% NEQ 0 (
        echo BitNet 저장소 클론에 실패했습니다.
        exit /b 1
    )
    echo BitNet 저장소 클론 완료.
) else (
    echo BitNet 저장소가 이미 존재합니다.
    cd BitNet
    git pull
    cd ..
)

REM Python 가상 환경 설정
echo Python 가상 환경 설정 중...
if not exist "venv" (
    python -m venv venv
    echo 가상 환경 생성 완료.
) else (
    echo 가상 환경이 이미 존재합니다.
)

REM 가상 환경 활성화
echo 가상 환경 활성화 중...
call venv\Scripts\activate.bat
if %ERRORLEVEL% NEQ 0 (
    echo 가상 환경 활성화에 실패했습니다.
    exit /b 1
)
echo 가상 환경 활성화 완료.

REM 의존성 설치
echo 필요한 패키지 설치 중...
cd BitNet
pip install -r requirements.txt
if %ERRORLEVEL% NEQ 0 (
    echo 패키지 설치에 실패했습니다.
    exit /b 1
)
echo 패키지 설치 완료.

REM 테스트용 모델 다운로드
echo 테스트용 더미 모델 생성 중...
mkdir models 2>nul
python utils\generate-dummy-bitnet-model.py models\bitnet_b1_58-large --outfile models\dummy-bitnet-125m.i2_s.gguf --outtype i2_s --model-size 125M
if %ERRORLEVEL% NEQ 0 (
    echo 더미 모델 생성에 실패했습니다.
    exit /b 1
)
echo 더미 모델 생성 완료.

REM 벤치마크 실행
echo 벤치마크 실행 중...
python utils\e2e_benchmark.py -m models\dummy-bitnet-125m.i2_s.gguf -p 64 -n 32 -t 2
if %ERRORLEVEL% NEQ 0 (
    echo 벤치마크 실행에 실패했습니다.
    exit /b 1
)
echo 벤치마크 실행 완료.

REM 마무리
cd ..\..
echo BitNet.cpp 설치 및 설정이 완료되었습니다.
echo.
echo 사용 방법:
echo   cd %WORK_DIR%\BitNet
echo   call ..\venv\Scripts\activate.bat
echo   python run_inference.py -m models\dummy-bitnet-125m.i2_s.gguf -p "안녕하세요, 당신은 누구인가요?" -n 100
echo.
echo 실제 모델 다운로드:
echo   huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf --local-dir models\BitNet-b1.58-2B-4T
echo.

pause 