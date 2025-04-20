@echo off
echo UV를 사용하여 AI 파워포인트 생성기 환경을 설정합니다...

:: UV 설치 확인
pip show uv >nul 2>&1
if %errorlevel% neq 0 (
    echo UV 설치 중...
    pip install uv
)

:: 가상 환경 생성 및 활성화
echo 가상 환경 생성 중...
uv venv .venv
call .venv\Scripts\activate.bat

:: 의존성 설치
echo 의존성 설치 중...
uv pip install -r requirements.txt

:: 개발 모드 설치
echo 개발 모드로 패키지 설치 중...
uv pip install -e .

echo.
echo 설정 완료!
echo "ai-ppt" 명령어를 사용하여 프로그램을 실행할 수 있습니다.
echo 예: ai-ppt "인공지능" --slides 6 