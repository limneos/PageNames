include theos/makefiles/common.mk

TWEAK_NAME = PageNames
PageNames_FILES = Tweak.xm
PageNames_FRAMEWORKS=UIKit
include $(THEOS_MAKE_PATH)/tweak.mk
