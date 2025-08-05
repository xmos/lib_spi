cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)

# Get JSON lists
file(READ ${CMAKE_CURRENT_LIST_DIR}/test_params.json params_json)

# Get individual fields from params_json
string(JSON arch_list GET ${params_json} arch)
string(JSON spi_mode_list GET ${params_json} SPI_MODE)
string(JSON transfer_size_list GET ${params_json} TRANSFER_SIZE)

string(JSON arch_list_len LENGTH ${arch_list})
string(JSON spi_mode_list_len LENGTH ${spi_mode_list})
string(JSON transfer_size_list_len LENGTH ${transfer_size_list})

# Subtract one off each of the lengths because RANGE includes last element
math(EXPR arch_list_len "${arch_list_len} - 1")
math(EXPR spi_mode_list_len "${spi_mode_list_len} - 1")
math(EXPR transfer_size_list_len "${transfer_size_list_len} - 1")


set(APP_PCA_ENABLE ON)
set(XMOS_SANDBOX_DIR    ${CMAKE_CURRENT_LIST_DIR}/../../..)
include(${CMAKE_CURRENT_LIST_DIR}/../../examples/deps.cmake)


foreach(i RANGE 0 ${arch_list_len})
    string(JSON arch GET ${arch_list} ${i})
    if(arch STREQUAL "xs3")
        set(target "XK-EVK-XU316")
    elseif(arch STREQUAL "xs2")
        set(target "XCORE-200-EXPLORER")
    endif()
    foreach(j RANGE 0 ${spi_mode_list_len})
        string(JSON spi_mode GET ${spi_mode_list} ${j})

        foreach(j RANGE 0 ${transfer_size_list_len})
            string(JSON transfer_size GET ${transfer_size_list} ${j})


            set(config ${spi_mode}_${transfer_size}_${arch})
            message(STATUS "building config ${config}")

            project(spi_slave_ss_deassert)
            set(APP_HW_TARGET   ${target})

            set(APP_COMPILER_FLAGS_${config}    ${CONFIG_COMPILER_FLAGS} 
                                                -DSPI_MODE=${spi_mode} 
                                                -DTRANSFER_SIZE=${transfer_size} 
                                                -O2 
                                                -g 
                                                -Wno-reinterpret-alignment)
            set(APP_INCLUDES src ../spi_slave_tester_common)

            XMOS_REGISTER_APP()

            unset(APP_COMPILER_FLAGS_${config})
            unset(CONFIG_COMPILER_FLAGS)
        endforeach()
    endforeach()
endforeach()
