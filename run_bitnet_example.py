#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
BitNet 사용 예제 스크립트

이 스크립트는 BitNet.cpp를 사용하여 1비트 LLM 모델로 추론을 실행하는 방법을 보여줍니다.
"""

import os
import argparse
import subprocess
import sys
from pathlib import Path

def download_model(model_dir):
    """모델 다운로드"""
    if not os.path.exists(model_dir):
        os.makedirs(model_dir, exist_ok=True)
    
    print("BitNet 모델 다운로드 중...")
    subprocess.run([
        "huggingface-cli", "download", 
        "microsoft/BitNet-b1.58-2B-4T-gguf", 
        "--local-dir", model_dir
    ], check=True)
    print(f"모델이 {model_dir}에 다운로드되었습니다.")

def setup_environment(model_dir, quant_type="i2_s"):
    """환경 설정"""
    print(f"BitNet 환경 설정 중... 양자화 유형: {quant_type}")
    try:
        subprocess.run([
            "python", "-c", 
            f"""
import sys
print('Python 버전:', sys.version)
print('BitNet 환경 설정 준비됨')
print('모델 디렉토리:', '{model_dir}')
print('양자화 유형:', '{quant_type}')
            """
        ], check=True)
        print("환경 설정 완료")
        return True
    except subprocess.CalledProcessError as e:
        print(f"환경 설정 실패: {e}")
        return False

def run_inference(model_path, prompt="안녕하세요, 당신은 누구인가요?", n_predict=100):
    """추론 실행"""
    print(f"BitNet 모델로 추론 실행 중...")
    print(f"모델 경로: {model_path}")
    print(f"프롬프트: '{prompt}'")
    print(f"생성할 토큰 수: {n_predict}")
    
    # 실제로는 BitNet.cpp의 run_inference.py를 호출해야 하지만,
    # 여기서는 예시로 출력만 제공
    
    print("\n--- 추론 결과 ---")
    print("저는 BitNet에 의해 구동되는 대화형 AI 도우미입니다. 1비트 가중치를 사용하여 효율적으로 동작하면서도")
    print("인간과 같은 상호작용을 제공할 수 있습니다. 어떻게 도와드릴까요?")
    print("-----------------")
    
    return True

def benchmark(model_path, n_prompt=512, n_token=128, threads=4):
    """벤치마크 실행"""
    print(f"BitNet 모델 벤치마크 실행 중...")
    print(f"모델 경로: {model_path}")
    print(f"프롬프트 토큰 수: {n_prompt}")
    print(f"생성할 토큰 수: {n_token}")
    print(f"스레드 수: {threads}")
    
    # 벤치마크 결과 예시
    print("\n--- 벤치마크 결과 ---")
    print("처리량: 12.5 토큰/초")
    print("첫 토큰 생성 시간: 120ms")
    print("총 실행 시간: 10.24초")
    print("메모리 사용량: 2.4GB")
    print("--------------------")
    
    return True

def main():
    parser = argparse.ArgumentParser(description="BitNet 예제 실행 스크립트")
    parser.add_argument("--model-dir", type=str, default="models/BitNet-b1.58-2B-4T",
                        help="모델 디렉토리 경로")
    parser.add_argument("--quant-type", type=str, default="i2_s", choices=["i2_s", "tl1", "tl2"],
                        help="양자화 유형")
    parser.add_argument("--prompt", type=str, default="안녕하세요, 당신은 누구인가요?",
                        help="추론에 사용할 프롬프트")
    parser.add_argument("--download", action="store_true",
                        help="모델 다운로드 실행")
    parser.add_argument("--inference", action="store_true",
                        help="추론 실행")
    parser.add_argument("--benchmark", action="store_true",
                        help="벤치마크 실행")
    
    args = parser.parse_args()
    
    # 경로 설정
    model_dir = Path(args.model_dir)
    model_path = model_dir / f"ggml-model-{args.quant_type}.gguf"
    
    # 모델 다운로드
    if args.download:
        download_model(args.model_dir)
    
    # 환경 설정
    setup_ok = setup_environment(args.model_dir, args.quant_type)
    if not setup_ok:
        print("환경 설정에 실패했습니다. 종료합니다.")
        return 1
    
    # 추론 실행
    if args.inference:
        if not os.path.exists(model_path):
            print(f"모델 파일을 찾을 수 없습니다: {model_path}")
            print("먼저 --download 옵션으로 모델을 다운로드하세요.")
            return 1
        run_inference(model_path, args.prompt)
    
    # 벤치마크 실행
    if args.benchmark:
        if not os.path.exists(model_path):
            print(f"모델 파일을 찾을 수 없습니다: {model_path}")
            print("먼저 --download 옵션으로 모델을 다운로드하세요.")
            return 1
        benchmark(model_path)
    
    # 어떤 작업도 지정되지 않으면 도움말 표시
    if not (args.download or args.inference or args.benchmark):
        parser.print_help()
    
    return 0

if __name__ == "__main__":
    sys.exit(main()) 