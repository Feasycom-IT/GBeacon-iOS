//
//  FBGSensorViewCell.h
//  FeasyBeacon
//
//  Created by chenchanghua on 2024/4/28.
//  Copyright © 2024 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBGSensorViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *xAxisRawLabel;
@property (weak, nonatomic) IBOutlet UILabel *yAxisRawLabel;
@property (weak, nonatomic) IBOutlet UILabel *zAxisRawLabel;

@end

NS_ASSUME_NONNULL_END
