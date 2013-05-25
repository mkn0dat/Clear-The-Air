#import "StatusBarAndClockBarViewController.h"

@implementation StatusBarAndClockBarViewController

- (id)initForContentSize:(CGSize)size
{
    if ((self = [super initForContentSize:size]) != nil) {
        id statusBarImage = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/ClearTheAirPrefBundle.bundle/StatusBar.png"];
        id clockBarBackgroundImage = [self settingImageWithName:@"ClockBarBackground"];
        if (!statusBarImage) statusBarImage = [NSNull null];
        if (!clockBarBackgroundImage) clockBarBackgroundImage = [NSNull null];
    
        NSMutableDictionary *statusbarBackgroundDictionary = [[NSMutableDictionary alloc] init];
        [statusbarBackgroundDictionary setObject:@"StatusBar" forKey:@"name"];
        [statusbarBackgroundDictionary setObject:statusBarImage forKey:@"image"];
        [statusbarBackgroundDictionary setObject:[self.sharedManager.settings valueForKey:[statusbarBackgroundDictionary valueForKey:@"name"]] forKey:@"value"];
        [statusbarBackgroundDictionary setObject:@"HomescreenAlso" forKey:@"thirdSwitchKey"];
        [statusbarBackgroundDictionary setObject:[self.sharedManager.settings valueForKey:[statusbarBackgroundDictionary valueForKey:@"thirdSwitchKey"]] forKey:@"thirdSwitch"];
        [self.caches addObject:statusbarBackgroundDictionary];

        NSMutableDictionary *clockBarBackgroundDictionary = [[NSMutableDictionary alloc] init];
        [clockBarBackgroundDictionary setObject:@"ClockBarBackground" forKey:@"name"];
        [clockBarBackgroundDictionary setObject:clockBarBackgroundImage forKey:@"image"];
        [clockBarBackgroundDictionary setObject:[self.sharedManager.settings valueForKey:[clockBarBackgroundDictionary valueForKey:@"name"]] forKey:@"value"];
        [clockBarBackgroundDictionary setObject:@"AbsolutelyClockBar" forKey:@"thirdSwitchKey"];
        [clockBarBackgroundDictionary setObject:[self.sharedManager.settings valueForKey:[clockBarBackgroundDictionary valueForKey:@"thirdSwitchKey"]] forKey:@"thirdSwitch"];
        [self.caches addObject:clockBarBackgroundDictionary];
        
        self.navigationTitle = @"StatusBar&ClockBar";
        [self.tableView reloadData];
	}
    return self;
}


- (id)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:aTableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 2) {
        cell.textLabel.text = (indexPath.section == 0)? @"Homescreen also":@"Remove shadow";
    }
    return cell;
}


- (void)aSwitch:(UISwitch *)aSwitch didChange:(BOOL)on forIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [self.caches objectAtIndex:indexPath.section];
    [self.sharedManager setValue:[NSNumber numberWithBool:on] forKey:[dict valueForKey:@"thirdSwitchKey"]];
    [dict setObject:[NSNumber numberWithBool:on] forKey:@"thirdSwitch"];
    [self.caches replaceObjectAtIndex:indexPath.section withObject:dict];
    [self.tableView reloadData];
    notify_post("com.mkn0dat.cleartheairforlockscreen.settingschanged");
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if ((section == 1) && (iOSVersion < 6.0)){
        return 2;
    }
    return 3;
}

@end