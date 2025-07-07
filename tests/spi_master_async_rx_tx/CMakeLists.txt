cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)

# Get JSON lists
file(READ ${CMAKE_CURRENT_LIST_DIR}/test_params.json params_json)

# Get individual fields from params_json
string(JSON arch_list GET ${params_json} arch)
string(JSON thread_profile_list GET ${params_json} THREAD_PROFILES)
string(JSON speed_test_list GET ${params_json} SPEED_TESTS)
string(JSON transfer_width_list GET ${params_json} TRANSFER_WIDTH)
string(JSON spi_mode_list GET ${params_json} MODE)
string(JSON mosi_enabled_list GET ${params_json} MOSI_ENABLED)

string(JSON arch_list_len LENGTH ${arch_list})
string(JSON thread_profile_list_len LENGTH ${thread_profile_list})
string(JSON speed_test_list_len LENGTH ${speed_test_list})
string(JSON transfer_width_list_len LENGTH ${transfer_width_list})
string(JSON spi_mode_list_len LENGTH ${spi_mode_list})
string(JSON mosi_enabled_list_len LENGTH ${mosi_enabled_list})


# Subtract one off each of the lengths because RANGE includes last element
math(EXPR arch_list_len "${arch_list_len} - 1")
math(EXPR thread_profile_list_len "${thread_profile_list_len} - 1")
math(EXPR speed_test_list_len "${speed_test_list_len} - 1")
math(EXPR transfer_width_list_len "${transfer_width_list_len} - 1")
math(EXPR spi_mode_list_len "${spi_mode_list_len} - 1")
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

        foreach(l RANGE 0 ${speed_test_list_len})
            string(JSON SPEED_TESTS GET ${speed_test_list} ${l})

            foreach(m RANGE 0 ${mosi_enabled_list_len})
                string(JSON MOSI_ENABLED GET ${mosi_enabled_list} ${m})

                foreach(n RANGE 0 ${transfer_width_list_len})
                    string(JSON TRANSFER_WIDTH GET ${transfer_width_list} ${n})

                    foreach(o RANGE 0 ${spi_mode_list_len})
                        string(JSON SPI_MODE GET ${spi_mode_list} ${o})


                        set(config ${COMBINED}_${BURNT_THREADS}_${MOSI_ENABLED}_${SPEED_TESTS}_${TRANSFER_WIDTH}_${SPI_MODE}_${arch})
                        message(STATUS "building config ${config}")

                        project(spi_master_async_rx_tx)
                        set(APP_HW_TARGET   ${target})

                        set(APP_COMPILER_FLAGS_${config}    ${CONFIG_COMPILER_FLAGS} 
                                                            -DCOMBINED=${COMBINED} 
                                                            -DBURNT_THREADS=${BURNT_THREADS}
                                                            -DMOSI_ENABLED=${MOSI_ENABLED}
                                                            -DSPEED_TESTS=${SPEED_TESTS}
                                                            -DTRANSFER_WIDTH=${TRANSFER_WIDTH}
                                                            -DSPI_MODE=${SPI_MODE}
                                                            -O2 
                                                            -g 
                                                            -Wno-reinterpret-alignment)

                        set(APP_INCLUDES src ../spi_master_tester_common)

                        XMOS_REGISTER_APP()
                        message(STATUS "****${APP_COMPILER_FLAGS_${config}} ")

                        unset(APP_COMPILER_FLAGS_${config})
                        unset(CONFIG_COMPILER_FLAGS)
                    endforeach()
                endforeach()
            endforeach()
        endforeach()
    endforeach()
endforeach()
