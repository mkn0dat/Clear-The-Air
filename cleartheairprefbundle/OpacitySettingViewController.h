#import <Preferences/PSViewController.h>
#import <Preferences/PSListController.h>
#import <notify.h>
#import "UISwitchCell.h"
#import "UIImageCell.h"
#import "UISliderCell.h"
#import "SettingsManager.h"

@interface OpacitySettingViewController : PSViewController <UITableViewDelegate, UITableViewDataSource,UISliderCellDelegate,UISwitchCellDelegate>

@property (nonatomic,retain) NSMutableArray *caches;
@property (nonatomic,retain) SettingsManager *sharedManager;

@property (nonatomic, copy) NSString *navigationTitle;
@property (nonatomic, retain) UITableView *tableView;

- (id) initForContentSize:(CGSize)size ;
- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section;
- (id)navigationTitle;
- (id)view;
- (int)numberOfSectionsInTableView:(UITableView *)tableView;
- (UIImage *)settingImageWithName:(NSString *)name;
@end
