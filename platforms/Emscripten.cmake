cmake_minimum_required(VERSION 3.10)

project(RetroEngine)

add_executable(RetroEngine ${RETRO_FILES})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC -O3")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -O3")

set(COMPILE_THEORA FALSE) # set this to false so that the main CMakeLists compile step doesnt take over.
set(THEORA_DIR dependencies/all/libtheora)

add_library(libtheora STATIC
    ${THEORA_DIR}/lib/analyze.c
    ${THEORA_DIR}/lib/apiwrapper.c
    ${THEORA_DIR}/lib/bitpack.c
    ${THEORA_DIR}/lib/decapiwrapper.c
    ${THEORA_DIR}/lib/decinfo.c
    ${THEORA_DIR}/lib/decode.c
    ${THEORA_DIR}/lib/dequant.c
    ${THEORA_DIR}/lib/encapiwrapper.c
    ${THEORA_DIR}/lib/encfrag.c
    ${THEORA_DIR}/lib/encinfo.c
    ${THEORA_DIR}/lib/encode.c
    ${THEORA_DIR}/lib/encoder_disabled.c
    ${THEORA_DIR}/lib/enquant.c
    ${THEORA_DIR}/lib/fdct.c
    ${THEORA_DIR}/lib/fragment.c
    ${THEORA_DIR}/lib/huffdec.c
    ${THEORA_DIR}/lib/huffenc.c
    ${THEORA_DIR}/lib/idct.c
    ${THEORA_DIR}/lib/info.c
    ${THEORA_DIR}/lib/internal.c
    ${THEORA_DIR}/lib/mathops.c
    ${THEORA_DIR}/lib/mcenc.c
    ${THEORA_DIR}/lib/quant.c
    ${THEORA_DIR}/lib/rate.c
    ${THEORA_DIR}/lib/state.c
    ${THEORA_DIR}/lib/tokenize.c
)

target_compile_options(libtheora PRIVATE ${THEORA_FLAGS} -fPIC -sUSE_OGG=1)
target_link_libraries(libtheora PRIVATE "-sUSE_OGG=1")
target_include_directories(libtheora PRIVATE ${THEORA_DIR}/include)
target_include_directories(RetroEngine PRIVATE ${THEORA_DIR}/include)

set(EMSCRIPTEN_COMPILER_FLAGS
    -sUSE_SDL=2
    -sUSE_OGG=1
    -sUSE_PTHREADS=1
    -DRSDK_REVISION=3
    -DRSDK_USE_SDL2=1
    -DRETRO_STANDALONE=1
    -DRETRO_USE_MOD_LOADER=1
    -DRETRO_PLATFORM=5
)

target_compile_options(RetroEngine PRIVATE ${EMSCRIPTEN_COMPILER_FLAGS})

set(emsc_link_options
    -sMAIN_MODULE=1
    -sEXPORT_ALL=1
    
    -sALLOW_TABLE_GROWTH=1
    -sINITIAL_TABLE=200000
    
    
    -sINITIAL_MEMORY=1024MB      # 1GB to prevent memory growth during heavy audio/video loading
    -sMAXIMUM_MEMORY=2048MB      
    -sALLOW_MEMORY_GROWTH=1
    -sSTACK_SIZE=2MB             
    
    -sUSE_PTHREADS=1
    -sPTHREAD_POOL_SIZE=4
    -pthread
    
    -sUSE_SDL=2
    -sUSE_OGG=1
    
    -sFORCE_FILESYSTEM=1
    -lidbfs.js
    
    "-sEXPORTED_RUNTIME_METHODS=['FS','ccall','cwrap','getValue','setValue']"
    "-sEXPORTED_FUNCTIONS=['_main','_RSDK_Initialize','_RSDK_Configure']"
    
    -flto
)

target_link_libraries(RetroEngine libtheora)
target_link_options(RetroEngine PRIVATE ${emsc_link_options})

set(RETRO_MOD_LOADER TRUE)

if(RETRO_MOD_LOADER)
    set_target_properties(RetroEngine PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
    )
endif()

# Force the output to be a JavaScript file, which Emscripten will pair with the .wasm
set_target_properties(RetroEngine PROPERTIES
    SUFFIX ".js"
)
