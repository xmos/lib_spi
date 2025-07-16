cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)

# Get JSON lists
file(READ ${CMAKE_CURRENT_LIST_DIR}/test_params.json params_json)

# Get individual fields from params_json
string(JSON arch_list GET ${params_json} arch)
string(JSON burnt_threads_list GET ${params_json} BURNT_THREADS)
string(JSON spi_mode_list GET ${params_json} SPI_MODE)
string(JSON miso_mosi_enabled_list GET ${params_json} MISO_MOSI_ENABLED)

string(JSON arch_list_len LENGTH ${arch_list})
string(JSON burnt_threads_list_len LENGTH ${burnt_threads_list})
string(JSON spi_mode_list_len LENGTH ${spi_mode_list})
string(JSON miso_mosi_enabled_list_len LENGTH ${miso_mosi_enabled_list})


# Subtract one off each of the lengths because RANGE includes last element
math(EXPR arch_list_len "${arch_list_len} - 1")
math(EXPR burnt_threads_list_len "${burnt_threads_list_len} - 1")
math(EXPR spi_mode_list_len "${spi_mode_list_len} - 1")
math(EXPR miso_mosi_enabled_list_len "${miso_mosi_enabled_list_len} - 1")


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
    foreach(j RANGE 0 ${burnt_threads_list_len})
        string(JSON burnt_threads GET ${burnt_threads_list} ${j})

        foreach(k RANGE 0 ${spi_mode_list_len})
            string(JSON SPI_MODE GET ${spi_mode_list} ${k})
                
            foreach(l RANGE 0 ${miso_mosi_enabled_list_len})
                string(JSON miso_mosi_enabled GET ${miso_mosi_enabled_list} ${l})

                set(config ${burnt_threads}_${SPI_MODE}_${miso_mosi_enabled}_${arch})
                message(STATUS "building config ${config}")

                project(spi_master_sync_benchmark)
                set(APP_HW_TARGET   ${target})

                string(FIND "${config}" "mosi" pos)
                if(NOT pos EQUAL -1)
                    list(APPEND CONFIG_COMPILER_FLAGS "-DMOSI_ENABLED=1")
                else()
                    list(APPEND CONFIG_COMPILER_FLAGS "-DMOSI_ENABLED=0")
                endif()

                string(FIND "${config}" "miso" pos)
                if(NOT pos EQUAL -1)
                    list(APPEND CONFIG_COMPILER_FLAGS "-DMISO_ENABLED=1")
                else()
                    list(APPEND CONFIG_COMPILER_FLAGS "-DMISO_ENABLED=0")
                endif()

                set(APP_INCLUDES src ../spi_master_tester_common)

                set(APP_COMPILER_FLAGS_${config}    ${CONFIG_COMPILER_FLAGS} 
                                                    -DBURNT_THREADS=${burnt_threads} 
                                                    -DSPI_MODE=${SPI_MODE}
                                                    -O2 
                                                    -g 
                                                    -Wno-reinterpret-alignment)


                XMOS_REGISTER_APP()
                message(STATUS "****${APP_COMPILER_FLAGS_${config}} ")

                unset(APP_COMPILER_FLAGS_${config})
                unset(CONFIG_COMPILER_FLAGS)
            endforeach()
        endforeach()
    endforeach()
endforeach()
