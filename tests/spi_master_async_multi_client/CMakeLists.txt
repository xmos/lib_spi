cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)

# Get JSON lists
file(READ ${CMAKE_CURRENT_LIST_DIR}/test_params.json params_json)

# Get individual fields from params_json
string(JSON arch_list GET ${params_json} arch)
string(JSON thread_profile_list GET ${params_json} THREAD_PROFILES)
string(JSON mosi_enabled_list GET ${params_json} MOSI_ENABLED)

string(JSON arch_list_len LENGTH ${arch_list})
string(JSON thread_profile_list_len LENGTH ${thread_profile_list})
string(JSON mosi_enabled_list_len LENGTH ${mosi_enabled_list})


# Subtract one off each of the lengths because RANGE includes last element
math(EXPR arch_list_len "${arch_list_len} - 1")
math(EXPR thread_profile_list_len "${thread_profile_list_len} - 1")
math(EXPR mosi_enabled_list_len "${mosi_enabled_list_len} - 1")


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
    foreach(j RANGE 0 ${thread_profile_list_len})
        string(JSON thread_profile GET ${thread_profile_list} ${j})
        string(JSON COMBINED GET ${thread_profile} COMBINED)
        string(JSON BURNT_THREADS GET ${thread_profile} BURNT_THREADS)

        foreach(l RANGE 0 ${mosi_enabled_list_len})
            string(JSON mosi_enabled GET ${mosi_enabled_list} ${l})

            set(config ${COMBINED}_${BURNT_THREADS}_${mosi_enabled}_${arch})
            message(STATUS "building config ${config}")

            project(spi_master_async_multi_client)
            set(APP_HW_TARGET   ${target})

            set(APP_COMPILER_FLAGS_${config}    ${CONFIG_COMPILER_FLAGS} 
                                                -DBURNT_THREADS=${BURNT_THREADS} 
                                                -DCOMBINED=${COMBINED}
                                                -DMOSI_ENABLED=${mosi_enabled}
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
