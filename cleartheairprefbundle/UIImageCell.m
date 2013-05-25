#import "UIImageCell.h"

@implementation UIImageCell
@synthesize partsView,indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        UIImage *image = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/ClearTheAirPrefBundle.bundle/ImageNotFound.png"];
        self.partsView = [[UIImageView alloc] initWithImage:image];
        self.partsView.backgroundColor = [UIColor clearColor];
        self.partsView.opaque = NO;
        
        float height = (image)? image.size.height : 44.0f;
        float width = (image)? image.size.width : 300.0f;
        
        self.partsView.frame = CGRectMake( 0, 0, width * 0.8, height * 0.8 );
        self.partsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.partsView];
    }
    return self;
}

- (void)setCellImage:(UIImage *)image
{
    if (image && ![image isEqual:[NSNull null]]){
        float width = 320.0f;
        float height = image.size.height;
        if (20.0f < image.size.width){
            width = image.size.width;
        }
        self.partsView.frame = CGRectMake(0, 0, width*0.8, height*0.8);
        self.partsView.image = image;
    }
}

- (void)setCellAlpha:(float)alpha
{
    self.partsView.alpha = alpha;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIImageView *kView = self.partsView;
    if (kView){
        kView.center = self.contentView.center;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
