#import "SettingsManager.h"
#import <notify.h>

@implementation SettingsManager

@synthesize settings=_settings;

static SettingsManager* sharedManager = nil;
static NSString *dictPath = @"/var/mobile/Library/Preferences/com.mkn0dat.cleartheairforlockscreen.plist";

- (id)init
{
    self = [super init];
    if(self)
    {
        [self settings]; // settings initialize
    }
    return self;
}


+ (SettingsManager *)sharedManager
{
	if(!sharedManager) {
		sharedManager = [[self alloc] init];
	}
	return sharedManager;
}


- (id)valueForKey:(NSString *)key
{
    return [self.settings valueForKey:key];
}


- (void)setValue:(id)value forKey:(NSString *)key
{
    NSMutableDictionary *dict = self.settings;
    [dict setValue:value forKey:key];
    [dict writeToFile:dictPath atomically:YES];
}


- (NSMutableDictionary *)settings
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dirName = [paths objectAtIndex:0];
    NSMutableString* saveFileDirPath = [NSMutableString string];
    [saveFileDirPath appendString:dirName];
    [saveFileDirPath appendString:@"/CTA/"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isYES = YES;
    BOOL isExist = [fileManager fileExistsAtPath:saveFileDirPath isDirectory:&isYES];
    
    if(!isExist) {
        [fileManager changeCurrentDirectoryPath:dirName];
        [fileManager createDirectoryAtPath:@"CTA" withIntermediateDirectories:YES attributes:nil error:nil];
    }

    _settings = [NSMutableDictionary dictionaryWithContentsOfFile:dictPath];
    if (!_settings){
        _settings = [[NSMutableDictionary alloc]init];

        NSNumber *numberWithClean = [NSNumber numberWithFloat:0.0f];
        [_settings setObject:numberWithClean forKey:@"StatusBar"];
        [_settings setObject:numberWithClean forKey:@"ClockBarBackground"];
        [_settings setObject:[NSNumber numberWithFloat:1.0f] forKey:@"Slider"];
        [_settings setObject:numberWithClean forKey:@"SliderBackground"];
        [_settings setObject:numberWithClean forKey:@"SliderDitch"];
        [_settings setObject:[NSNumber numberWithFloat:1.0f] forKey:@"CameraGrabber"];
        [_settings setObject:numberWithClean forKey:@"PasscodeField"];
        [_settings setObject:[NSNumber numberWithFloat:0.2f] forKey:@"PressedKeypad"];
        [_settings setObject:[NSNumber numberWithFloat:0.2f] forKey:@"Keypad"];

        [_settings setObject:[NSNumber numberWithBool:YES] forKey:@"Enabled"];
        [_settings setObject:[NSNumber numberWithBool:NO] forKey:@"HomescreenAlso"];
        [_settings setObject:[NSNumber numberWithBool:NO] forKey:@"RemoveSliderText"];
        [_settings setObject:[NSNumber numberWithBool:NO] forKey:@"AbsolutelyClockBar"];
        [_settings setObject:[NSNumber numberWithBool:NO] forKey:@"AbsolutelySliderBackground"];
            
        [_settings writeToFile:dictPath atomically:YES];
        notify_post("com.mkn0dat.cleartheairforlockscreen.settingschanged");
    } else if (![[_settings allKeys] containsObject:@"RemoveSliderText"]){
        [_settings setObject:[NSNumber numberWithBool:NO] forKey:@"RemoveSliderText"];
        [_settings writeToFile:dictPath atomically:YES];
    }
    return _settings;
}

@end