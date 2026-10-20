//
//  FWConfigurePhyCell.h
//  FeasyBeacon
//
//  Created by wenjie zeng on 2023/9/12.
//  Copyright © 2023 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FWConfigurePhyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *phyLabel;
@property (weak, nonatomic) IBOutlet UILabel *phyValueLabel;
@property (weak, nonatomic) IBOutlet UIButton *phyButton;

@end

NS_ASSUME_NONNULL_END
