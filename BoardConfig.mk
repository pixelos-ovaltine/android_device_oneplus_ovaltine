#
# Copyright (C) 2021-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Include the common OEM chipset BoardConfig.
include device/oneplus/sm8450-common/BoardConfigCommon.mk

DEVICE_PATH := device/oneplus/ovaltine

# HIDL
# 10T 有 eSE/NFC 与 qti esepowermanager 两个 HIDL HAL；
# sm8450-common 的 vintf/manifest.xml 未声明它们，必须由机型补。
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest.xml

# Partitions
# 10T 的 super 分区布局沿用 stock：super 总大小与 common 默认一致（11274289152），
# 只在 product 上预留 900000000 B。
ifeq (,$(filter true, $(WITHOUT_RESERVED_SIZE) $(WITH_GMS)))
BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE := 900000000
endif

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Recovery
# 10T: 1080x2412 → xxhdpi；状态栏/挖孔高度与 10 Pro 不同（103 vs 126）。
TARGET_RECOVERY_DENSITY := xxhdpi
TARGET_RECOVERY_UI_MARGIN_HEIGHT := 103

# Include the proprietary files BoardConfig.
include vendor/oneplus/ovaltine/BoardConfigVendor.mk

# vendor/extra board config
-include vendor/extra/BoardConfigExtra.mk

# Third-party Adreno driver (Meta Quest 3) selection.
# vendor/oneplus/sm8450-common 的 Android.bp 里 select 只有 "true"/"false" 两个
# 分支、没有 default，所以这个变量必须显式赋值，留 undefined 会直接让 soong
# bootstrap 失败：
#   soong_config_variable("gpu_oplus", "driver_q3") had value undefined
# 这里设 false 走 OEM 原厂驱动（proprietary/vendor/lib64/egl/...）。
GPU_DRIVER_Q3 ?= false
$(call soong_config_set,gpu_oplus,driver_q3,$(GPU_DRIVER_Q3))

# [xi-a17] vendor/oneplus/ovaltine 的 blob 仓是用旧版 extract-files 生成的，
# 全部走 PRODUCT_COPY_FILES 拷 .so；A17 的 build 会拒绝 ELF 放进 PRODUCT_COPY_FILES
# （build/make/core/Makefile:125「found ELF prebuilt」）。
# 这是 AOSP 官方给的兼容开关（Makefile:127），开启后跳过该检查。
# 彻底修法是重新用 24.0 版 extract-files 生成 vendor 仓（走 cc_prebuilt_library_shared）。
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
