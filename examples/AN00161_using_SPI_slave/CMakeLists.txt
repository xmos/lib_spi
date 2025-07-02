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
list(APPEND APP_DEPENDENT_MODULES "lib_spi")

# Flags
set(
    APP_COMPILER_FLAGS
    -Os
    -g
    -report
    -Wall
    -Werror
)

XMOS_REGISTER_APP()