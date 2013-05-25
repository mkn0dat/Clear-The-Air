#import "PasscodeViewController.h"

@implementation PasscodeViewController

- (id)initForContentSize:(CGSize)size
{
    if ((self = [super initForContentSize:size]) != nil) {
        
        id passcodeFieldImage = [self settingImageWithName:@"PasscodeField"];
        id keypadImage = [self settingImageWithName:@"Keypad"];
        id pressedKeypadImage = [self settingImageWithName:@"PressedKeypad"];
        
        if (!passcodeFieldImage) passcodeFieldImage = [NSNull null];
        if (!keypadImage) keypadImage = [NSNull null];
        if (!pressedKeypadImage) pressedKeypadImage = [NSNull null];
         
        NSMutableDictionary *passcodeFieldDictionary = [[NSMutableDictionary alloc] init];
        [passcodeFieldDictionary setObject:@"PasscodeField" forKey:@"name"];
        [passcodeFieldDictionary setObject:passcodeFieldImage forKey:@"image"];
        [passcodeFieldDictionary setObject:[self.sharedManager.settings valueForKey:[passcodeFieldDictionary valueForKey:@"name"]] forKey:@"value"];
        [passcodeFieldDictionary setObject:@"NULL" forKey:@"thirdSwitchKey"];
        [passcodeFieldDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"thirdSwitch"];
        [self.caches addObject:passcodeFieldDictionary];

        NSMutableDictionary *keypadDictionary = [[NSMutableDictionary alloc] init];
        [keypadDictionary setObject:@"Keypad" forKey:@"name"];
        [keypadDictionary setObject:keypadImage forKey:@"image"];
        [keypadDictionary setObject:[self.sharedManager.settings valueForKey:[keypadDictionary valueForKey:@"name"]] forKey:@"value"];
        [keypadDictionary setObject:@"NULL" forKey:@"thirdSwitchKey"];
        [keypadDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"thirdSwitch"];
        [self.caches addObject:keypadDictionary];
        
        NSMutableDictionary *pressedKeypadArray = [[NSMutableDictionary alloc] init];
        [pressedKeypadArray setObject:@"PressedKeypad" forKey:@"name"];
        [pressedKeypadArray setObject:pressedKeypadImage forKey:@"image"];
        [pressedKeypadArray setObject:[self.sharedManager.settings valueForKey:[pressedKeypadArray valueForKey:@"name"]] forKey:@"value"];
        [pressedKeypadArray setObject:@"NULL" forKey:@"thirdSwitchKey"];
        [pressedKeypadArray setObject:[NSNumber numberWithBool:NO] forKey:@"thirdSwitch"];
        [self.caches addObject:pressedKeypadArray];

        self.navigationTitle = @"Passcode";
        [self.tableView reloadData];
    }
    return self;
}


- (void)slider:(UISlider *)slider valueFinishedCanged:(float)value forIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [self.caches objectAtIndex:indexPath.section];
    
    if (!value && indexPath.section > 0){
        NSString *message = [NSString stringWithFormat:@"%@ will be completely invisible.",[dict valueForKey:@"name"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CAUTION!"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    [self.sharedManager setValue:[NSNumber numberWithFloat:value] forKey:[dict valueForKey:@"name"]];
    [dict setObject:[NSNumber numberWithFloat:value] forKey:[dict valueForKey:@"value"]];
    [self.caches replaceObjectAtIndex:indexPath.section withObject:dict];
    notify_post("com.mkn0dat.cleartheairforlockscreen.settingschanged");
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

@end