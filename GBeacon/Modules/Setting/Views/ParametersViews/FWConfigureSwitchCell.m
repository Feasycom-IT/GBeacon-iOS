//
//  FWConfigureSwitchCell.m
//  FeasyBeacon
//
//  Created by ericj on 2017/9/22.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import "FWConfigureSwitchCell.h"

@interface FWConfigureSwitchCell ()


@end

@implementation FWConfigureSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)switchTransform:(id)sender {
    UIView *v = [sender superview];//获取父类view
    UITableViewCell *cell = (UITableViewCell *)[v superview];
    NSIndexPath *newIndexPath;
    if (@available(iOS 11.0, *)) {
        newIndexPath = [(UITableView *)[cell superview] indexPathForCell:cell];//获取cell对应的indexPath
    } else {
        newIndexPath = [(UITableView *)[[cell superview] superview] indexPathForCell:cell];//获取cell对应的indexPath
    }
    NSLog(@"indexPath:--------%ld--%ld",(long)newIndexPath.section,(long)newIndexPath.row);
    if (self.indexPathBlock) {
        self.indexPathBlock(newIndexPath,self.switchBtn.on);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
