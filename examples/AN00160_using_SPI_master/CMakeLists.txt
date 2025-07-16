cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)
project(app_spi_master)

# Sandbox configuration
set(XMOS_SANDBOX_DIR ${CMAKE_CURRENT_LIST_DIR}/../../..)

# Target, xscope
set(APP_HW_TARGET XCORE-AI-EXPLORER)
set(APP_XSCOPE_SRCS config.xscope)

# Includes, Dependencies
list(APPEND APP_INCLUDES src)
include(${CMAKE_CURRENT_LIST_DIR}/../deps.cmake)

# Flags
set(COMPILER_FLAGS_COMMON
    -Os
    -g
    -report
    -Wall
    -Werror
)

set(APP_COMPILER_FLAGS_SYNC
    ${COMPILER_FLAGS_COMMON})

set(APP_COMPILER_FLAGS_ASYNC
    ${COMPILER_FLAGS_COMMON}
    -DSPI_USE_ASYNC=1)


XMOS_REGISTER_APP()