cmake_minimum_required(VERSION 3.10)

project(RetroEngine)

add_executable(RetroEngine ${RETRO_FILES})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC -O3")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -O3")

# we're gonna handle libtheora here, because usually, COMPILE_THEORA directs
# to the android dependencies, can't just set THEORA_DIR - because CMakeLists.txt
# immediately changes it
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

target_compile_options(libtheora PRIVATE ${THEORA_FLAGS} -sUSE_OGG=1)

target_include_directories(libtheora PRIVATE ${THEORA_DIR}/include)
target_include_directories(RetroEngine PRIVATE ${THEORA_DIR}/include)
target_link_libraries(RetroEngine libtheora)

set(EMSCRIPTEN_FLAGS
    -sUSE_SDL=2
    -sUSE_OGG=1
    -sUSE_PTHREADS=1
    -DRSDK_REVISION=3
    -DRSDK_USE_SDL2=1
    -DRETRO_STANDALONE=1
    -DRETRO_USE_MOD_LOADER=1
    -DRETRO_PLATFORM=5
)

set(emsc_link_options
    # Memory settings - fixed for pthread compatibility
    -sINITIAL_MEMORY=268435456          # 256MB (TOTAL_MEMORY is deprecated)
    -sMAXIMUM_MEMORY=2147483648         # 2GB max
    -sALLOW_MEMORY_GROWTH=1
    -sSTACK_SIZE=5242880                # 5MB stack
    
    # Threading
    -sUSE_PTHREADS=1
    -sPTHREAD_POOL_SIZE=4
    -sPROXY_TO_PTHREAD=1                # Critical for memory growth with threads
    
    # Libraries
    -sUSE_SDL=2
    -sUSE_OGG=1
    
    # Filesystem
    -sFORCE_FILESYSTEM=1
    -lidbfs.js
    
    # Module settings
    -sMAIN_MODULE=1
    -sEXPORT_ALL=1
    
    # Exports
    "-sEXPORTED_RUNTIME_METHODS=['FS','ccall','cwrap']"
    "-sEXPORTED_FUNCTIONS=['_main','_RSDK_Initialize','_RSDK_Configure']"
    
    # Other
    -DRSDK_REVISION=3
    -lm
    -pthread
    -Wl,--whole-archive
    ${THEORA_LIB}
    -Wl,--no-whole-archive
)

target_compile_options(RetroEngine PRIVATE ${EMSCRIPTEN_FLAGS})
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
