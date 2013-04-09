#import <UIKit/UIStatusBar.h>

static BOOL TweakEnabled = nil;
static CGFloat Transparency = 0.0;
static BOOL Adjustable = YES;
static BOOL KeepOpacity = NO;

@interface SBAwayView : NSObject
@end

@interface SBUIController : NSObject
+ (id)sharedInstance;
@end

@interface SBAwayController : NSObject
- (BOOL)isLocked;
+ (id)sharedAwayController;
- (id)awayView;
@end

@interface SBWallpaperView : UIImageView
@end

@interface SBIconScrollView : UIScrollView
@end


@interface SBIconController : NSObject
{
    SBIconScrollView *_scrollView;
}
- (SBIconScrollView *)scrollView;
+ (id)sharedInstance;
@end

@interface UIStatusBarBackgroundView : UIView
@end


%hook SBIconController

- (SBIconScrollView *)scrollView
{
	return MSHookIvar<SBIconScrollView *>(self, "_scrollView");
}

%end


%hook UIStatusBarBackgroundView
- (void)setAlpha:(float)alpha
{
    if (TweakEnabled && KeepOpacity){
        UIScrollView *aScrollView = [[%c(SBIconController) sharedInstance] scrollView];
        CGPoint kOffset = [aScrollView contentOffset];
        CGRect kRect = [[UIScreen mainScreen] bounds];
        if (kOffset.x < kRect.size.width){
            %orig(1.0);
            return;
        }
    }
    %orig(alpha);
}
%end


%hook SBAwayController

- (void)setDeviceLocked:(BOOL)arg1
{
    if (arg1){
        Adjustable = YES;
    }    
    %orig(arg1);
}
%end

%hook SBAwayView

- (void)finishedAnimatingIn
{
    %orig;
    Adjustable = YES;
}

- (void)finishedAnimatingOut
{
    %orig;
    Adjustable = NO;
}

%end


%hook SBWallpaperView

- (void)setAlpha:(float)alpha
{
    if (!TweakEnabled || Adjustable || [[%c(SBAwayController) sharedAwayController] isLocked]) {
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
    KeepOpacity = [[settings objectForKey:@"KeepOpacity"] boolValue];
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