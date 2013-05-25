#import <UIKit/UIKit.h>

@protocol UISliderCellDelegate <NSObject>
@required;
- (void)slider:(UISlider *)slider valueFinishedCanged:(float)value forIndexPath:(NSIndexPath *)indexPath;
- (void)slider:(UISlider*)slider valueDidChange:(float)value forIndexPath:(NSIndexPath *)indexPath;
@end

@interface UISliderCell : UITableViewCell

@property (nonatomic,retain) UISlider *slider;
@property (nonatomic,retain) NSIndexPath *indexPath;
@property (nonatomic,assign) id <UISliderCellDelegate> delegate;

@end
