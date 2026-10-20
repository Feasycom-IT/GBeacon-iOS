//
//  FWConfigureGsensCell.h
//  FeasyBeacon
//
//  Created by LiDong on 2020/11/5.
//  Copyright © 2020 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FWConfigureGsensCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *intervalTextField;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;
@property (weak, nonatomic) IBOutlet UITextField *sensitiveTextField;

@end

NS_ASSUME_NONNULL_END
