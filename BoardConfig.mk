#
# Copyright (C) 2017-2020 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

-include device/motorola/sm7250-common/BoardConfigCommon.mk

DEVICE_PATH := device/motorola/smith

# Display
TARGET_SCREEN_DENSITY := 360

# HIDL
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifests/manifest_smith.xml
ODM_MANIFEST_SKUS += dn n
ODM_MANIFEST_DN_FILES := $(DEVICE_PATH)/manifests/manifest_dn.xml
ODM_MANIFEST_N_FILES  := $(DEVICE_PATH)/manifests/manifest_n.xml

# Kernel
TARGET_KERNEL_CONFIG := vendor/smith_defconfig

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

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
