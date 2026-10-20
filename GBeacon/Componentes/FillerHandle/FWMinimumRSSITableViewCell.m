//
//  FWMinimumRSSITableViewCell.m
//  BLEAssistant
//
//  Created by ericj on 2018/6/5.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "FWMinimumRSSITableViewCell.h"

@implementation FWMinimumRSSITableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _minimumRSSISlider.minimumValue = -100;
    _minimumRSSISlider.maximumValue = -30;
}

@end
