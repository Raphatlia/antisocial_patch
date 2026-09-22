ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = antisocial_patch
antisocial_patch_FILES = Tweak.xm
antisocial_patch_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk