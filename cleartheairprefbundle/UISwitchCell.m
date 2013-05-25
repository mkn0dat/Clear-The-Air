#import "UISwitchCell.h"

@implementation UISwitchCell

@synthesize switchView,delegate,indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.switchView = [[UISwitch alloc] init];
        [self.switchView addTarget:self
                      action:@selector(switchValueFinishedCanged:)
            forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.switchView];
        switchView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.switchView];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGPoint newCenter = self.contentView.center;
    newCenter.x += 100;
    self.switchView.center = newCenter;
}

- (void)switchValueFinishedCanged:(UISwitch *)aSwitch
{
    [self.delegate aSwitch:aSwitch didChange:aSwitch.on forIndexPath:self.indexPath];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
