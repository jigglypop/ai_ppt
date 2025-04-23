#include <iostream>
#include <string>
#include <vector>
#include <chrono>
#include <memory>
#include <thread>
#include <mutex>
#include <fstream>
#include <sstream>
#include "include/httplib.h"
#include "include/nlohmann/json.hpp"

// BitNet.cpp 통합을 위한 헤더 포함
#include "include/llama.h"
#include "include/common.h"
#include "include/grammar-parser.h"

// JSON 라이브러리 사용
using json = nlohmann::json;

// 글로벌 BitNet 컨텍스트
struct BitNetContext {
    llama_model* model = nullptr;
    llama_context* ctx = nullptr;
    
    ~BitNetContext() {
        if (ctx) {
            llama_free(ctx);
            ctx = nullptr;
        }
        if (model) {
            llama_free_model(model);
            model = nullptr;
        }
    }
};

// BitNet 컨텍스트 초기화 함수
std::shared_ptr<BitNetContext> initialize_bitnet(const std::string& model_path, int n_threads) {
    auto bitnet_ctx = std::make_shared<BitNetContext>();
    
    // 모델 파라미터 설정
    llama_model_params model_params = llama_model_default_params();
    
    // 모델 로드
    bitnet_ctx->model = llama_load_model_from_file(model_path.c_str(), model_params);
    if (!bitnet_ctx->model) {
        throw std::runtime_error("BitNet 모델 로드 실패: " + model_path);
    }
    
    // 컨텍스트 파라미터 설정
    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = 2048;  // 컨텍스트 크기
    ctx_params.n_threads = n_threads;
    ctx_params.n_threads_batch = n_threads;
    
    // 컨텍스트 생성
    bitnet_ctx->ctx = llama_new_context_with_model(bitnet_ctx->model, ctx_params);
    if (!bitnet_ctx->ctx) {
        llama_free_model(bitnet_ctx->model);
        throw std::runtime_error("BitNet 컨텍스트 생성 실패");
    }
    
    return bitnet_ctx;
}

// 실제 BitNet 추론 실행 함수
std::string run_bitnet_inference(std::shared_ptr<BitNetContext> bitnet_ctx, const std::string& prompt, int n_predict = 100) {
    if (!bitnet_ctx || !bitnet_ctx->ctx || !bitnet_ctx->model) {
        return "오류: BitNet 모델이 초기화되지 않았습니다.";
    }
    
    // 토큰 설정
    std::vector<llama_token> tokens_list;
    std::vector<llama_token> prompt_tokens;
    
    // 프롬프트 토큰화
    prompt_tokens = llama_tokenize(bitnet_ctx->ctx, prompt, true);
    if (prompt_tokens.empty()) {
        return "오류: 프롬프트 토큰화에 실패했습니다.";
    }
    
    // 배치 크기 설정
    const int batch_size = 512;
    const int n_batch = (prompt_tokens.size() + batch_size - 1) / batch_size;
    
    // 프롬프트 평가
    for (int i = 0; i < n_batch; ++i) {
        const int batch_start = i * batch_size;
        const int batch_size_i = std::min(batch_size, (int)prompt_tokens.size() - batch_start);
        if (llama_decode(bitnet_ctx->ctx, llama_batch_get_one(&prompt_tokens[batch_start], batch_size_i, 0, 0)) != 0) {
            return "오류: 프롬프트 디코딩에 실패했습니다.";
        }
    }
    
    // 생성 시작
    std::string result = prompt;
    
    // 토큰 생성 파라미터
    llama_sampling_params params;
    params.temp = 0.8f;
    params.top_p = 0.95f;
    params.repeat_penalty = 1.1f;
    params.n_prev = 64;
    
    llama_sampling_context * sampling_ctx = llama_sampling_init(params);
    
    // 응답 생성
    llama_token id = 0;
    for (int i = 0; i < n_predict; ++i) {
        // 다음 토큰 얻기
        if (llama_sampling_sample(sampling_ctx, bitnet_ctx->ctx, NULL)) {
            id = llama_sampling_last(sampling_ctx);
        } else {
            break;
        }
        
        // EOS 토큰이면 중단
        if (id == llama_token_eos(bitnet_ctx->model)) {
            break;
        }
        
        // 토큰을 텍스트로 변환하여 결과에 추가
        const char* token_str = llama_token_to_str(bitnet_ctx->ctx, id);
        if (token_str) {
            result += token_str;
        }
        
        // 토큰 디코딩
        if (llama_decode(bitnet_ctx->ctx, llama_batch_get_one(&id, 1, i + prompt_tokens.size(), 0)) != 0) {
            llama_sampling_free(sampling_ctx);
            return result + "\n\n오류: 토큰 디코딩 중 오류가 발생했습니다.";
        }
    }
    
    llama_sampling_free(sampling_ctx);
    return result;
}

