#import <UIKit/UIKit.h>

@interface SettingsManager : NSObject

@property (nonatomic,retain) NSMutableDictionary *settings;

+ (SettingsManager *)sharedManager;
- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;
@end