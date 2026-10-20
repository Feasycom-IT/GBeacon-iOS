//
//  FWConfigureStateCell.h
//  FeasyBeacon
//
//  Created by ericj on 2019/2/16.
//  Copyright © 2019年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWConfigureStateCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *intervalTextField;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;

@end