// 성능 메트릭 구조체
struct PerformanceMetrics {
    double avg_response_time_ms = 0.0;
    double min_response_time_ms = std::numeric_limits<double>::max();
    double max_response_time_ms = 0.0;
    int total_requests = 0;
    int successful_requests = 0;
    std::mutex metrics_mutex;
    
    void update(double response_time_ms, bool success) {
        std::lock_guard<std::mutex> lock(metrics_mutex);
        
        if (success) {
            avg_response_time_ms = (avg_response_time_ms * successful_requests + response_time_ms) / (successful_requests + 1);
            min_response_time_ms = std::min(min_response_time_ms, response_time_ms);
            max_response_time_ms = std::max(max_response_time_ms, response_time_ms);
            successful_requests++;
        }
        
        total_requests++;
    }
    
    json to_json() const {
        return {
            {"avg_response_time_ms", avg_response_time_ms},
            {"min_response_time_ms", min_response_time_ms},
            {"max_response_time_ms", max_response_time_ms},
            {"total_requests", total_requests},
            {"successful_requests", successful_requests},
            {"success_rate", successful_requests * 100.0 / (total_requests > 0 ? total_requests : 1)}
        };
    }
};

int main(int argc, char** argv) {
    // 기본 설정
    int port = 8080;
    std::string model_path = "models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf";
    int num_threads = std::thread::hardware_concurrency();
    
    // 명령줄 인수 파싱
    for (int i = 1; i < argc; i += 2) {
        std::string arg = argv[i];
        if (i + 1 < argc) {
            if (arg == "--port") {
                port = std::stoi(argv[i + 1]);
            } else if (arg == "--model") {
                model_path = argv[i + 1];
            } else if (arg == "--threads") {
                num_threads = std::stoi(argv[i + 1]);
            }
        }
    }
    
    // 서버 로그 설정
    std::cerr << "BitNet REST API 서버 시작중..." << std::endl;
    std::cerr << "모델 경로: " << model_path << std::endl;
    std::cerr << "스레드 수: " << num_threads << std::endl;
    std::cerr << "포트: " << port << std::endl;
    
    // BitNet 초기화
    std::cerr << "BitNet 모델 로드 중..." << std::endl;
    std::shared_ptr<BitNetContext> bitnet_ctx;
    
    try {
        bitnet_ctx = initialize_bitnet(model_path, num_threads);
        std::cerr << "BitNet 모델 로드 완료!" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "오류: BitNet 초기화 실패: " << e.what() << std::endl;
        return 1;
    }
    
    // 성능 메트릭 초기화
    auto metrics = std::make_shared<PerformanceMetrics>();
    
    // HTTP 서버 설정
    httplib::Server server;
    
    // CORS 헤더 설정
    server.set_default_headers({
        {"Access-Control-Allow-Origin", "*"},
        {"Access-Control-Allow-Methods", "POST, GET, OPTIONS"},
        {"Access-Control-Allow-Headers", "Content-Type, Authorization"}
    });
    
    // OPTIONS 요청 처리 (CORS 프리플라이트 요청)
    server.Options("/(.*)", [](const httplib::Request& req, httplib::Response& res) {
        res.status = 204; // No Content
    });
    
    // 서버 상태 API
    server.Get("/status", [&](const httplib::Request& req, httplib::Response& res) {
        json response = {
            {"status", "running"},
            {"model", model_path},
            {"threads", num_threads},
            {"metrics", metrics->to_json()}
        };
        
        res.set_content(response.dump(2), "application/json");
    });
    
    // 추론 API
    server.Post("/generate", [&](const httplib::Request& req, httplib::Response& res) {
        auto start_time = std::chrono::high_resolution_clock::now();
        bool success = false;
        
        try {
            // 요청 본문 파싱
            auto request_json = json::parse(req.body);
            
            std::string prompt = request_json.value("prompt", "");
            int n_predict = request_json.value("n_predict", 100);
            
            if (prompt.empty()) {
                res.status = 400;
                res.set_content(R"({"error": "Prompt is required"})", "application/json");
                metrics->update(0, false);
                return;
            }
            
            // BitNet 추론 실행
            std::string output = run_bitnet_inference(bitnet_ctx, prompt, n_predict);
            
            // 응답 생성
            json response = {
                {"output", output}
            };
            
            res.set_content(response.dump(), "application/json");
            success = true;
            
        } catch (const std::exception& e) {
            res.status = 500;
            res.set_content(
                json{{"error", e.what()}}.dump(),
                "application/json"
            );
        }
        
        // 성능 측정 및 기록
        auto end_time = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time);
        metrics->update(duration.count(), success);
    });
    
    // 성능 측정 API
    server.Get("/metrics", [&](const httplib::Request& req, httplib::Response& res) {
        res.set_content(metrics->to_json().dump(2), "application/json");
    });
    
    // 서버 시작
    std::cerr << "서버가 http://localhost:" << port << "에서 실행 중입니다..." << std::endl;
    server.listen("0.0.0.0", port);
    
    return 0;
} 