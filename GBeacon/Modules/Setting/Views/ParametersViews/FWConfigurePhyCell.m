//
//  FWConfigurePhyCell.m
//  FeasyBeacon
//
//  Created by wenjie zeng on 2023/9/12.
//  Copyright © 2023 Feasycom. All rights reserved.
//

#import "FWConfigurePhyCell.h"

@implementation FWConfigurePhyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _phyValueLabel.textAlignment = NSTextAlignmentRight;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
