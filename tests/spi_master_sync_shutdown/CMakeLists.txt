cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)

# Get JSON lists
file(READ ${CMAKE_CURRENT_LIST_DIR}/test_params.json params_json)

# Get individual fields from params_json
string(JSON arch_list GET ${params_json} arch)
string(JSON distributed_list GET ${params_json} DISTRIBUTED)
string(JSON cb_enabled_list GET ${params_json} CB_ENABLED)

string(JSON arch_list_len LENGTH ${arch_list})
string(JSON distributed_list_len LENGTH ${distributed_list})
string(JSON cb_enabled_list_len LENGTH ${cb_enabled_list})

# Subtract one off each of the lengths because RANGE includes last element
math(EXPR arch_list_len "${arch_list_len} - 1")
math(EXPR distributed_list_len "${distributed_list_len} - 1")
math(EXPR cb_enabled_list_len "${cb_enabled_list_len} - 1")


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
    foreach(j RANGE 0 ${distributed_list_len})
        string(JSON distributed GET ${distributed_list} ${j})

        foreach(k RANGE 0 ${cb_enabled_list_len})
            string(JSON cb_enabled GET ${cb_enabled_list} ${k})

            set(config ${distributed}_${cb_enabled}_${arch})
            message(STATUS "building config ${config}")

            project(spi_master_sync_shutdown)
            set(APP_HW_TARGET   ${target})

            set(APP_COMPILER_FLAGS_${config}    ${CONFIG_COMPILER_FLAGS} 
                                                -DDISTRIBUTED=${distributed} 
                                                -DCB_ENABLED=${cb_enabled}
                                                -O2 
                                                -g 
                                                -Wno-reinterpret-alignment)
            set(APP_INCLUDES src ../spi_master_tester_common)

            XMOS_REGISTER_APP()

            unset(APP_COMPILER_FLAGS_${config})
            unset(CONFIG_COMPILER_FLAGS)
        endforeach()
    endforeach()
endforeach()
