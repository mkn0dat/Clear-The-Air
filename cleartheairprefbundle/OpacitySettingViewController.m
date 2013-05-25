#import "OpacitySettingViewController.h"

@implementation OpacitySettingViewController

@synthesize tableView,navigationTitle,caches,sharedManager;

static id sharedInstance = nil;

+ (id)sharedInstance{
    if (!sharedInstance){
        CGRect rect = [[UIScreen mainScreen]bounds];
        sharedInstance =[[self alloc] initForContentSize:rect.size];
    }
    return sharedInstance;
}


- (UIImage *)settingImageWithName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png",[documentsDirectory stringByAppendingPathComponent:@"CTA"],name]];
}


- (id)initForContentSize:(CGSize)size
{
    if ((self = [super initForContentSize:size]) != nil) {        

		self.sharedManager = [SettingsManager sharedManager];
        self.caches = [[NSMutableArray alloc] init];
        CGRect rect = [[UIScreen mainScreen]bounds];
        self.navigationTitle = @"title";
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-64) style:UITableViewStyleGrouped];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.editing = YES;
        self.tableView.allowsSelectionDuringEditing = YES;
        
        if ([self respondsToSelector:@selector(setView:)]){
            [self setView:self.tableView];
        }
	}
    return self;
}

- (int)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return self.caches.count;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = [self.caches objectAtIndex:section];
    return [dict valueForKey:@"name"];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView*)aTableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0){
        NSDictionary *dict = [self.caches objectAtIndex:indexPath.section];
        UIImage *image = [dict valueForKey:@"image"];
        if (!image || [image isEqual:[NSNull null]]) {
            return 64.0f;
        }
        return image.size.height;
    }
    return self.tableView.rowHeight;
}


- (id)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static const id identifiers[3] = { @"ImageCell",@"SliderCell",@"SwitchCell"};
    NSString* identifier = identifiers[indexPath.row];
    UITableViewCell* cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        switch (indexPath.row) {
            case 0:
                cell = [[UIImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                break;
            case 1:{
                cell = [[UISliderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                UISliderCell* cellWithSlider = (UISliderCell *)cell;
                cellWithSlider.delegate = self;
                break;
            }
            case 2:{
                cell = [[UISwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                UISwitchCell* cellWithSwitch = (UISwitchCell *)cell;
                cellWithSwitch.delegate = self;
                break;
            }
            default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dict = [self.caches objectAtIndex:indexPath.section];

    switch (indexPath.row) {
        case 0:{
            UIImageCell* cellWithImage = (UIImageCell *)cell;
            cellWithImage.indexPath = indexPath;
            [cellWithImage setCellImage:[dict valueForKey:@"image"]];
            cellWithImage.partsView.alpha = [[dict valueForKey:@"value"] floatValue];
            cell.textLabel.text = @"";
            break;
        }
        case 1:{
            UISliderCell* cellWithSlider = (UISliderCell *)cell;
            cellWithSlider.indexPath = indexPath;
            cellWithSlider.slider.value = [[dict valueForKey:@"value"] floatValue];
            cell.textLabel.text = @"";
            break;
        }
        case 2:{
            UISwitchCell* cellWithSwitch = (UISwitchCell *)cell;
            cellWithSwitch.indexPath = indexPath;
            cellWithSwitch.switchView.on = [[dict valueForKey:@"thirdSwitch"] boolValue];
            cellWithSwitch.textLabel.text = @"Remove shadow";
            break;
        }
        default:
            break;
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

- (void)slider:(UISlider *)slider valueFinishedCanged:(float)value forIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [self.caches objectAtIndex:indexPath.section];
    [self.sharedManager setValue:[NSNumber numberWithFloat:value] forKey:[dict valueForKey:@"name"]];
    [dict setObject:[NSNumber numberWithFloat:value] forKey:@"value"];
    [self.caches replaceObjectAtIndex:indexPath.section withObject:dict];

    notify_post("com.mkn0dat.cleartheairforlockscreen.settingschanged");
}


- (void)slider:(UISlider*)slider valueDidChange:(float)value forIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [self.caches objectAtIndex:indexPath.section];
    [dict setValue:[NSNumber numberWithFloat:value] forKey:@"value"];
    [self.caches replaceObjectAtIndex:indexPath.section withObject:dict];

    UISliderCell* cellWithSlider = (UISliderCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cellWithSlider.slider.value = value;

    NSUInteger index[] = {indexPath.section,0};
    NSIndexPath *imageIndexPath = [[NSIndexPath alloc] initWithIndexes:index length:2];
    UIImageCell* cellWithImage = (UIImageCell *)[self.tableView cellForRowAtIndexPath:imageIndexPath];
    cellWithImage.partsView.alpha = value;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (id) title
{
    return self.navigationTitle;
}

- (id) view
{
    return self.tableView;
}

@end