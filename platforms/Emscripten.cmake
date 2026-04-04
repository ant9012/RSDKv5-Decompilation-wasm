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
    -sMAIN_MODULE=1                     # ← was 2; needs 1 for full stdlib (vsprintf etc.)
    -sALLOW_TABLE_GROWTH=1              # ← NEW: lets Game.wasm register its function pointers at runtime
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
    -Wl,--whole-archive
    ${THEORA_LIB}
    -Wl,--no-whole-archive
)
