@echo off
REM BitNet 모델 다운로드 스크립트 (Windows용)

echo BitNet 모델 다운로드 스크립트
echo ==============================

REM 모델 저장 디렉토리
set MODEL_DIR=models\BitNet-b1.58-2B-4T

REM 디렉토리 생성
mkdir %MODEL_DIR% 2>nul

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

echo 필수 도구가 설치되어 있습니다.

REM huggingface-cli 설치 확인
where huggingface-cli >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo huggingface-cli 설치 중...
    pip install huggingface_hub
)

echo BitNet 모델 다운로드 중...
huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf --local-dir %MODEL_DIR%

if %ERRORLEVEL% NEQ 0 (
    echo 모델 다운로드에 실패했습니다.
    
    echo BitNet 레퍼런스 저장소에서 더미 모델 생성을 시도합니다...
    
    REM BitNet 저장소가 없으면 클론
    if not exist "BitNet" (
        echo BitNet 저장소 클론 중...
        git clone --recursive https://github.com/microsoft/BitNet.git
        
        if %ERRORLEVEL% NEQ 0 (
            echo BitNet 저장소 클론에 실패했습니다.
            exit /b 1
        )
    )
    
    REM 더미 모델 생성
    echo 더미 모델 생성 중...
    python BitNet\utils\generate-dummy-bitnet-model.py %MODEL_DIR% --outfile %MODEL_DIR%\ggml-model-i2_s.gguf --outtype i2_s --model-size 125M
    
    if %ERRORLEVEL% NEQ 0 (
        echo 더미 모델 생성에 실패했습니다.
        exit /b 1
    )
    
    echo 더미 모델 생성 완료: %MODEL_DIR%\ggml-model-i2_s.gguf
) else (
    echo 모델 다운로드 완료: %MODEL_DIR%
)

echo 서버 실행 시 다음 모델 경로를 사용하세요:
echo %MODEL_DIR%\ggml-model-i2_s.gguf
echo.

pause 