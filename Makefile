THEOS = /var/theos
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TaobaoEnhancer
TaobaoEnhancer_FILES = Tweak.x
TaobaoEnhancer_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
