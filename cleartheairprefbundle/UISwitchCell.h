#import <UIKit/UIKit.h>

@protocol UISwitchCellDelegate <NSObject>
@required;
- (void)aSwitch:(UISwitch*)aSwitch didChange:(BOOL)on forIndexPath:(NSIndexPath *)indexPath;
@end

@interface UISwitchCell : UITableViewCell

@property (nonatomic,retain) UISwitch *switchView;
@property (nonatomic,retain) NSIndexPath *indexPath;
@property (nonatomic,assign) id <UISwitchCellDelegate> delegate;

@end
