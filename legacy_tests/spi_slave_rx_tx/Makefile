# The TARGET variable determines what target system the application is
# compiled for. It either refers to an XN file in the source directories
# or a valid argument for the --target option when compiling
TARGET = XCORE-AI-EXPLORER

# The APP_NAME variable determines the name of the final .xe file. It should
# not include the .xe postfix. If left blank the name will default to
# the project name
APP_NAME = spi_slave_rx_tx

# The USED_MODULES variable lists other module used by the application.
USED_MODULES = lib_spi

# The flags passed to xcc when building the application
# You can also set the following to override flags for a particular language:
# XCC_XC_FLAGS, XCC_C_FLAGS, XCC_ASM_FLAGS, XCC_CPP_FLAGS
# If the variable XCC_MAP_FLAGS is set it overrides the flags passed to
# xcc for the final link (mapping) stage.
COMMON_FLAGS = -O2 -g

FULL_LOAD = 0 1
MISO_ENABLED = 0 1
SPI_MODE = 0 1 2 3

define create_flags
XCC_FLAGS_$(1)_$(2)_$(3) = $(COMMON_FLAGS) -DFULL_LOAD=$(1) -DMISO_ENABLED=$(2) -DSPI_MODE=$(3)
endef

$(foreach load,$(FULL_LOAD),\
	$(foreach miso,$(MISO_ENABLED),\
		$(foreach mode,$(SPI_MODE),\
			$(eval $(call create_flags,$(load),$(miso),$(mode))))))

#=============================================================================
# The following part of the Makefile includes the common build infrastructure
# for compiling XMOS applications. You should not need to edit below here.

XMOS_MAKE_PATH ?= ../..
-include $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common
