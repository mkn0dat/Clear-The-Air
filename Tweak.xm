#import <UIKit/UIStatusBar.h>
#import <QuartzCore/QuartzCore.h>

//forSpotLightSettings
static BOOL TweakEnabled = YES;
static BOOL Adjustable = YES;
static BOOL KeepOpacity = NO;
static BOOL PitchDark = NO;
static BOOL NotStartKeyboard = NO;
static CGFloat Opacity = 1.0;

//forLockscreenSettings
static float StatusBar=0.0f;
static float ClockBarBackground=0.0f;
static float SliderBackground=0.0f;
static float Slider=1.0f;
static float SliderDitch = 0.0f;
static float CameraGrabber=1.0f;
static float PasscodeField = 0.0f;
static float PressedKeypad = 0.2f;
static float Keypad = 0.2f;

static UIImage *PressedImageCache = nil;
static UIImage *KeypadImageCache = nil;

static BOOL RemoveSliderText = NO;
static BOOL HomeScreenAlso = NO;
static BOOL Enabled = YES;
static BOOL Locked=NO;
static BOOL AbsolutelyClockBar=NO;
static BOOL AbsolutelySliderBackground=NO;

static BOOL ReloadPressedKeypad = NO;
static BOOL ReloadKeypad = NO;
static NSMutableSet *instances = nil;


@interface SBUIController : NSObject
+ (id)sharedInstance;
@end

@interface SBAwayController : NSObject
- (BOOL)isLocked;
+ (id)sharedAwayController;
- (id)awayView;
- (void)foo:(BOOL)isLocked;
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

@interface TPLockKnobView : UIView
@end

@interface TPBottomLockBar : UIView
- (UIImageView*)backgroundView;
- (TPLockKnobView*)knobView;
@end

@interface SBAwayLockBar : TPBottomLockBar
- (UIImageView *)cameraGrabber;
@end

@interface TPLCDView : UIView
@end

@interface SBDeviceLockEntryField : UIView
@end

@interface SBDeviceLockKeypad : NSObject
@end


#pragma mark SpotLight


%hook SBIconController

- (SBIconScrollView *)scrollView
{
	return MSHookIvar<SBIconScrollView *>(self, "_scrollView");
}

%end



%hook SBAwayController

%new(v@:B)
- (void)foo:(BOOL)isLocked
{
    Locked = isLocked;
    if (isLocked) Adjustable = YES;
    for (UIStatusBarBackgroundView *object in instances){
        [object setAlpha:1.0f];
    }   
}

- (void)setLocked:(BOOL)arg1
{
    [self foo:arg1]; %orig(arg1);
}

- (void)setDeviceLocked:(BOOL)arg1
{
    [self foo:arg1]; %orig(arg1);
}

%end


@interface SBSlidingAlertDisplay
@end

%hook SBSlidingAlertDisplay

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
    if (!TweakEnabled || Adjustable|| Locked) {
        %orig(alpha); return;
    }
    
    if (PitchDark){
        UIScrollView *aScrollView = [[%c(SBIconController) sharedInstance] scrollView];
        CGRect kRect = [[UIScreen mainScreen] bounds];
        CGPoint kOffset = [aScrollView contentOffset];
        alpha = kOffset.x/kRect.size.width;
        %orig(alpha);
        return;
    }

    float transparency = 1 - Opacity;
    if(alpha < transparency){
        %orig((!alpha)? alpha : transparency);
        return;
    }
    %orig(alpha);
}

%end

#pragma mark Lockscreen

@interface UIImage (addingAlpha)
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;
- (BOOL)saveToCTAWithName:(NSString *)name;
@end

@implementation UIImage (addingAlpha)

