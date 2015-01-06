GO_EASY_ON_ME = 1

THEOS_DEVICE_IP = 192.168.1.9

ARCHS = armv7 arm64

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 6.0
#ADDITIONAL_CFLAGS = -fobjc-arc


include theos/makefiles/common.mk

BUNDLE_NAME = Reaction
Reaction_FILES = Reaction.mm
Reaction_INSTALL_PATH = /Library/PreferenceBundles
Reaction_FRAMEWORKS = UIKit
Reaction_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Reaction.plist$(ECHO_END)
