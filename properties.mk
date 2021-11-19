#
# Properties for smith
#

# Firmware
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.hw.modem_version=.

# Graphics
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.sf.color_mode=9 \
    vendor.display.window_rect=102,0,102,0

# Recovery
PRODUCT_PROPERTY_OVERRIDES += \
    ro.recovery.ui.margin_height=102 \
    ro.recovery.ui.margin_width=102

# Sensor
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.vendor.sensors.dual_als=1 \
    ro.vendor.sensors.mot_ltv=true \
    persist.vendor.sensors.hal_trigger_ssr=false \
    persist.vendor.sensors.odl.adsp=true
