//
//  FWConfigureValueSetCell.m
//  FeasyBeacon
//
//  Created by ericj on 2017/9/22.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import "FWConfigureValueSetCell.h"

@interface FWConfigureValueSetCell ()

@end

@implementation FWConfigureValueSetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.inputTextField.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
