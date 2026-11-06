#
# Copyright (C) 2021-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from ovaltine device
$(call inherit-product, device/oneplus/ovaltine/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_ovaltine
PRODUCT_DEVICE := ovaltine
PRODUCT_MANUFACTURER := OnePlus
PRODUCT_BRAND := OnePlus
PRODUCT_MODEL := CPH2415

PRODUCT_GMS_CLIENTID_BASE := android-oneplus

# 机型指纹沿用 10T(CPH2415) 自身，基线固件 CPH2415_15.0.0.700(EX01)。
# 注意：不要把 wly 的 NE2213 / OP516FL1 带过来。
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="qssi-user 15 AP3A.240617.008 1763899742269 release-keys" \
    BuildFingerprint=OnePlus/CPH2415/OP5552L1:15/AP3A.240617.008/S.2122e42-d896-1:user/release-keys \
    DeviceName=OP5552L1 \
    DeviceProduct=CPH2415 \
    SystemDevice=OP5552L1 \
    SystemName=CPH2415
