//
//  FWFilterNameTableViewCell.h
//  BLEAssistant
//
//  Created by ericj on 2018/6/5.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWFilterNameTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *filterEnableSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end
