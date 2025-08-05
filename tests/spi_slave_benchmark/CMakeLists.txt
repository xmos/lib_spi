cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)

# Get JSON lists
file(READ ${CMAKE_CURRENT_LIST_DIR}/test_params.json params_json)

# Get individual fields from params_json
string(JSON arch_list GET ${params_json} arch)
string(JSON thread_profile_list GET ${params_json} THREAD_PROFILES)
string(JSON mode_list GET ${params_json} MODE)
string(JSON transfer_size_list GET ${params_json} TRANSFER_SIZE)
string(JSON miso_enabled_list GET ${params_json} MISO_ENABLED)

string(JSON arch_list_len LENGTH ${arch_list})
string(JSON thread_profile_list_len LENGTH ${thread_profile_list})
string(JSON mode_list_len LENGTH ${mode_list})
string(JSON transfer_size_list_len LENGTH ${transfer_size_list})
string(JSON miso_enabled_list_len LENGTH ${miso_enabled_list})


# Subtract one off each of the lengths because RANGE includes last element
math(EXPR arch_list_len "${arch_list_len} - 1")
math(EXPR thread_profile_list_len "${thread_profile_list_len} - 1")
math(EXPR mode_list_len "${mode_list_len} - 1")
math(EXPR transfer_size_list_len "${transfer_size_list_len} - 1")
math(EXPR miso_enabled_list_len "${miso_enabled_list_len} - 1")


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

        foreach(k RANGE 0 ${mode_list_len})
            string(JSON SPI_MODE GET ${mode_list} ${k})
                
            foreach(l RANGE 0 ${transfer_size_list_len})
                string(JSON SPI_TRANSFER_SIZE GET ${transfer_size_list} ${l})

                foreach(m RANGE 0 ${miso_enabled_list_len})
                    string(JSON MISO_ENABLED GET ${miso_enabled_list} ${m})

                    set(config ${COMBINED}_${BURNT_THREADS}_${MISO_ENABLED}_${SPI_MODE}_${SPI_TRANSFER_SIZE}_${arch})
                    message(STATUS "building config ${config}")

                    project(spi_slave_benchmark)
                    set(APP_HW_TARGET   ${target})

                    set(APP_COMPILER_FLAGS_${config}    ${CONFIG_COMPILER_FLAGS} 
                                                        -DCOMBINED=${COMBINED} 
                                                        -DBURNT_THREADS=${BURNT_THREADS}
                                                        -DMISO_ENABLED=${MISO_ENABLED}
                                                        -DSPI_MODE=${SPI_MODE}
                                                        -DTRANSFER_SIZE=SPI_TRANSFER_SIZE_${SPI_TRANSFER_SIZE}
                                                        -O2 
                                                        -g 
                                                        -Wno-reinterpret-alignment)

                    set(APP_INCLUDES src ../spi_slave_tester_common)

                    XMOS_REGISTER_APP()
                    message(STATUS "****${APP_COMPILER_FLAGS_${config}} ")

                    unset(APP_COMPILER_FLAGS_${config})
                    unset(CONFIG_COMPILER_FLAGS)
                endforeach()
            endforeach()
        endforeach()
    endforeach()
endforeach()
