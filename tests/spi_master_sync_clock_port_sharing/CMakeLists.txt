cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)

set(APP_PCA_ENABLE ON)
set(XMOS_SANDBOX_DIR    ${CMAKE_CURRENT_LIST_DIR}/../../..)
include(${CMAKE_CURRENT_LIST_DIR}/../../examples/deps.cmake)

project(spi_master_sync_clock_port_sharing)
set(target "XK-EVK-XU316")
set(APP_HW_TARGET   ${target})

set(COMPILER_FLAGS_COMMON           -O2
                                    -g 
                                    -Wno-reinterpret-alignment)


set(APP_COMPILER_FLAGS_COMBINED     ${COMPILER_FLAGS_COMMON} 
                                    -DCOMBINED=1)

set(APP_COMPILER_FLAGS_NOT_COMBINED ${COMPILER_FLAGS_COMMON} 
                                    -DCOMBINED=0)


set(APP_INCLUDES src ../spi_master_tester_common)

XMOS_REGISTER_APP()
