#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
TARGET_SUPPORTS_OMX_SERVICE := false
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from smith device
$(call inherit-product, device/motorola/smith/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := lineage_smith
PRODUCT_DEVICE := smith
PRODUCT_BRAND := motorola
PRODUCT_MODEL := motorola razr 5G
PRODUCT_MANUFACTURER := motorola
PRODUCT_SYSTEM_NAME := smith_retail

PRODUCT_AAPT_CONFIG := xxxhdpi
PRODUCT_AAPT_PREF_CONFIG := xxxhdpi

# Boot animation
$(call soong_config_set_bool,bootanimation,multidisplay,true)

TARGET_SCREEN_HEIGHT := 2142
TARGET_SCREEN_WIDTH := 876

PRODUCT_GMS_CLIENTID_BASE := android-motorola

# Build info
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="smith_retail-user 12 S2PS32.57-23-31 69268-82a27f release-keys" \
    BuildFingerprint="motorola/smith_retail/smith:12/S2PS32.57-23-31/69268-82a27f:user/release-keys" \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME)
