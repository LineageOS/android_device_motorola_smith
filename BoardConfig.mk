#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from sm7250-common
include device/motorola/sm7250-common/BoardConfigCommon.mk

DEVICE_PATH := device/motorola/smith

# Display
TARGET_SCREEN_DENSITY := 360

# HIDL
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifests/manifest_smith.xml
ODM_MANIFEST_SKUS += dn n
ODM_MANIFEST_DN_FILES := $(DEVICE_PATH)/manifests/manifest_dn.xml
ODM_MANIFEST_N_FILES  := $(DEVICE_PATH)/manifests/manifest_n.xml

# Kernel modules - Audio
TARGET_MODULE_ALIASES += \
    snd-soc-aov-trigger.ko:aov_trigger.ko \
    snd-soc-cs35l41-i2c.ko:cirrus_cs35l41-i2c.ko \
    snd-soc-cs35l41-spi.ko:cirrus_cs35l41-spi.ko \
    snd-soc-cs35l41.ko:cirrus_cs35l41.ko \
    snd-soc-cs47l35.ko:cirrus_cs47l35.ko \
    snd-soc-madera.ko:cirrus_madera.ko \
    snd-soc-wm-adsp.ko:cirrus_wm_adsp.ko \
    irq-madera.ko:cirrus_irq-madera.ko

# Partitions
BOARD_DTBOIMG_PARTITION_SIZE := 8388608

# Properties
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/product.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Copy to recovery
BOARD_RECOVERY_KERNEL_MODULES_LOAD := \
    utags \
    mmi_annotate \
    mmi_info \
    tzlog_dump \
    bq27426_fg_mmi \
    qpnp-power-on-mmi \
    qpnp-smbcharger-mmi \
    slg51000 \
    sensors_class \
    mmi_relay \
    sx933x_sar \
    touchscreen_mmi \
    sec_mmi \
    synaptics_mmi_class \
    synaptics_mmi_class_fw_update \
    synaptics_mmi_class_rmi_dev \
    synaptics_mmi_class_test_reporting

RECOVERY_KERNEL_MODULES := $(addsuffix .ko,$(BOARD_RECOVERY_KERNEL_MODULES_LOAD))

# Security
VENDOR_SECURITY_PATCH := 2022-08-01

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Inherit the proprietary files
include vendor/motorola/smith/BoardConfigVendor.mk
