#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)
namespace_imports = [
    'hardware/motorola',
    'vendor/motorola/sm7250-common',
    'vendor/qcom/opensource/display',
]
blob_fixups: blob_fixups_user_type = {
    'vendor/etc/libnfc-hal-st.conf': blob_fixup()
        # I33d07604e87a2d9466a3a857e281ee4b611330a8 "Switch NFC from HIDL to AIDL"
        .regex_replace('White list', 'Allow list')
        .regex_replace('DEVICE_HOST_WHITE_LIST', 'DEVICE_HOST_ALLOW_LIST'),
    # Patch configureRpcThreadpool 
    'vendor/lib64/vendor.qti.hardware.camera.postproc@1.0-service-impl.so': blob_fixup()
        .sig_replace('CC 0A 00 94', '1F 20 03 D5'),
    # rename moto modified tinyalsa
    ('vendor/lib/motorola.hardware.audio.adspd@1.0-impl.so', 'vendor/lib64/motorola.hardware.audio.adspd@1.0-impl.so'): blob_fixup()
        .replace_needed('libtinyalsa.so', 'libtinyalsa-moto.so'),
    # __lttf2 shim 
    'vendor/lib64/libvidhance.so': blob_fixup()
        .add_needed('libcomparetf2_shim.so'),
    # sensors shim
    'vendor/lib64/sensors.moto.so': blob_fixup()
        .add_needed('libbase_shim.so'),
}  # fmt: skip
module = ExtractUtilsModule(
    'smith',
    'motorola',
    namespace_imports=namespace_imports,
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    add_firmware_proprietary_file=False,
)
if __name__ == '__main__':
    utils = ExtractUtils.device_with_common(
        module, 'sm7250-common', module.vendor
    )
    utils.run()


