import argparse
from .generator import AIPresentation

def main():
    parser = argparse.ArgumentParser(description="AI를 사용하여 파워포인트 프레젠테이션 생성")
    parser.add_argument("topic", help="프레젠테이션 주제")
    parser.add_argument("--slides", type=int, default=5, help="슬라이드 수 (기본값: 5)")
    parser.add_argument("--output", default="presentation.pptx", help="출력 파일 경로")
    parser.add_argument("--api-key", help="OpenAI API 키 (제공되지 않으면 OPENAI_API_KEY 환경 변수 사용)")
    
    args = parser.parse_args()
    
    try:
        generator = AIPresentation(api_key=args.api_key)
        print(f"'{args.topic}' 주제에 대한 프레젠테이션 개요 생성 중...")
        outline = generator.generate_outline(args.topic, args.slides)
        
        print("파워포인트 프레젠테이션 생성 중...")
        output_path = generator.create_presentation(outline, args.output)
        
        print(f"프레젠테이션이 성공적으로 생성되었습니다: {output_path}")
    
    except Exception as e:
        print(f"오류: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    main() 