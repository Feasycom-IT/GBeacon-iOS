//
//  FEDevelopDebugVC.m
//  BLEAssistant
//
//  Created by chenchanghua on 2023/3/28.
//  Copyright © 2023 feasycom. All rights reserved.
//

#import "FEDevelopDebugVC.h"
#import "FBUserDefaultCache.h"

@interface FEDevelopDebugVC ()

@property (nonatomic, strong) UISwitch *isUseScanLogSwitch;

@end

@implementation FEDevelopDebugVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavigationContent];
    [self setupViewContent];
}

- (void)setupNavigationContent {
    self.title = LS(@"Developer debugging");
}

- (void)setupViewContent {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // ----- 是否默认启动扫描日志
    UILabel *isUseScanLogLabel = [[UILabel alloc] init];
    isUseScanLogLabel.text = @"Log-AdvertisementData";
    [self.view addSubview:isUseScanLogLabel];
    [isUseScanLogLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(100);
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.height.mas_equalTo(40);
    }];
    
    self.isUseScanLogSwitch = [[UISwitch alloc] init];
    [self.isUseScanLogSwitch setOn:[FBUserDefaultCache getIsUseScanLog]];
    [self.isUseScanLogSwitch addTarget:self action:@selector(isUseScanLogSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.isUseScanLogSwitch];
    [self.isUseScanLogSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(isUseScanLogLabel.mas_centerY);
        make.left.mas_equalTo(isUseScanLogLabel.mas_right).offset(10);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(40);
    }];
}

- (void)isUseScanLogSwitchAction:(UISwitch *)swit {
    if (swit.isOn) {
        [FBUserDefaultCache saveIsUseScanLog:YES];
    } else {
        [FBUserDefaultCache saveIsUseScanLog:NO];
    }
}

@end
