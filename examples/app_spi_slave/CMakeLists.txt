cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)
project(app_spi_slave)

# Sandbox configuration
set(XMOS_SANDBOX_DIR ${CMAKE_CURRENT_LIST_DIR}/../../..)

# Target, xscope
set(APP_HW_TARGET XCORE-AI-EXPLORER)
set(APP_XSCOPE_SRCS config.xscope)

# Includes, Dependencies
list(APPEND APP_INCLUDES src)
include(${CMAKE_CURRENT_LIST_DIR}/../deps.cmake)

# Flags
set(
    APP_COMPILER_FLAGS
    -Os
    -g
    -report
    -Wall
    -Werror
    -DDEBUG_PRINT_ENABLE=1
)

XMOS_REGISTER_APP()
