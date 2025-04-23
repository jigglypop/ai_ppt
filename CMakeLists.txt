cmake_minimum_required(VERSION 3.10)
project(bitnet_rest_server CXX)

# C++17 표준 사용
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 릴리스 빌드 설정
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# 컴파일러 최적화 플래그
if(CMAKE_BUILD_TYPE MATCHES Release)
  if(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /O2")
  else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
  endif()
endif()

# BitNet.cpp 및 llama.cpp 저장소 경로 설정
set(BITNET_DIR "${CMAKE_CURRENT_SOURCE_DIR}/BitNet" CACHE PATH "BitNet repository directory")
set(LLAMACPP_DIR "${BITNET_DIR}/llamacpp" CACHE PATH "llama.cpp directory within BitNet")

# 외부 라이브러리 다운로드 설정
include(FetchContent)

# nlohmann/json 라이브러리 다운로드
FetchContent_Declare(
  json
  GIT_REPOSITORY https://github.com/nlohmann/json.git
  GIT_TAG v3.11.2
)
FetchContent_MakeAvailable(json)

# cpp-httplib 다운로드
FetchContent_Declare(
  httplib
  GIT_REPOSITORY https://github.com/yhirose/cpp-httplib.git
  GIT_TAG v0.14.0
)
FetchContent_MakeAvailable(httplib)

# BitNet 저장소 클론 (필요한 경우)
if(NOT EXISTS "${BITNET_DIR}")
  message(STATUS "Cloning BitNet repository...")
  execute_process(
    COMMAND git clone --recursive https://github.com/microsoft/BitNet.git ${BITNET_DIR}
    RESULT_VARIABLE GIT_RESULT
  )
  if(NOT GIT_RESULT EQUAL 0)
    message(FATAL_ERROR "Failed to clone BitNet repository")
  endif()
endif()

# llama.cpp 디렉토리 확인
if(NOT EXISTS "${LLAMACPP_DIR}")
  message(FATAL_ERROR "llama.cpp not found at ${LLAMACPP_DIR}")
endif()

# llama.cpp 빌드 설정 추가
set(LLAMA_NATIVE ON CACHE BOOL "Enable CPU specific optimizations")
set(LLAMA_CUDA_DMMV OFF CACHE BOOL "Disable CUDA for our REST API server")
set(LLAMA_BLAS OFF CACHE BOOL "Disable BLAS for simplicity")
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "Do not build examples")
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "Do not build tests")
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build static libraries")

# llama.cpp 소스 포함
add_subdirectory(${LLAMACPP_DIR} ${CMAKE_BINARY_DIR}/llama.cpp)

# 실행 파일 생성
add_executable(bitnet_server bitnet_server.cpp)

# 포함 경로 설정
target_include_directories(bitnet_server PRIVATE 
  ${LLAMACPP_DIR} 
  ${LLAMACPP_DIR}/common
)

# 외부 라이브러리 링크
target_link_libraries(bitnet_server PRIVATE nlohmann_json::nlohmann_json)
target_link_libraries(bitnet_server PRIVATE httplib::httplib)
target_link_libraries(bitnet_server PRIVATE llama)

# 스레드 라이브러리 링크
find_package(Threads REQUIRED)
target_link_libraries(bitnet_server PRIVATE Threads::Threads)

# 설치 설정
install(TARGETS bitnet_server DESTINATION bin) 