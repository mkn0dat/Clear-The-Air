#import "UISliderCell.h"

@implementation UISliderCell

@synthesize slider,delegate,indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.slider = [[UISlider alloc] init];
        self.slider.frame = CGRectMake(0, 0, 280, 20);
        self.slider.continuous = YES;
        [self.slider addTarget:self action:@selector(sliderValueFinishedCanged:) forControlEvents:UIControlEventTouchUpInside];
        self.slider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        [self.slider addTarget:self
                        action:@selector(sliderValueDidChange:)
              forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.slider];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.slider.center = self.contentView.center;
}


- (void)sliderValueFinishedCanged:(UISlider *)sender
{
    [self.delegate slider:sender valueFinishedCanged:sender.value forIndexPath:self.indexPath];
}

- (void)sliderValueDidChange:(UISlider *)sender
{
    [self.delegate slider:sender valueDidChange:sender.value forIndexPath:self.indexPath];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
