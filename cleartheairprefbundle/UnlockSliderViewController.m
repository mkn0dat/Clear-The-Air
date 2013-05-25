#import "UnlockSliderViewController.h"


@implementation UnlockSliderViewController

- (id)initForContentSize:(CGSize)size
{
    if ((self = [super initForContentSize:size]) != nil) {

        id SliderImage = [self settingImageWithName:@"Slider"];
        id SliderBackgroundImage = [self settingImageWithName:@"SliderBackground"];
        id SliderDitchImage = [self settingImageWithName:@"SliderDitch"];
        id CameraGrabberImage = [self settingImageWithName:@"CameraGrabber"];
        
        if (!SliderImage) SliderImage = [NSNull null];
        if (!SliderBackgroundImage) SliderBackgroundImage = [NSNull null];
        if (!SliderDitchImage) SliderDitchImage = [NSNull null];
        if (!CameraGrabberImage) CameraGrabberImage = [NSNull null];

        NSMutableDictionary *sliderDictionary = [[NSMutableDictionary alloc] init];
        [sliderDictionary setObject:@"Slider" forKey:@"name"];
        [sliderDictionary setObject:SliderImage forKey:@"image"];
        [sliderDictionary setObject:[self.sharedManager.settings valueForKey:[sliderDictionary valueForKey:@"name"]] forKey:@"value"];
        [sliderDictionary setObject:@"NULL" forKey:@"thirdSwitchKey"];
        [sliderDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"thirdSwitch"];
        [self.caches addObject:sliderDictionary];

        NSMutableDictionary *sliderDitchDictionary = [[NSMutableDictionary alloc] init];
        [sliderDitchDictionary setObject:@"SliderDitch" forKey:@"name"];
        [sliderDitchDictionary setObject:SliderDitchImage forKey:@"image"];
        [sliderDitchDictionary setObject:[self.sharedManager.settings valueForKey:[sliderDitchDictionary valueForKey:@"name"]] forKey:@"value"];
        [sliderDitchDictionary setObject:@"RemoveSliderText" forKey:@"thirdSwitchKey"];        
        [sliderDitchDictionary setObject:[self.sharedManager.settings valueForKey:[sliderDitchDictionary valueForKey:@"thirdSwitchKey"]] forKey:@"thirdSwitch"];
        [self.caches addObject:sliderDitchDictionary];

        NSMutableDictionary *sliderBackgroundDictionary = [[NSMutableDictionary alloc] init];
        [sliderBackgroundDictionary setObject:@"SliderBackground" forKey:@"name"];
        [sliderBackgroundDictionary setObject:SliderBackgroundImage forKey:@"image"];
        [sliderBackgroundDictionary setObject:[self.sharedManager.settings valueForKey:[sliderBackgroundDictionary valueForKey:@"name"]] forKey:@"value"];
        [sliderBackgroundDictionary setObject:@"AbsolutelySliderBackground" forKey:@"thirdSwitchKey"];
        [sliderBackgroundDictionary setObject:[self.sharedManager.settings valueForKey:[sliderBackgroundDictionary valueForKey:@"thirdSwitchKey"]] forKey:@"thirdSwitch"];
        [self.caches addObject:sliderBackgroundDictionary];

        NSMutableDictionary *cameraGrabberDictionary = [[NSMutableDictionary alloc] init];
        [cameraGrabberDictionary setObject:@"CameraGrabber" forKey:@"name"];
        [cameraGrabberDictionary setObject:CameraGrabberImage forKey:@"image"];
        [cameraGrabberDictionary setObject:[self.sharedManager.settings valueForKey:[cameraGrabberDictionary valueForKey:@"name"]] forKey:@"value"];
        [cameraGrabberDictionary setObject:@"NULL" forKey:@"thirdSwitchKey"];
        [cameraGrabberDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"thirdSwitch"];
        [self.caches addObject:cameraGrabberDictionary];

        self.navigationTitle = @"Unlock Slider";
        [self.tableView reloadData];
	}
    return self;
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


- (id)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:aTableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 2) {
        cell.textLabel.text = (indexPath.section == 1)? @"Remove text":@"Remove shadow";
    }
    return cell;
}


- (void)slider:(UISlider *)slider valueFinishedCanged:(float)value forIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [self.caches objectAtIndex:indexPath.section];
    if (!value && (indexPath.section == 0 || indexPath.section == 3)){
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
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (section == 1){
        return 3;
    }
    
    if ((section != 2) || (iOSVersion < 6.0)){
        return 2;
    }
    return 3;
}

@end