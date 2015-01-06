GO_EASY_ON_ME = 1

THEOS_DEVICE_IP = 192.168.1.9

ARCHS = armv7 arm64

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 6.0
#ADDITIONAL_CFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = ReactionAtor
ReactionAtor_OBJC_FILES = ReactionAtor.m ReactionWindow.m BYQuickShotView.m
ReactionAtor_FRAMEWORKS = SystemConfiguration MobileCoreServices AudioToolbox UIKit QuartzCore Social Foundation CoreGraphics AVFoundation MediaPlayer MobileCoreServices MessageUI AssetsLibrary
ReactionAtor_LIBRARIES = activator

include $(THEOS_MAKE_PATH)/tweak.mk
