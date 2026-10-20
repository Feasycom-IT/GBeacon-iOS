//
//  FWMinimumRSSITableViewCell.h
//  BLEAssistant
//
//  Created by ericj on 2018/6/5.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWMinimumRSSITableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *minimumRSSILabel;
@property (weak, nonatomic) IBOutlet UISlider *minimumRSSISlider;

@end
