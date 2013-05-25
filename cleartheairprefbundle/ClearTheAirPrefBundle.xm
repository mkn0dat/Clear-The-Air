#import <Preferences/Preferences.h>
#import <notify.h>
#import "SettingsManager.h"

@interface LockscreenViewController: PSListController
@end

@implementation LockscreenViewController
- (id)specifiers
{
    SettingsManager *settingsManager = [SettingsManager sharedManager];
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Lockscreen" target:self] retain];
	}
	return _specifiers;
}
@end

%hook PSRootController

%new(v@:)
- (void)popController
{
    [self popViewControllerAnimated:YES];
}

%end

%hook PSViewController

%new(@@:{ff})
- (id)initForContentSize:(CGSize)size
{
    return [self init];
}

%new(v@:)
- (void)hideNavigationBarButtons
{}
%end


@interface ClearTheAirPrefBundleListController: PSListController {
}
@end

@implementation ClearTheAirPrefBundleListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ClearTheAirPrefBundle" target:self] retain];
	}
	return _specifiers;
}

- (void)openTwitter
{
    NSString *location = @"//user?screen_name=mkn0dat";
    NSString *url = [NSString stringWithFormat:@"twitter:%@",location];
    NSURL* twitterUrl = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:twitterUrl]) {
        [[UIApplication sharedApplication] openURL:twitterUrl];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/intent/follow?screen_name=mkn0dat"]];
    }
}

@end


@interface SpotLightViewController: PSListController {
}
@end

@implementation SpotLightViewController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"SpotLight" target:self] retain];
	}
	return _specifiers;
}

@end

// vim:ft=objc
