@echo off
REM BitNet REST API 서버 빌드 및 실행 스크립트 (Windows용)

echo BitNet REST API 서버 빌드 스크립트
echo ========================================

REM 필수 도구 체크
echo 필수 도구 확인 중...
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 오류: git이 설치되어 있지 않습니다.
    exit /b 1
)

where cmake >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 오류: cmake가 설치되어 있지 않습니다.
    exit /b 1
)

REM Visual Studio 개발자 명령 프롬프트 체크 (cl.exe 확인)
where cl >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 경고: 컴파일러를 찾을 수 없습니다. Visual Studio 개발자 명령 프롬프트에서 이 스크립트를 실행하세요.
    echo 1. Visual Studio Command Prompt 검색
    echo 2. 'x64 Native Tools Command Prompt for VS 2019' 또는 유사한 항목 선택
    echo 3. 이 스크립트를 다시 실행하세요.
    pause
    exit /b 1
)

echo 필수 도구가 설치되어 있습니다.

REM 현재 디렉토리 저장
set CURRENT_DIR=%CD%

REM 빌드 디렉토리 생성
set BUILD_DIR=%CURRENT_DIR%\build
mkdir %BUILD_DIR% 2>nul
cd %BUILD_DIR%

REM CMake 프로젝트 설정
echo CMake 프로젝트 설정 중...
cmake -DCMAKE_BUILD_TYPE=Release ..

if %ERRORLEVEL% NEQ 0 (
    echo CMake 구성에 실패했습니다.
    cd %CURRENT_DIR%
    exit /b 1
)

REM 빌드 시작
echo 빌드 중...
cmake --build . --config Release

if %ERRORLEVEL% NEQ 0 (
    echo 빌드에 실패했습니다.
    cd %CURRENT_DIR%
    exit /b 1
)

echo BitNet REST API 서버 빌드에 성공했습니다!

REM 서버 정보 표시
echo 서버 실행 방법:
echo Release\bitnet_server.exe [--port 포트번호] [--model 모델경로] [--threads 스레드수]
echo.
echo 기본 옵션:
echo - 포트: 8080
echo - 모델: models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf
echo - 스레드: %NUMBER_OF_PROCESSORS%
echo.
echo 예시:
echo Release\bitnet_server.exe --port 8080 --model ..\models\BitNet-b1.58-2B-4T\ggml-model-i2_s.gguf --threads 4
echo.

REM 사용자에게 서버 실행 여부 묻기
set /p RUN_SERVER=서버를 지금 실행할까요? (y/n): 
if /i "%RUN_SERVER%"=="y" (
    echo BitNet REST API 서버 실행 중...
    Release\bitnet_server.exe
) else (
    echo 빌드 디렉토리의 Release 폴더에서 'bitnet_server.exe'를 실행하여 서버를 시작할 수 있습니다.
)

REM 원래 디렉토리로 돌아가기
cd %CURRENT_DIR%

pause 