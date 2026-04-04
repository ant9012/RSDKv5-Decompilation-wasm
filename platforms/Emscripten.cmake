cmake_minimum_required(VERSION 3.10)

project(RetroEngine)

add_executable(RetroEngine ${RETRO_FILES})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC -O3")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -O3")

set(COMPILE_THEORA FALSE)
set(THEORA_DIR dependencies/all/libtheora)

add_library(libtheora STATIC
    ${THEORA_DIR}/lib/analyze.c
    ${THEORA_DIR}/lib/apiwrapper.c
    ${THEORA_DIR}/lib/bitpack.c
    ${THEORA_DIR}/lib/cpu.c
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

target_compile_options(libtheora PRIVATE -sUSE_OGG=1)

target_include_directories(libtheora PRIVATE ${THEORA_DIR}/include)
target_include_directories(RetroEngine PRIVATE ${THEORA_DIR}/include)

set(EMSCRIPTEN_FLAGS
    -sUSE_SDL=2
    -sUSE_OGG=1
    -sUSE_PTHREADS=1
    -pthread
    -DRSDK_REVISION=3
    -DRSDK_USE_SDL2=1
    -DRETRO_STANDALONE=1
    -DRETRO_USE_MOD_LOADER=1
    -DRETRO_PLATFORM=5
)

set(emsc_link_options
    # Memory
    -sINITIAL_MEMORY=536870912
    -sMAXIMUM_MEMORY=2147483648
    -sALLOW_MEMORY_GROWTH=1
    -sSTACK_SIZE=8388608

    # Threading
    -sUSE_PTHREADS=1
    -sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency
    -sPTHREAD_POOL_SIZE_STRICT=0
    -sPROXY_TO_PTHREAD=0
    -sOFFSCREEN_FRAMEBUFFER=1

    # Libraries
    -sUSE_SDL=2
    -sUSE_OGG=1

    # Filesystem
    -sFORCE_FILESYSTEM=1
    -lidbfs.js

    # Module settings
    -sMAIN_MODULE=1
    -sALLOW_TABLE_GROWTH=1
    -sEXIT_RUNTIME=0
    -sENVIRONMENT=web,worker
    -sMODULARIZE=0

    # Error handling
    -sASSERTIONS=1
    -sSTACK_OVERFLOW_CHECK=2
    -sNO_DISABLE_EXCEPTION_CATCHING

    # Exports
    "-sEXPORTED_RUNTIME_METHODS=['FS','ccall','cwrap','addFunction','removeFunction']"
    "-sEXPORTED_FUNCTIONS=['_main','_RSDK_Initialize','_RSDK_Configure','_malloc','_free']"

    # Async
    -sASYNCIFY=1
    -sASYNCIFY_STACK_SIZE=65536

    # Other
    -DRSDK_REVISION=3
    -lm
    -pthread
)

target_compile_options(RetroEngine PRIVATE ${EMSCRIPTEN_FLAGS})
target_link_libraries(RetroEngine libtheora)
target_link_options(RetroEngine PRIVATE ${emsc_link_options})

if(RETRO_MOD_LOADER)
    set_target_properties(RetroEngine PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
    )
endif()

set_target_properties(RetroEngine PROPERTIES
    SUFFIX ".js"
)
