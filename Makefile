GO_EASY_ON_ME = 1
THEOS_DEVICE_IP = 192.168.1.92
#TARGET_CODESIGN_FLAGS ="-Sentitlements.plist"
export SDKVERSION=8.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
ADDITIONAL_CFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = Reaction
Reaction_FILES = Tweak.xm BYQuickShotView.m ReactionController.m ReactionView.m
Reaction_FRAMEWORKS = SystemConfiguration MobileCoreServices AudioToolbox UIKit QuartzCore Social Foundation CoreGraphics AVFoundation MediaPlayer MobileCoreServices MessageUI AssetsLibrary

TWEAK_TARGET_PROCESS = SpringBoard

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += reaction
SUBPROJECTS += reactionator
include $(THEOS_MAKE_PATH)/aggregate.mk
