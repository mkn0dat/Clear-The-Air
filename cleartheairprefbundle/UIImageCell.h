#import <UIKit/UIKit.h>

@interface UIImageCell : UITableViewCell

@property (nonatomic,retain) UIImageView *partsView;
@property (nonatomic,retain) NSIndexPath *indexPath;

- (void)setCellImage:(UIImage *)image;
- (void)setCellAlpha:(float)alpha;
@end
