GO_EASY_ON_ME=1
include theos/makefiles/common.mk

BUNDLE_NAME = ClearTheAirPrefBundle
ClearTheAirPrefBundle_OBJC_FILES = UISwitchCell.m UISliderCell.m UIImageCell.m UnlockSliderViewController.m PasscodeViewController.m StatusBarAndClockBarViewController.m OpacitySettingViewController.m SettingsManager.m
ClearTheAirPrefBundle_FILES = ClearTheAirPrefBundle.xm
ClearTheAirPrefBundle_INSTALL_PATH = /Library/PreferenceBundles
ClearTheAirPrefBundle_FRAMEWORKS = UIKit
ClearTheAirPrefBundle_PRIVATE_FRAMEWORKS = Preferences
ClearTheAirPrefBundle_LDFLAGS=-lsubstrate

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ClearTheAirPrefBundle.plist$(ECHO_END)
