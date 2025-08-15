cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)

project(lib_spi_examples)

add_subdirectory(app_spi_master)
add_subdirectory(app_spi_slave)