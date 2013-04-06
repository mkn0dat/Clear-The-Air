static BOOL TweakEnabled = nil;
static CGFloat Transparency = 0.0;


@interface SBAwayController : NSObject
- (BOOL)isLocked;
+ (id)sharedAwayController;
@end


%hook SBWallpaperView

- (void)setAlpha:(float)alpha
{    
    SBAwayController *sharedController = [%c(SBAwayController) sharedAwayController];
    if (!TweakEnabled || [sharedController isLocked]) {
        %orig(alpha); return;
    }
    if(alpha < Transparency){
        return;
    }
    %orig(alpha);
}

%end


static void ReloadSettings(void)
{
	NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.mkn0dat.cleartheair.plist"];
    TweakEnabled = [[settings objectForKey:@"Enabled"] boolValue];
    Transparency = [[settings objectForKey:@"Transparency"] floatValue];
	[settings release];
}

static void SettingsChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	ReloadSettings();
}


%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    ReloadSettings();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SettingsChangedCallback, CFSTR("com.mkn0dat.cleartheair.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    %init();
	[pool drain];
}