- (BOOL)saveToCTAWithName:(NSString *)name
{
    NSData *data = UIImagePNGRepresentation(self);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@@2x.png",[documentsDirectory stringByAppendingPathComponent:@"CTA"],name];
    return [data writeToFile:filePath atomically:YES];
}

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha
{
    if (!Enabled){
        return self;
    }
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, self.CGImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end



%hook SBAwayLockBar

%new(@@:)
- (TPLockKnobView *)knobView
{
    return MSHookIvar<TPLockKnobView *>(self, "_knobView");
}

%new(@@:)
- (UIImageView*)backgroundView
{
    return MSHookIvar<UIImageView *>(self, "_backgroundView");
}

//------- Shadow -------//
- (void)setAlpha:(float)alpha
{
    for (UIView *view in self.subviews){
        if ([view isMemberOfClass:NSClassFromString(@"UIImageView")]){
            if(view.frame.size.height == 3 && AbsolutelySliderBackground && Enabled){
                UIImageView* kView = (UIImageView *)view;
                kView.image = nil;
            }
        }
    }
    %orig(alpha);
}


-(id)initWithFrame:(CGRect)frame knobImage:(id)image
{
//------- Slider -------//
    [image saveToCTAWithName:@"Slider"];
    self = %orig(frame,[image imageByApplyingAlpha:Slider]);

//------- Slider background -------//
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(iOSVersion >= 6.0) {
        UIImageView *sliderBackgroundView = [self backgroundView];
        UIImage *sliderBackgroundImage = sliderBackgroundView.image;
        [sliderBackgroundImage saveToCTAWithName:@"SliderBackground"];
        [sliderBackgroundView setImage:[sliderBackgroundImage imageByApplyingAlpha:SliderBackground]];
    } else {
        for (id object in self.subviews){
            if ([object isMemberOfClass:NSClassFromString(@"UIImageView")]){
                UIImageView *sliderBackgroundView = (UIImageView *)object;
                UIImage *sliderBackgroundImage = sliderBackgroundView.image;
                [sliderBackgroundImage saveToCTAWithName:@"SliderBackground"];
                [sliderBackgroundView setImage:[sliderBackgroundImage imageByApplyingAlpha:SliderBackground]];
            }
        }
    }
    
//------- Slider ditch -------//
    UIImageView *sliderDitchView = (UIImageView *)[[self knobView] superview];
    UIImage *ditchImage = sliderDitchView.image;
    [ditchImage saveToCTAWithName:@"SliderDitch"];
    [sliderDitchView setImage:[[ditchImage imageByApplyingAlpha:SliderDitch] stretchableImageWithLeftCapWidth:12 topCapHeight:12]];    
    return self;
}

%end



%hook SBAwayLockBar

%new(@@:)
- (UIImageView*)cameraGrabber
{
    return MSHookIvar<UIImageView *>(self, "_cameraGrabber");
}

//------- Camera Grabber -------//
-(void)setShowsCameraGrabber:(BOOL)grabber
{
    UIImage *cameraGrabberImage = [[self cameraGrabber] image];
    [cameraGrabberImage saveToCTAWithName:@"CameraGrabber"];
    [[self cameraGrabber] setImage:[cameraGrabberImage imageByApplyingAlpha:CameraGrabber]];
	%orig;
}

%end


%hook UIStatusBarBackgroundView

-(id)initWithFrame:(CGRect)arg1 style:(int)arg2
{
    self = %orig(arg1,arg2);
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(iOSVersion < 6.0){
        [instances addObject:self];
    }
	return self;
}

- (id)initWithFrame:(CGRect)arg1 style:(int)arg2 tintColor:(id)arg3
{
    self = %orig(arg1,arg2,arg3);
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(iOSVersion >= 6.0){
        [instances addObject:self];
    }
	return self;
}

- (void)dealloc
{
    [instances removeObject:self];
    %orig;
}

//------- Statusbar -------//
- (void)setAlpha:(float)alpha
{    
    BOOL enabledAndHomeScreenAlso = (Enabled && HomeScreenAlso);
    if((Enabled && Locked) || enabledAndHomeScreenAlso){
        UIScrollView *aScrollView = [[%c(SBIconController) sharedInstance] scrollView];
        CGPoint kOffset = [aScrollView contentOffset];
        CGRect kRect = [[UIScreen mainScreen] bounds];
        if (kOffset.x < kRect.size.width){
            goto spotLightStatusBar;
        }
        %orig(StatusBar);
        return;
    }
    
    spotLightStatusBar:
    if (TweakEnabled && KeepOpacity){
        %orig((enabledAndHomeScreenAlso)? StatusBar : 1.0f);
        return;
    } else if (enabledAndHomeScreenAlso){
        if (alpha < StatusBar)
            %orig(alpha);
       return;
    }
    %orig(alpha);
}
%end


@interface SBSearchView : UIView
@end

%hook SBSearchView

- (void)setShowsKeyboard:(BOOL)arg1 animated:(BOOL)arg2
{
    %orig((TweakEnabled && NotStartKeyboard? NO : arg1),arg2);
}


- (void)setShowsKeyboard:(BOOL)arg1 animated:(BOOL)arg2 shouldDeferResponderStatus:(BOOL)arg3 completionBlock:(id)arg4
{
    %orig((TweakEnabled && NotStartKeyboard? NO : arg1),arg2,arg3,arg4);

}

- (void)setShowsKeyboard:(BOOL)arg1 animated:(BOOL)arg2 shouldDeferResponderStatus:(BOOL)arg3
{
    %orig((TweakEnabled && NotStartKeyboard? NO : arg1),arg2,arg2);
}


%end


%hook TPLCDView

//------- ClockBar background -------//
- (void)setImage:(UIImage *)image
{
    [image saveToCTAWithName:@"ClockBarBackground"];

    UIImage *newImage = [image imageByApplyingAlpha:ClockBarBackground];
    if (!ClockBarBackground && Enabled){
        CGRect rect = CGRectMake(0,0,image.size.width,image.size.height);
        UIGraphicsBeginImageContext(rect.size);
        [image drawAtPoint:CGPointZero];
        [[UIColor clearColor] setFill];
        UIRectFill(rect);
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    %orig(newImage);
}

%end


%hook UIView

//------- ClockBar Shadow -------//
- (void)setAlpha:(float)alpha
{
    if([self.superview isMemberOfClass:NSClassFromString(@"TPLCDView")] && self.frame.size.height == 3 && AbsolutelyClockBar && Enabled){
        %orig(0.0f);
        return;
    }    
    %orig(alpha);
}

%end



#pragma mark Passcode

%hook SBDeviceLockEntryField

//------- PasscodeField background -------//
-(id)_backgroundImage
{
    UIImage *image = (UIImage *)%orig;
    [image saveToCTAWithName:@"PasscodeField"];
    return [image imageByApplyingAlpha:PasscodeField];
}

%end


%hook SBDeviceLockKeypad

//------- Keypad -------//
- (id)_keypadImage
{
    if (!KeypadImageCache || ReloadKeypad){
        UIImage *image = (UIImage *)%orig;
        [image saveToCTAWithName:@"Keypad"];
        KeypadImageCache = [[image imageByApplyingAlpha:Keypad] retain];
        ReloadKeypad = NO;
    }
    return KeypadImageCache;
}

//-------Pressed Keypad -------//
- (id)_pressedImage
{
    if (!PressedImageCache || ReloadPressedKeypad){
        UIImage *image = (UIImage *)%orig;
        [image saveToCTAWithName:@"PressedKeypad"];
        PressedImageCache = [[image imageByApplyingAlpha:PressedKeypad] retain];
        ReloadPressedKeypad = NO;
    }
    return PressedImageCache;
}
%end


@interface TPLockTextView : UIView
@end

%hook TPLockTextView

-(void)_cacheLabel:(id)label size:(CGSize)size
{
    NSString *kLabel = (Enabled && RemoveSliderText)? @"" : label;
    %orig(kLabel,size);
}

-(id)initWithLabel:(id)label fontSize:(float)size
{
    NSString *kLabel = (Enabled && RemoveSliderText)? @"" : label;
    return %orig(kLabel,size);
}

-(id)label
{
    id obj = %orig;
    return (Enabled && RemoveSliderText)? @"" : obj;
}

%end

#pragma mark Settings

static void ReloadLockscreenSettings(void)
{
	NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.mkn0dat.cleartheairforlockscreen.plist"];
    if (settings){
        StatusBar = [[settings valueForKey:@"StatusBar"]floatValue];
        ClockBarBackground = [[settings valueForKey:@"ClockBarBackground"]floatValue];
        Slider = [[settings valueForKey:@"Slider"]floatValue];
        SliderBackground= [[settings valueForKey:@"SliderBackground"]floatValue];
        SliderDitch = [[settings valueForKey:@"SliderDitch"]floatValue];
        CameraGrabber = [[settings valueForKey:@"CameraGrabber"]floatValue];
        PasscodeField = [[settings valueForKey:@"PasscodeField"]floatValue];
        PressedKeypad = [[settings valueForKey:@"PressedKeypad"]floatValue];
        Keypad = [[settings valueForKey:@"Keypad"]floatValue];
        AbsolutelyClockBar = [[settings valueForKey:@"AbsolutelyClockBar"]boolValue];
        AbsolutelySliderBackground = [[settings valueForKey:@"AbsolutelySliderBackground"]boolValue];
        Enabled = [[settings valueForKey:@"Enabled"]boolValue];
        HomeScreenAlso = [[settings valueForKey:@"HomescreenAlso"]boolValue];
        RemoveSliderText = [[settings valueForKey:@"RemoveSliderText"]boolValue];
        ReloadPressedKeypad = YES;
        ReloadKeypad = YES;
    }
    
    for (UIStatusBarBackgroundView *object in instances){
        [object setAlpha:1.0f];
    }
    [settings release];
}


static void ReloadSpotLightSettings(void)
{
	NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.mkn0dat.cleartheair.plist"];
    TweakEnabled = ([[settings allKeys] containsObject:@"Enabled"])? [[settings objectForKey:@"Enabled"] boolValue] : YES;
    KeepOpacity = ([[settings allKeys] containsObject:@"KeepOpacity"])? [[settings objectForKey:@"KeepOpacity"] boolValue] : NO;
    Opacity = ([[settings allKeys] containsObject:@"Opacity"])? [[settings objectForKey:@"Opacity"] floatValue] : 0.0f;
    PitchDark = ([[settings allKeys] containsObject:@"PitchDark"])? [[settings objectForKey:@"PitchDark"] boolValue] : NO;
    NotStartKeyboard = ([[settings allKeys] containsObject:@"NotStartKeyboard"])? [[settings objectForKey:@"NotStartKeyboard"] boolValue] : NO;

    if([[settings allKeys] containsObject:@"Transparency"]){
        Opacity = 1 - [[settings objectForKey:@"Transparency"] floatValue];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:settings];
        [dict removeObjectForKey:@"Transparency"];
        [dict setObject:[NSNumber numberWithFloat:Opacity] forKey:@"Opacity"];
        [dict writeToFile:@"/var/mobile/Library/Preferences/com.mkn0dat.cleartheair.plist" atomically:YES];
    }
	[settings release];
}


static void SettingsChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    if (kCFCompareEqualTo == CFStringCompare(name,CFSTR("com.mkn0dat.cleartheair.settingschanged"), 0)){
        ReloadSpotLightSettings();
    } else if (kCFCompareEqualTo == CFStringCompare(name,CFSTR("com.mkn0dat.cleartheairforlockscreen.settingschanged"), 0)){
        ReloadLockscreenSettings();
    }
}

#pragma mark Initialize

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    ReloadLockscreenSettings();
    ReloadSpotLightSettings();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SettingsChangedCallback, CFSTR("com.mkn0dat.cleartheair.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SettingsChangedCallback, CFSTR("com.mkn0dat.cleartheairforlockscreen.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    instances = [[NSMutableSet alloc]init];
    %init();
	[pool drain];
}
