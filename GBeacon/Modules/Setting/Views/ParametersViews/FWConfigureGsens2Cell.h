//
//  FWConfigureGsens2Cell.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/3/1.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FWConfigureGsens2Cell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *intervalTextField;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;

@end

NS_ASSUME_NONNULL_END
