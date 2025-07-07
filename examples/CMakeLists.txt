cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)

project(lib_camera_examples)

add_subdirectory(AN00160_using_SPI_master)
add_subdirectory(AN00160_using_SPI_master_fwk)
add_subdirectory(AN00161_using_SPI_slave)