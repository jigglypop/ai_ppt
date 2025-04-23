#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
BitNet REST API 서버 성능 벤치마크 스크립트
"""

import time
import json
import requests
import argparse
import threading
import statistics
import matplotlib.pyplot as plt
from tqdm import tqdm
from concurrent.futures import ThreadPoolExecutor

def send_request(url, prompt, n_predict=100):
    """BitNet 서버에 추론 요청 전송"""
    start_time = time.time()
    
    try:
        response = requests.post(
            f"{url}/generate", 
            json={"prompt": prompt, "n_predict": n_predict},
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            success = True
        else:
            result = {"error": f"Status code: {response.status_code}"}
            success = False
            
    except Exception as e:
        result = {"error": str(e)}
        success = False
    
    end_time = time.time()
    latency = (end_time - start_time) * 1000  # 밀리초 단위
    
    return {
        "success": success,
        "latency_ms": latency,
        "result": result
    }

def run_benchmark(url, num_requests=100, concurrency=10, prompt="안녕하세요, 오늘 날씨는 어떤가요?", n_predict=100):
    """벤치마크 실행"""
    print(f"BitNet REST API 서버 벤치마크 시작")
    print(f"서버 URL: {url}")
    print(f"총 요청 수: {num_requests}")
    print(f"동시 요청 수: {concurrency}")
    print(f"프롬프트: {prompt}")
    print(f"생성 토큰 수: {n_predict}")
    print("=" * 50)
    
    results = []
    success_count = 0
    
    # 진행 상황 표시
    progress_bar = tqdm(total=num_requests, desc="요청 중")
    
    # 스레드 풀 생성
    with ThreadPoolExecutor(max_workers=concurrency) as executor:
        # 요청 제출
        futures = [executor.submit(send_request, url, prompt, n_predict) for _ in range(num_requests)]
        
        # 결과 수집
        for future in futures:
            result = future.result()
            results.append(result)
            if result["success"]:
                success_count += 1
            progress_bar.update(1)
    
    progress_bar.close()
    
    # 결과 분석
    if results:
        latencies = [r["latency_ms"] for r in results if r["success"]]
        
        if latencies:
            avg_latency = statistics.mean(latencies)
            min_latency = min(latencies)
            max_latency = max(latencies)
            p50_latency = statistics.median(latencies)
            p95_latency = sorted(latencies)[int(len(latencies) * 0.95)]
            p99_latency = sorted(latencies)[int(len(latencies) * 0.99)]
            success_rate = (success_count / num_requests) * 100
            requests_per_second = 1000 / avg_latency * concurrency
            
            # 결과 출력
            print("\n벤치마크 결과:")
            print(f"성공률: {success_rate:.2f}%")
            print(f"평균 지연 시간: {avg_latency:.2f} ms")
            print(f"최소 지연 시간: {min_latency:.2f} ms")
            print(f"최대 지연 시간: {max_latency:.2f} ms")
            print(f"중앙값 지연 시간: {p50_latency:.2f} ms")
            print(f"95%ile 지연 시간: {p95_latency:.2f} ms")
            print(f"99%ile 지연 시간: {p99_latency:.2f} ms")
            print(f"초당 요청 처리량: {requests_per_second:.2f} 요청/초")
            
            # 지연 시간 분포 그래프 그리기
            plt.figure(figsize=(10, 6))
            plt.hist(latencies, bins=20, alpha=0.7, color='blue')
            plt.axvline(avg_latency, color='red', linestyle='dashed', linewidth=1, label=f'평균: {avg_latency:.2f}ms')
            plt.axvline(p95_latency, color='green', linestyle='dashed', linewidth=1, label=f'95%ile: {p95_latency:.2f}ms')
            plt.title('BitNet REST API 응답 시간 분포')
            plt.xlabel('응답 시간 (ms)')
            plt.ylabel('요청 수')
            plt.legend()
            plt.grid(True, alpha=0.3)
            
            # 그래프 저장
            plt.savefig('bitnet_latency_distribution.png')
            print("\n응답 시간 분포 그래프가 'bitnet_latency_distribution.png'에 저장되었습니다.")
            
            # 결과 JSON 저장
            benchmark_results = {
                "config": {
                    "url": url,
                    "num_requests": num_requests,
                    "concurrency": concurrency,
                    "prompt": prompt,
                    "n_predict": n_predict
                },
                "results": {
                    "success_rate": success_rate,
                    "avg_latency_ms": avg_latency,
                    "min_latency_ms": min_latency,
                    "max_latency_ms": max_latency,
                    "p50_latency_ms": p50_latency,
                    "p95_latency_ms": p95_latency,
                    "p99_latency_ms": p99_latency,
                    "requests_per_second": requests_per_second
                }
            }
            
            with open('bitnet_benchmark_results.json', 'w', encoding='utf-8') as f:
                json.dump(benchmark_results, f, indent=2)
            print("벤치마크 결과가 'bitnet_benchmark_results.json'에 저장되었습니다.")
            
        else:
            print("\n오류: 성공한 요청이 없습니다!")
    else:
        print("\n오류: 결과가 없습니다!")

def main():
    parser = argparse.ArgumentParser(description='BitNet REST API 서버 벤치마크')
    parser.add_argument('--url', type=str, default='http://localhost:8080', help='BitNet 서버 URL')
    parser.add_argument('--requests', type=int, default=100, help='총 요청 수')
    parser.add_argument('--concurrency', type=int, default=10, help='동시 요청 수')
    parser.add_argument('--prompt', type=str, default='안녕하세요, 비트넷에 대해 알려주세요.', help='추론 프롬프트')
    parser.add_argument('--tokens', type=int, default=100, help='생성할 토큰 수')
    
    args = parser.parse_args()
    
    # 서버 상태 확인
    try:
        response = requests.get(f"{args.url}/status", timeout=5)
        if response.status_code == 200:
            print("서버 상태 확인 완료!")
            print(f"서버 정보: {response.json()}")
        else:
            print(f"서버가 응답했지만 상태 코드가 좋지 않습니다: {response.status_code}")
    except Exception as e:
        print(f"서버 연결 오류: {e}")
        print("서버가 실행 중인지 확인하고 다시 시도하세요.")
        return
    
    # 벤치마크 실행
    run_benchmark(
        url=args.url,
        num_requests=args.requests,
        concurrency=args.concurrency,
        prompt=args.prompt,
        n_predict=args.tokens
    )

if __name__ == "__main__":
    main() 