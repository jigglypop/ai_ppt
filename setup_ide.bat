@echo off
REM IDE 설정 스크립트 - 종속성 다운로드 (Windows용)

echo IDE 설정 스크립트 - 종속성 다운로드
echo ========================================

REM 필수 도구 체크
echo 필수 도구 확인 중...
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 오류: git이 설치되어 있지 않습니다.
    exit /b 1
)

echo 필수 도구가 설치되어 있습니다.

REM 작업 디렉토리 생성
set DEPS_DIR=deps
mkdir %DEPS_DIR% 2>nul

REM BitNet 저장소 클론
if not exist "BitNet" (
    echo BitNet 저장소 클론 중...
    git clone --recursive https://github.com/microsoft/BitNet.git
    
    if %ERRORLEVEL% NEQ 0 (
        echo BitNet 저장소 클론에 실패했습니다.
        exit /b 1
    )
    
    echo BitNet 저장소 클론 완료
) else (
    echo BitNet 저장소가 이미 존재합니다.
)

REM nlohmann/json 라이브러리 클론
if not exist "%DEPS_DIR%\json" (
    echo nlohmann/json 라이브러리 클론 중...
    git clone https://github.com/nlohmann/json.git %DEPS_DIR%\json
    
    if %ERRORLEVEL% NEQ 0 (
        echo nlohmann/json 라이브러리 클론에 실패했습니다.
        exit /b 1
    )
    
    echo nlohmann/json 라이브러리 클론 완료
) else (
    echo nlohmann/json 라이브러리가 이미 존재합니다.
)

REM cpp-httplib 라이브러리 클론
if not exist "%DEPS_DIR%\httplib" (
    echo cpp-httplib 라이브러리 클론 중...
    git clone https://github.com/yhirose/cpp-httplib.git %DEPS_DIR%\httplib
    
    if %ERRORLEVEL% NEQ 0 (
        echo cpp-httplib 라이브러리 클론에 실패했습니다.
        exit /b 1
    )
    
    echo cpp-httplib 라이브러리 클론 완료
) else (
    echo cpp-httplib 라이브러리가 이미 존재합니다.
)

REM Include 경로 링크
echo IDE를 위한 include 디렉토리 생성 중...
mkdir include 2>nul

REM nlohmann/json 헤더 링크
mkdir include\nlohmann 2>nul
copy %DEPS_DIR%\json\include\nlohmann\json.hpp include\nlohmann\

REM cpp-httplib 헤더 링크
copy %DEPS_DIR%\httplib\httplib.h include\

REM BitNet 헤더 링크
copy BitNet\llamacpp\llama.h include\
copy BitNet\llamacpp\common\common.h include\
copy BitNet\llamacpp\common\grammar-parser.h include\

echo IDE 설정 완료!
echo 이제 IDE에서 헤더 파일을 찾을 수 있습니다.

pause 