# AI 파워포인트 생성기

이 도구는 OpenAI의 GPT 모델을 사용하여 어떤 주제에 관한 파워포인트 프레젠테이션도 자동으로 생성합니다.

## 설치

### 방법 1: pip 사용
1. 이 저장소를 복제하거나 파일을 다운로드합니다
2. 필요한 종속성을 설치합니다:
   ```
   pip install -r requirements.txt
   ```

### 방법 2: UV 사용 (권장)
[UV](https://github.com/astral-sh/uv)는 빠른 Python 패키지 설치 도구입니다.

1. UV 설치:
   ```bash
   pip install uv
   ```

2. 가상 환경 생성 및 의존성 설치:
   ```bash
   uv venv
   source .venv/bin/activate  # Linux/Mac
   # 또는
   .venv\Scripts\activate     # Windows
   uv pip install -r requirements.txt
   ```

3. 개발 모드로 설치:
   ```bash
   uv pip install -e .
   ```

4. `.env` 파일 설정:
   ```
   OPENAI_API_KEY=여기에_OpenAI_API_키를_입력하세요
   ```

## 사용법

### 모듈 실행:
```bash
python -m ai_ppt_generator.cli "인공지능"
```

### 설치된 명령어 사용 (개발 모드로 설치한 경우):
```bash
ai-ppt "인공지능"
```

추가 옵션:
- `--slides`: 생성할 슬라이드 수 (기본값: 5)
- `--output`: 출력 파일 경로 (기본값: presentation.pptx)
- `--api-key`: .env 파일 대신 OpenAI API 키를 직접 제공

옵션을 포함한 예시:
```bash
ai-ppt "기후 변화" --slides 8 --output 기후변화_발표.pptx
```

## 기능

- 프레젠테이션 제목과 개요 자동 생성
- 글머리 기호가 있는 적절한 형식의 슬라이드 생성
- 각 슬라이드에 발표자 노트 포함
- 슬라이드 수 조정 가능

## 요구 사항

- Python 3.8 이상
- OpenAI API 키
- API 호출을 위한 인터넷 연결

## UV 특징

- 빠른 의존성 해결 및 설치
- 정확한 의존성 잠금
- 최적화된 환경 관리 