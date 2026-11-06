#
# Copyright (C) 2021-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# 本树骨架取自 pjgowtham/android_device_oneplus_wly@lineage-24.0（24.0 已验证可出包），
# 机型数据替换为 OnePlus 10T / ovaltine（CPH2415）自身。
# 关键差异：wly 是 waipio（SM8450，1440p，有静音键，有 Pixelworks iris），
#           ovaltine 是 cape（SM8475，1080p，无静音键，无 Pixelworks）。

# AAPT
# 10T 是 1080x2412（xxhdpi），wly 是 1440x3216（xxxhdpi），不能沿用。
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Audio
# 10T(CPH2415) 的 audio XML 取自 10T 自身（旧 ovaltine 树）：
# ODM 侧文件名是 mixer_paths.xml / resourcemanager.xml，
# 且 10T 树没有 sound_trigger_*.xml（不要从 wly 抄）。
QCV_FAMILY_SKUS := taro cape

PRODUCT_COPY_FILES += \
$(foreach DEVICE_SKU, $(QCV_FAMILY_SKUS), \
    $(LOCAL_PATH)/audio/mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_$(DEVICE_SKU)/mixer_paths_waipio_mtp.xml \
    $(LOCAL_PATH)/audio/resourcemanager.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_$(DEVICE_SKU)/resourcemanager_waipio_mtp.xml)

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/backend_conf.xml:$(TARGET_COPY_OUT_ODM)/etc/backend_conf.xml \
    $(LOCAL_PATH)/audio/mixer_paths.xml:$(TARGET_COPY_OUT_ODM)/etc/mixer_paths.xml \
    $(LOCAL_PATH)/audio/resourcemanager.xml:$(TARGET_COPY_OUT_ODM)/etc/resourcemanager.xml \
    $(LOCAL_PATH)/audio/usecaseKvManager.xml:$(TARGET_COPY_OUT_ODM)/etc/usecaseKvManager.xml \
    $(LOCAL_PATH)/audio/usecaseKvManager.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usecaseKvManager.xml

# Boot animation
TARGET_SCREEN_HEIGHT := 2412
TARGET_SCREEN_WIDTH := 1080

# Display
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/display_id_4630947180710147970.xml:$(TARGET_COPY_OUT_VENDOR)/etc/displayconfig/display_id_4630947180710147969.xml

# oplus_udfps 在 qtidisplay 命名空间里声明为 bool_variables → 必须用 soong_config_set_bool
# （wly 树用的是 soong_config_set 字符串写法，与 bool 声明不匹配，不要照抄）
$(call soong_config_set_bool,qtidisplay,oplus_udfps,true)
# 10T(ovaltine) 无 Pixelworks iris 硬件，不设 pxlw_vendor_namespace；
# 否则 display 的 soong_config select 会要求 libpwirisfeature。
# （wly 的 device.mk 有这一行，已删除。）

# Fingerprint
# 10T 用 stock HAL（odm 里注册 IFingerprint/default），
# 不需要 HIDL 2.3 service，也不需要 AIDL proxy。
# PRODUCT_PACKAGES += \
#     android.hardware.biometrics.fingerprint@2.3-service.oplus

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml

$(call soong_config_set,surfaceflinger,udfps_lib,//hardware/oplus:libudfps_extension.oplus)

# NFC
PRODUCT_PACKAGES += \
    android.hardware.nfc-service.nxp \
    com.android.nfc_extras \
    Tag

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \
    frameworks/native/data/etc/com.android.nfc_extras.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.android.nfc_extras.xml \
    frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml \
    vendor/oneplus/sm8450-common/proprietary/vendor/etc/libnfc-nxp.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libnfc-nxp.conf \
    vendor/oneplus/sm8450-common/proprietary/vendor/etc/libnfc-nci.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libnfc-nci.conf \
    vendor/oneplus/sm8450-common/proprietary/vendor/firmware/sn100u.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/sn100u.bin

# Overlays
# 10T 没有三段式静音键，不打包 KeyHandlerResTarget（wly 有，已删除）。
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay-lineage

PRODUCT_PACKAGES += \
    OPlusFrameworksResTarget \
    OPlusSettingsProviderResTarget \
    OPlusSettingsResTarget \
    OPlusSystemUIResTarget

# Power
$(call soong_config_set,qtipower,mode_ext_lib,power-ext-oplus)

# PowerShare
PRODUCT_PACKAGES += \
    vendor.lineage.powershare-service.oplus

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Inherit from the common OEM chipset makefile.
$(call inherit-product, device/oneplus/sm8450-common/common.mk)

# Inherit from the proprietary files makefile.
$(call inherit-product, vendor/oneplus/ovaltine/ovaltine-vendor.mk)

# vendor/extra (LineageOS community extras)
$(call inherit-product-if-exists, vendor/extra/product.mk)

# adb root on a fresh flash; the developer option still overrides it.
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += persist.sys.root_access=3
