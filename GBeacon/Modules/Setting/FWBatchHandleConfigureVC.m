//
//  FWBatchHandleConfigureVC.m
//  FeasyBeacon
//
//  Created by chenchanghua on 2022/3/23.
//  Copyright © 2022 LIDONG. All rights reserved.
//

#import "FWBatchHandleConfigureVC.h"
#import "FWPopoverViewController.h"
#import "FWBatchSelectDeviceVC.h"
#import "FBTextFiled.h"
#import "FBSDKPublicHeader.h"

@interface FWBatchHandleConfigureVC ()

#pragma mark - UI元素
// 版本
@property (nonatomic, strong) FBTextFiled *lowVersionTF;
@property (nonatomic, strong) FBTextFiled *hightVersionTF;

// 名称
@property (nonatomic, strong) UIButton *nameInfo_selectBtn;
@property (nonatomic, strong) FBTextFiled *nameInfoTF;

// 间隔
@property (nonatomic, strong) UIButton *IntervalInfo_selectBtn;
@property (nonatomic, strong) FBTextFiled *IntervalInfoTF;

// Pin
@property (nonatomic, strong) UIButton *pinInfo_selectBtn;
@property (nonatomic, strong) FBTextFiled *pinInfoTF;

// TxPower
@property (nonatomic, strong) UIButton *txPowerInfo_selectBtn;
@property (nonatomic, strong) UILabel *txPowerInfo_value;

// GSensor3
@property (nonatomic, strong) UIButton *gSensor3Info_selectBtn;
@property (nonatomic, strong) FBTextFiled *gSensor3Info_intervalTF;
@property (nonatomic, strong) FBTextFiled *gSensor3Info_durationTF;
@property (nonatomic, strong) FBTextFiled *gSensor3Info_sensitivityTF;

// GSensor2
@property (nonatomic, strong) UIButton *gSensor2Info_selectBtn;
@property (nonatomic, strong) FBTextFiled *gSensor2Info_intervalTF;
@property (nonatomic, strong) FBTextFiled *gSensor2Info_durationTF;

// Key
@property (nonatomic, strong) UIButton *keyInfo_selectBtn;
@property (nonatomic, strong) FBTextFiled *keyInfo_intervalTF;
@property (nonatomic, strong) FBTextFiled *keyInfo_durationTF;

// TLM
@property (nonatomic, strong) UIButton *tLMInfo_selectBtn;
@property (nonatomic, strong) UISwitch *tLMInfo_switch;

// LongRange
@property (nonatomic, strong) UIButton *longRangeInfo_selectBtn;
@property (nonatomic, strong) UISwitch *longRangeInfo_switch;

#pragma mark - 数据来源
@property (nonatomic, strong) FBPeripheralManager *peripheralManager;
@property (nonatomic, strong) FBConfiguration *configuration;

#pragma mark - 传递数据
@property (nonatomic, strong) NSMutableDictionary *beaconConfiguratedDic;

@end

@implementation FWBatchHandleConfigureVC

- (instancetype)initWithBeaconManager:(FBPeripheralManager *)beaconManager configurationRange:(FBConfiguration *)configuration {
    if (self = [super init]) {
        self.peripheralManager = beaconManager;
        self.configuration = configuration;
        self.beaconConfiguratedDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNavigationView];
    [self setupViewContent];
}

- (void)setupNavigationView {
    // 标题
    self.title = LS(@"BatchConfigInfomation");
    
    // right按钮
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 50, 44);
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightBtn setTitle:LS(@"START") forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];

    UIView *rightBtnView = [[UIView alloc]initWithFrame:rightBtn.frame];
    [rightBtnView addSubview:rightBtn];
    UIBarButtonItem * rightBarbutton = [[UIBarButtonItem alloc]initWithCustomView:rightBtnView];

    UIBarButtonItem *rightSpaceBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSpaceBarButton.width = -10;

    self.navigationItem.rightBarButtonItems = @[rightSpaceBarButton, rightBarbutton];
    
}

// 开始Action
- (void)clickRightButton:(UIButton *)sneder {
    [self generateConfigutedBeaconManager];
    [self.view endEditing:YES];
}

- (void)setupViewContent {
    
    // 型号 modelTypeInfo
    UIView *modelTypeInfoView = [[UIView alloc] init];
    modelTypeInfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:modelTypeInfoView];
    [modelTypeInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(kNavBar_Height);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    UILabel *modelTypeInfo_title = [[UILabel alloc] init];
    modelTypeInfo_title.text = LS(@"Model");
    modelTypeInfo_title.font = [UIFont systemFontOfSize:16];
    modelTypeInfo_title.textColor = [UIColor blackColor];
    [modelTypeInfoView addSubview:modelTypeInfo_title];
    [modelTypeInfo_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(modelTypeInfoView.mas_left).offset(30);
        make.centerY.mas_equalTo(modelTypeInfoView.mas_centerY);
    }];
    UILabel *modelTypeInfo_value = [[UILabel alloc] init];
    modelTypeInfo_value.text = [self.peripheralManager valueForName:kModel];
    modelTypeInfo_value.font = [UIFont systemFontOfSize:16];
    modelTypeInfo_value.textColor = [UIColor blackColor];
    [modelTypeInfoView addSubview:modelTypeInfo_value];
    [modelTypeInfo_value mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(modelTypeInfoView.mas_right).offset(-10);
        make.centerY.mas_equalTo(modelTypeInfoView.mas_centerY);
    }];
    
    // 版本 versionInfo
    UIView *versionInfoView = [[UIView alloc] init];
    versionInfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:versionInfoView];
    [versionInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(modelTypeInfoView.mas_bottom).offset(1);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    UILabel *versionInfo_title = [[UILabel alloc] init];
    versionInfo_title.text = LS(@"Version:");
    versionInfo_title.font = [UIFont systemFontOfSize:16];
    versionInfo_title.textColor = [UIColor blackColor];
    [versionInfoView addSubview:versionInfo_title];
    [versionInfo_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(versionInfoView.mas_left).offset(30);
        make.centerY.mas_equalTo(versionInfoView.mas_centerY);
    }];
    self.hightVersionTF = [[FBTextFiled alloc] init];
    self.hightVersionTF.borderStyle = UITextBorderStyleLine;
    self.hightVersionTF.textAlignment = NSTextAlignmentCenter;
    self.hightVersionTF.text = [self.peripheralManager valueForName:kVersion];
    self.hightVersionTF.keyboardType = UIKeyboardTypeDecimalPad;
    
    NSMutableAttributedString *hightVersionTF_placeholder = [[NSMutableAttributedString alloc] initWithString:@"x.x.x格式"];
    [hightVersionTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, hightVersionTF_placeholder.length)];
    self.hightVersionTF.attributedPlaceholder = hightVersionTF_placeholder;
    [versionInfoView addSubview:self.hightVersionTF];
    [self.hightVersionTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(versionInfoView.mas_right).mas_equalTo(-10);
        make.centerY.mas_equalTo(versionInfoView.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    self.lowVersionTF = [[FBTextFiled alloc] init];
    self.lowVersionTF.borderStyle = UITextBorderStyleLine;
    self.lowVersionTF.textAlignment = NSTextAlignmentCenter;
    self.lowVersionTF.text = [self.peripheralManager valueForName:kVersion];
    self.lowVersionTF.keyboardType = UIKeyboardTypeDecimalPad;
    
    NSMutableAttributedString *lowVersionTF_placeholder = [[NSMutableAttributedString alloc] initWithString:@"x.x.x格式"];
    [lowVersionTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, lowVersionTF_placeholder.length)];
    self.lowVersionTF.attributedPlaceholder = lowVersionTF_placeholder;
    [versionInfoView addSubview:self.lowVersionTF];
    [self.lowVersionTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.hightVersionTF.mas_left).mas_equalTo(-10);
        make.centerY.mas_equalTo(versionInfoView.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
    // 名称 nameInfo
    UIView *nameInfoView = [[UIView alloc] init];
    nameInfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:nameInfoView];
    [nameInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(versionInfoView.mas_bottom).offset(1);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    self.nameInfo_selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nameInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_no"] forState:UIControlStateNormal];
    [self.nameInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_yes"] forState:UIControlStateSelected];
    [self.nameInfo_selectBtn addTarget:self action:@selector(nameInfo_selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [nameInfoView addSubview:self.nameInfo_selectBtn];
    [self.nameInfo_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameInfoView.mas_left).offset(5);
        make.centerY.mas_equalTo(nameInfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    UILabel *nameInfo_title = [[UILabel alloc] init];
    nameInfo_title.text = LS(@"Name:");
    nameInfo_title.font = [UIFont systemFontOfSize:16];
    nameInfo_title.textColor = [UIColor blackColor];
    [nameInfoView addSubview:nameInfo_title];
    [nameInfo_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameInfoView.mas_left).offset(30);
        make.centerY.mas_equalTo(nameInfoView.mas_centerY);
    }];
    self.nameInfoTF = [[FBTextFiled alloc] init];
    self.nameInfoTF.borderStyle = UITextBorderStyleLine;
    self.nameInfoTF.textAlignment = NSTextAlignmentCenter;
    self.nameInfoTF.text = [self.peripheralManager valueForName:kName];
    
    NSMutableAttributedString *nameInfoTF_placeholder = [[NSMutableAttributedString alloc] initWithString:LS(@"Please enter a name within 25 characters")];
    [nameInfoTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, nameInfoTF_placeholder.length)];
    self.nameInfoTF.attributedPlaceholder = nameInfoTF_placeholder;
    [nameInfoView addSubview:self.nameInfoTF];
    [self.nameInfoTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(nameInfoView.mas_right).mas_equalTo(-10);
        make.centerY.mas_equalTo(nameInfoView.mas_centerY);
        make.width.mas_equalTo(270);
        make.height.mas_equalTo(30);
    }];
    
    // 间隔 IntervalInfo
    UIView *IntervalInfoView = [[UIView alloc] init];
    IntervalInfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:IntervalInfoView];
    [IntervalInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nameInfoView.mas_bottom).offset(1);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    self.IntervalInfo_selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.IntervalInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_no"] forState:UIControlStateNormal];
    [self.IntervalInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_yes"] forState:UIControlStateSelected];
    [self.IntervalInfo_selectBtn addTarget:self action:@selector(IntervalInfo_selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [IntervalInfoView addSubview:self.IntervalInfo_selectBtn];
    [self.IntervalInfo_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(IntervalInfoView.mas_left).offset(5);
        make.centerY.mas_equalTo(IntervalInfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    UILabel *IntervalInfo_title = [[UILabel alloc] init];
    IntervalInfo_title.text = LS(@"Interval");
    IntervalInfo_title.font = [UIFont systemFontOfSize:16];
    IntervalInfo_title.textColor = [UIColor blackColor];
    [IntervalInfoView addSubview:IntervalInfo_title];
    [IntervalInfo_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(IntervalInfoView.mas_left).offset(30);
        make.centerY.mas_equalTo(IntervalInfoView.mas_centerY);
    }];
    self.IntervalInfoTF = [[FBTextFiled alloc] init];
    self.IntervalInfoTF.borderStyle = UITextBorderStyleLine;
    self.IntervalInfoTF.textAlignment = NSTextAlignmentCenter;
    self.IntervalInfoTF.keyboardType = UIKeyboardTypeNumberPad;
    self.IntervalInfoTF.text = [self.peripheralManager valueForName:kInterval];
    self.IntervalInfoTF.keyboardType = UIKeyboardTypeNumberPad;
    
    NSMutableAttributedString *IntervalInfoTF_placeholder = [[NSMutableAttributedString alloc] initWithString:@"100ms～2000ms"];
    [IntervalInfoTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, IntervalInfoTF_placeholder.length)];
    self.IntervalInfoTF.attributedPlaceholder = IntervalInfoTF_placeholder;
    [IntervalInfoView addSubview:self.IntervalInfoTF];
    [self.IntervalInfoTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(IntervalInfoView.mas_right).mas_equalTo(-10);
        make.centerY.mas_equalTo(IntervalInfoView.mas_centerY);
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(30);
    }];
    
    // Pin
    UIView *pinInfoView = [[UIView alloc] init];
    pinInfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pinInfoView];
    [pinInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(IntervalInfoView.mas_bottom).offset(1);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    self.pinInfo_selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pinInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_no"] forState:UIControlStateNormal];
    [self.pinInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_yes"] forState:UIControlStateSelected];
    [self.pinInfo_selectBtn addTarget:self action:@selector(pinInfo_selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [pinInfoView addSubview:self.pinInfo_selectBtn];
    [self.pinInfo_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pinInfoView.mas_left).offset(5);
        make.centerY.mas_equalTo(pinInfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    UILabel *pinInfo_title = [[UILabel alloc] init];
    pinInfo_title.text = @"Pin：";
    pinInfo_title.font = [UIFont systemFontOfSize:16];
    pinInfo_title.textColor = [UIColor blackColor];
    [pinInfoView addSubview:pinInfo_title];
    [pinInfo_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pinInfoView.mas_left).offset(30);
        make.centerY.mas_equalTo(pinInfoView.mas_centerY);
    }];
    self.pinInfoTF = [[FBTextFiled alloc] init];
    self.pinInfoTF.borderStyle = UITextBorderStyleLine;
    self.pinInfoTF.textAlignment = NSTextAlignmentCenter;
    self.pinInfoTF.keyboardType = UIKeyboardTypeNumberPad;
    self.pinInfoTF.text = [self.peripheralManager valueForName:kPin];
    self.pinInfoTF.keyboardType = UIKeyboardTypeNumberPad;
    
    NSMutableAttributedString *pinInfoTF_placeholder = [[NSMutableAttributedString alloc] initWithString:LS(@"Please enter 6 digits")];
    [pinInfoTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, pinInfoTF_placeholder.length)];
    self.pinInfoTF.attributedPlaceholder = pinInfoTF_placeholder;
    [pinInfoView addSubview:self.pinInfoTF];
    [self.pinInfoTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(pinInfoView.mas_right).mas_equalTo(-10);
        make.centerY.mas_equalTo(pinInfoView.mas_centerY);
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(30);
    }];
    
    // Txpower
    UIView *txPowerInfoView = [[UIView alloc] init];
    txPowerInfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:txPowerInfoView];
    [txPowerInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(pinInfoView.mas_bottom).offset(1);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    self.txPowerInfo_selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.txPowerInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_no"] forState:UIControlStateNormal];
    [self.txPowerInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_yes"] forState:UIControlStateSelected];
    [self.txPowerInfo_selectBtn addTarget:self action:@selector(txPowerInfo_selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [txPowerInfoView addSubview:self.txPowerInfo_selectBtn];
    [self.txPowerInfo_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(txPowerInfoView.mas_left).offset(5);
        make.centerY.mas_equalTo(txPowerInfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    UILabel *txPowerInfo_title = [[UILabel alloc] init];
    txPowerInfo_title.text = @"TxPower(db):";
    txPowerInfo_title.font = [UIFont systemFontOfSize:16];
    txPowerInfo_title.textColor = [UIColor blackColor];
    [txPowerInfoView addSubview:txPowerInfo_title];
    [txPowerInfo_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(txPowerInfoView.mas_left).offset(30);
        make.centerY.mas_equalTo(txPowerInfoView.mas_centerY);
    }];
    UIButton *txPowerInfo_checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [txPowerInfo_checkBtn setImage:[UIImage imageNamed:@"bottom-1"] forState:UIControlStateNormal];
    [txPowerInfo_checkBtn addTarget:self action:@selector(txPowerInfo_checkBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [txPowerInfoView addSubview:txPowerInfo_checkBtn];
    [txPowerInfo_checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(txPowerInfoView.mas_right).offset(-10);
        make.centerY.mas_equalTo(txPowerInfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    self.txPowerInfo_value = [[UILabel alloc] init];
    self.txPowerInfo_value.text = [self.peripheralManager valueForName:kTxPower];
    self.txPowerInfo_value.font = [UIFont systemFontOfSize:16];
    self.txPowerInfo_value.textColor = [UIColor blackColor];
    [txPowerInfoView addSubview:self.txPowerInfo_value];
    [self.txPowerInfo_value mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(txPowerInfo_checkBtn.mas_left).offset(-2);
        make.centerY.mas_equalTo(txPowerInfoView.mas_centerY);
    }];
    
    // GSensor-3
    UIView *gSensor3InfoView = [[UIView alloc] init];
    gSensor3InfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:gSensor3InfoView];
    [gSensor3InfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(txPowerInfoView.mas_bottom).offset(1);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    self.gSensor3Info_selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.gSensor3Info_selectBtn setImage:[UIImage imageNamed:@"selecte_no"] forState:UIControlStateNormal];
    [self.gSensor3Info_selectBtn setImage:[UIImage imageNamed:@"selecte_yes"] forState:UIControlStateSelected];
    [self.gSensor3Info_selectBtn addTarget:self action:@selector(gSensor3Info_selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [gSensor3InfoView addSubview:self.gSensor3Info_selectBtn];
    [self.gSensor3Info_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(gSensor3InfoView.mas_left).offset(5);
        make.centerY.mas_equalTo(gSensor3InfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    UILabel *gSensor3Info_title = [[UILabel alloc] init];
    gSensor3Info_title.text = @"Gsensor(ms):";
    gSensor3Info_title.font = [UIFont systemFontOfSize:16];
    gSensor3Info_title.textColor = [UIColor blackColor];
    [gSensor3InfoView addSubview:gSensor3Info_title];
    [gSensor3Info_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(gSensor3InfoView.mas_left).offset(30);
        make.centerY.mas_equalTo(gSensor3InfoView.mas_centerY);
    }];
    self.gSensor3Info_sensitivityTF = [[FBTextFiled alloc] init];
    self.gSensor3Info_sensitivityTF.borderStyle = UITextBorderStyleLine;
    self.gSensor3Info_sensitivityTF.textAlignment = NSTextAlignmentCenter;
    self.gSensor3Info_sensitivityTF.keyboardType = UIKeyboardTypeNumberPad;
    self.gSensor3Info_sensitivityTF.keyboardType = UIKeyboardTypeNumberPad;
    
    NSMutableAttributedString *gSensor3Info_sensitivityTF_placeholder = [[NSMutableAttributedString alloc] initWithString:LS(@"sensitivity")];
    [gSensor3Info_sensitivityTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, gSensor3Info_sensitivityTF_placeholder.length)];
    self.gSensor3Info_sensitivityTF.attributedPlaceholder = gSensor3Info_sensitivityTF_placeholder;
    [gSensor3InfoView addSubview:self.gSensor3Info_sensitivityTF];
    [self.gSensor3Info_sensitivityTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(gSensor3InfoView.mas_right).mas_equalTo(-10);
        make.centerY.mas_equalTo(gSensor3InfoView.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    self.gSensor3Info_durationTF = [[FBTextFiled alloc] init];
    self.gSensor3Info_durationTF.borderStyle = UITextBorderStyleLine;
    self.gSensor3Info_durationTF.textAlignment = NSTextAlignmentCenter;
    self.gSensor3Info_durationTF.keyboardType = UIKeyboardTypeNumberPad;
    self.gSensor3Info_durationTF.keyboardType = UIKeyboardTypeNumberPad;
    
    NSMutableAttributedString *gSensor3Info_durationTF_placeholder = [[NSMutableAttributedString alloc] initWithString:LS(@"duration")];
    [gSensor3Info_durationTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, gSensor3Info_durationTF_placeholder.length)];
    self.gSensor3Info_durationTF.attributedPlaceholder = gSensor3Info_durationTF_placeholder;
    [gSensor3InfoView addSubview:self.gSensor3Info_durationTF];
    [self.gSensor3Info_durationTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.gSensor3Info_sensitivityTF.mas_left).mas_equalTo(-10);
        make.centerY.mas_equalTo(gSensor3InfoView.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    self.gSensor3Info_intervalTF = [[FBTextFiled alloc] init];
    self.gSensor3Info_intervalTF.borderStyle = UITextBorderStyleLine;
    self.gSensor3Info_intervalTF.textAlignment = NSTextAlignmentCenter;
    self.gSensor3Info_intervalTF.keyboardType = UIKeyboardTypeNumberPad;
    self.gSensor3Info_intervalTF.keyboardType = UIKeyboardTypeNumberPad;
    
    NSMutableAttributedString *gSensor3Info_intervalTF_placeholder = [[NSMutableAttributedString alloc] initWithString:LS(@"Broadcast Interval")];
    [gSensor3Info_intervalTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, gSensor3Info_intervalTF_placeholder.length)];
    self.gSensor3Info_intervalTF.attributedPlaceholder = gSensor3Info_intervalTF_placeholder;
    [gSensor3InfoView addSubview:self.gSensor3Info_intervalTF];
    [self.gSensor3Info_intervalTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.gSensor3Info_durationTF.mas_left).mas_equalTo(-10);
        make.centerY.mas_equalTo(gSensor3InfoView.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
    // GSensor-2
    UIView *gSensor2InfoView = [[UIView alloc] init];
    gSensor2InfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:gSensor2InfoView];
    [gSensor2InfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(gSensor3InfoView.mas_bottom).offset(1);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    self.gSensor2Info_selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.gSensor2Info_selectBtn setImage:[UIImage imageNamed:@"selecte_no"] forState:UIControlStateNormal];
    [self.gSensor2Info_selectBtn setImage:[UIImage imageNamed:@"selecte_yes"] forState:UIControlStateSelected];
    [self.gSensor2Info_selectBtn addTarget:self action:@selector(gSensor2Info_selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [gSensor2InfoView addSubview:self.gSensor2Info_selectBtn];
    [self.gSensor2Info_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(gSensor2InfoView.mas_left).offset(5);
        make.centerY.mas_equalTo(gSensor2InfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    UILabel *gSensor2Info_title = [[UILabel alloc] init];
    gSensor2Info_title.text = @"Gsensor(ms):";
    gSensor2Info_title.font = [UIFont systemFontOfSize:16];
    gSensor2Info_title.textColor = [UIColor blackColor];
    [gSensor2InfoView addSubview:gSensor2Info_title];
    [gSensor2Info_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(gSensor2InfoView.mas_left).offset(30);
        make.centerY.mas_equalTo(gSensor2InfoView.mas_centerY);
    }];
    self.gSensor2Info_durationTF = [[FBTextFiled alloc] init];
    self.gSensor2Info_durationTF.borderStyle = UITextBorderStyleLine;
    self.gSensor2Info_durationTF.textAlignment = NSTextAlignmentCenter;
    self.gSensor2Info_durationTF.keyboardType = UIKeyboardTypeNumberPad;
    self.gSensor2Info_durationTF.keyboardType = UIKeyboardTypeNumberPad;
    
    NSMutableAttributedString *gSensor2Info_durationTF_placeholder = [[NSMutableAttributedString alloc] initWithString:LS(@"duration")];
    [gSensor2Info_durationTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, gSensor2Info_durationTF_placeholder.length)];
    self.gSensor2Info_durationTF.attributedPlaceholder = gSensor2Info_durationTF_placeholder;
    [gSensor2InfoView addSubview:self.gSensor2Info_durationTF];
    [self.gSensor2Info_durationTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(gSensor2InfoView.mas_right).mas_equalTo(-10);
        make.centerY.mas_equalTo(gSensor2InfoView.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    self.gSensor2Info_intervalTF = [[FBTextFiled alloc] init];
    self.gSensor2Info_intervalTF.borderStyle = UITextBorderStyleLine;
    self.gSensor2Info_intervalTF.textAlignment = NSTextAlignmentCenter;
    self.gSensor2Info_intervalTF.keyboardType = UIKeyboardTypeNumberPad;
    self.gSensor2Info_intervalTF.keyboardType = UIKeyboardTypeNumberPad;
    
    NSMutableAttributedString *gSensor2Info_intervalTF_placeholder = [[NSMutableAttributedString alloc] initWithString:LS(@"Broadcast Interval")];
    [gSensor2Info_intervalTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, gSensor2Info_intervalTF_placeholder.length)];
    self.gSensor2Info_intervalTF.attributedPlaceholder = gSensor2Info_intervalTF_placeholder;
    [gSensor2InfoView addSubview:self.gSensor2Info_intervalTF];
    [self.gSensor2Info_intervalTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.gSensor2Info_durationTF.mas_left).mas_equalTo(-10);
        make.centerY.mas_equalTo(gSensor2InfoView.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
    // Key
    UIView *keyInfoView = [[UIView alloc] init];
    keyInfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:keyInfoView];
    [keyInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(gSensor2InfoView.mas_bottom).offset(1);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    self.keyInfo_selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.keyInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_no"] forState:UIControlStateNormal];
    [self.keyInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_yes"] forState:UIControlStateSelected];
    [self.keyInfo_selectBtn addTarget:self action:@selector(keyInfo_selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [keyInfoView addSubview:self.keyInfo_selectBtn];
    [self.keyInfo_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(keyInfoView.mas_left).offset(5);
        make.centerY.mas_equalTo(keyInfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    UILabel *keyInfo_title = [[UILabel alloc] init];
    keyInfo_title.text = @"Key(ms):";
    keyInfo_title.font = [UIFont systemFontOfSize:16];
    keyInfo_title.textColor = [UIColor blackColor];
    [keyInfoView addSubview:keyInfo_title];
    [keyInfo_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(keyInfoView.mas_left).offset(30);
        make.centerY.mas_equalTo(keyInfoView.mas_centerY);
    }];
    self.keyInfo_durationTF = [[FBTextFiled alloc] init];
    self.keyInfo_durationTF.borderStyle = UITextBorderStyleLine;
    self.keyInfo_durationTF.textAlignment = NSTextAlignmentCenter;
    self.keyInfo_durationTF.keyboardType = UIKeyboardTypeNumberPad;
    self.keyInfo_durationTF.text = [self.peripheralManager valueForName:kKey][1];
    self.keyInfo_durationTF.keyboardType = UIKeyboardTypeNumberPad;
    
    NSMutableAttributedString *keyInfo_durationTF_placeholder = [[NSMutableAttributedString alloc] initWithString:LS(@"duration")];
    [keyInfo_durationTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, keyInfo_durationTF_placeholder.length)];
    self.keyInfo_durationTF.attributedPlaceholder = keyInfo_durationTF_placeholder;
    [keyInfoView addSubview:self.keyInfo_durationTF];
    [self.keyInfo_durationTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(keyInfoView.mas_right).mas_equalTo(-10);
        make.centerY.mas_equalTo(keyInfoView.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    self.keyInfo_intervalTF = [[FBTextFiled alloc] init];
    self.keyInfo_intervalTF.borderStyle = UITextBorderStyleLine;
    self.keyInfo_intervalTF.textAlignment = NSTextAlignmentCenter;
    self.keyInfo_intervalTF.keyboardType = UIKeyboardTypeNumberPad;
    self.keyInfo_intervalTF.text = [self.peripheralManager valueForName:kKey][0];
    self.keyInfo_intervalTF.keyboardType = UIKeyboardTypeNumberPad;
    
    NSMutableAttributedString *keyInfo_intervalTF_placeholder = [[NSMutableAttributedString alloc] initWithString:LS(@"Broadcast Interval")];
    [keyInfo_intervalTF_placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, keyInfo_intervalTF_placeholder.length)];
    self.keyInfo_intervalTF.attributedPlaceholder = keyInfo_intervalTF_placeholder;
    [keyInfoView addSubview:self.keyInfo_intervalTF];
    [self.keyInfo_intervalTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.keyInfo_durationTF.mas_left).mas_equalTo(-10);
        make.centerY.mas_equalTo(keyInfoView.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
    // TLM
    UIView *tLMInfoView = [[UIView alloc] init];
    tLMInfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tLMInfoView];
    [tLMInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(keyInfoView.mas_bottom).offset(1);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    self.tLMInfo_selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.tLMInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_no"] forState:UIControlStateNormal];
    [self.tLMInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_yes"] forState:UIControlStateSelected];
    [self.tLMInfo_selectBtn addTarget:self action:@selector(tLMInfo_selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [tLMInfoView addSubview:self.tLMInfo_selectBtn];
    [self.tLMInfo_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tLMInfoView.mas_left).offset(5);
        make.centerY.mas_equalTo(tLMInfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    UILabel *tLMInfo_title = [[UILabel alloc] init];
    tLMInfo_title.text = @"TLM:";
    tLMInfo_title.font = [UIFont systemFontOfSize:16];
    tLMInfo_title.textColor = [UIColor blackColor];
    [tLMInfoView addSubview:tLMInfo_title];
    [tLMInfo_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tLMInfoView.mas_left).offset(30);
        make.centerY.mas_equalTo(tLMInfoView.mas_centerY);
    }];
    self.tLMInfo_switch = [[UISwitch alloc] init];
    NSString *tLM_value = [self.peripheralManager valueForName:kTLM];
    [self.tLMInfo_switch setOn:tLM_value.integerValue];
    [tLMInfoView addSubview:self.tLMInfo_switch];
    [self.tLMInfo_switch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(tLMInfoView.mas_right).offset(-10);
        make.centerY.mas_equalTo(tLMInfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    // LongRange
    UIView *longRangeInfoView = [[UIView alloc] init];
    longRangeInfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:longRangeInfoView];
    [longRangeInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLMInfoView.mas_bottom).offset(1);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    self.longRangeInfo_selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.longRangeInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_no"] forState:UIControlStateNormal];
    [self.longRangeInfo_selectBtn setImage:[UIImage imageNamed:@"selecte_yes"] forState:UIControlStateSelected];
    [self.longRangeInfo_selectBtn addTarget:self action:@selector(longRangeInfo_selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [longRangeInfoView addSubview:self.longRangeInfo_selectBtn];
    [self.longRangeInfo_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(longRangeInfoView.mas_left).offset(5);
        make.centerY.mas_equalTo(longRangeInfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    UILabel *longRangeInfo_title = [[UILabel alloc] init];
    longRangeInfo_title.text = @"Longrange:";
    longRangeInfo_title.font = [UIFont systemFontOfSize:16];
    longRangeInfo_title.textColor = [UIColor blackColor];
    [longRangeInfoView addSubview:longRangeInfo_title];
    [longRangeInfo_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(longRangeInfoView.mas_left).offset(30);
        make.centerY.mas_equalTo(longRangeInfoView.mas_centerY);
    }];
    self.longRangeInfo_switch = [[UISwitch alloc] init];
    NSString *longrange_value = [self.peripheralManager valueForName:kLongRange];
    self.longRangeInfo_switch.on = longrange_value.integerValue;
    [longRangeInfoView addSubview:self.longRangeInfo_switch];
    [self.longRangeInfo_switch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(longRangeInfoView.mas_right).offset(-10);
        make.centerY.mas_equalTo(longRangeInfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    // 背景效果
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:bgView];
    [self.view sendSubviewToBack:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(modelTypeInfoView.mas_top);
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(longRangeInfoView.mas_bottom).offset(1);
    }];
    
    // adjustUI------------------------
    if (![self.peripheralManager.paramKeys containsObject:kName]) {
        [nameInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(versionInfoView.mas_bottom).offset(0);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
        nameInfoView.hidden = YES;
    }
    if (![self.peripheralManager.paramKeys containsObject:kInterval]) {
        [IntervalInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(nameInfoView.mas_bottom).offset(0);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
        IntervalInfoView.hidden = YES;
    }
    if (![self.peripheralManager.paramKeys containsObject:kPin]) {
        [pinInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(IntervalInfoView.mas_bottom).offset(0);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
        pinInfoView.hidden = YES;
    }
    if (![self.peripheralManager.paramKeys containsObject:kTxPower]) {
        [txPowerInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(pinInfoView.mas_bottom).offset(0);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
        txPowerInfoView.hidden = YES;
    }
    if ([self.peripheralManager.paramKeys containsObject:kGsensor]) {
        NSArray *values = [self.peripheralManager valueForName:kGsensor];
        if (values.count == 2) {
            [gSensor3InfoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(txPowerInfoView.mas_bottom).offset(0);
                make.left.right.mas_equalTo(self.view);
                make.height.mas_equalTo(0);
            }];
            gSensor3InfoView.hidden = YES;
            
            self.gSensor2Info_durationTF.text = [self.peripheralManager valueForName:kGsensor][1];
            self.gSensor2Info_intervalTF.text = [self.peripheralManager valueForName:kGsensor][0];
        }
        if (values.count == 3) {
            [gSensor2InfoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(gSensor3InfoView.mas_bottom).offset(0);
                make.left.right.mas_equalTo(self.view);
                make.height.mas_equalTo(0);
            }];
            gSensor2InfoView.hidden = YES;
            
            self.gSensor3Info_sensitivityTF.text = [self.peripheralManager valueForName:kGsensor][2];
            self.gSensor3Info_durationTF.text = [self.peripheralManager valueForName:kGsensor][1];
            self.gSensor3Info_intervalTF.text = [self.peripheralManager valueForName:kGsensor][0];
        }
    } else {
        [gSensor3InfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(txPowerInfoView.mas_bottom).offset(0);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
        gSensor3InfoView.hidden = YES;
        
        [gSensor2InfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(gSensor3InfoView.mas_bottom).offset(0);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
        gSensor2InfoView.hidden = YES;
    }
    if (![self.peripheralManager.paramKeys containsObject:kKey]) {
        [keyInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(gSensor2InfoView.mas_bottom).offset(0);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
        keyInfoView.hidden = YES;
    }
    if (![self.peripheralManager.paramKeys containsObject:kTLM]) {
        [tLMInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(keyInfoView.mas_bottom).offset(0);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
        tLMInfoView.hidden = YES;
    }
    if (![self.peripheralManager.paramKeys containsObject:kLongRange]) {
        [longRangeInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(tLMInfoView.mas_bottom).offset(0);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
        longRangeInfoView.hidden = YES;
    }
}

// 名称
- (void)nameInfo_selectBtnAction:(UIButton *)btn {
    btn.selected = !btn.isSelected;
}

// 间隔
- (void)IntervalInfo_selectBtnAction:(UIButton *)btn {
    btn.selected = !btn.isSelected;
}

// Pin
- (void)pinInfo_selectBtnAction:(UIButton *)btn {
    btn.selected = !btn.isSelected;
}

// TxPower
- (void)txPowerInfo_selectBtnAction:(UIButton *)btn {
    btn.selected = !btn.isSelected;
}

// GSensor3
- (void)gSensor3Info_selectBtnAction:(UIButton *)btn {
    btn.selected = !btn.isSelected;
}

// GSensor2
- (void)gSensor2Info_selectBtnAction:(UIButton *)btn {
    btn.selected = !btn.isSelected;
}

// Key
- (void)keyInfo_selectBtnAction:(UIButton *)btn {
    btn.selected = !btn.isSelected;
}

// TLM
- (void)tLMInfo_selectBtnAction:(UIButton *)btn {
    btn.selected = !btn.isSelected;
}

// Longrange
- (void)longRangeInfo_selectBtnAction:(UIButton *)btn {
    btn.selected = !btn.isSelected;
}

// TxPowerCheck
- (void)txPowerInfo_checkBtnAction:(UIButton *)sender {
    FWPopoverViewController * popoverViewController = [[FWPopoverViewController alloc] initWithTitles:self.configuration.txPowers sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *powerString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.txPowerInfo_value.text = powerString;
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

// 校验输入参数的有效性
- (void)verificateInputedParameterValidity {
    // 版本范围
    
    // 名称
    // 通过NSUTF8StringEncoding转码后字节长度不能大于25
    if (self.nameInfo_selectBtn.isSelected) {
        NSString *newly_name = self.nameInfoTF.text;
        const NSInteger lengthOfBytes = [newly_name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        if (lengthOfBytes > 25) {
            NSLog(@"「名称」长度不能超过25个字符");
            [self presenteErrorWithMessage:LS(@"The effective range of interval time is 100ms~2000ms")];
            return;
        }
        if (lengthOfBytes == 0) {
            NSLog(@"「名称」不能为空");
            [self presenteErrorWithMessage:LS(@"Name cannot be empty")];
            return;
        }
    }
    
    // 间隔
    if (self.IntervalInfo_selectBtn.isSelected) {
        NSInteger newly_default_interval = self.IntervalInfoTF.text.integerValue;
        if (newly_default_interval < 100 || newly_default_interval > 2000) {
            NSLog(@"「间隔时间」有效范围为100ms～2000ms");
            [self presenteErrorWithMessage:LS(@"The effective range of interval time is 100ms~2000ms")];
            return;
        }
    }
    
    // Pin
    if (self.pinInfo_selectBtn.isSelected) {
        NSString *newly_pin = self.pinInfoTF.text;
        if (newly_pin.length != 6) {
            NSLog(@"「PIN」长度只能设置为六位");
            [self presenteErrorWithMessage:LS(@"The 'PIN' length can only be set to six digits")];
            return;
        }
    }
    
    // TxPower
    if (self.txPowerInfo_selectBtn.isSelected) {
        
    }
    
    // Gsensor3
    if (self.gSensor3Info_selectBtn.isSelected) {
        NSInteger newly_g_interval = self.gSensor3Info_intervalTF.text.integerValue;
        if (newly_g_interval < 100 || newly_g_interval > 2000) {
            NSLog(@"「Gsensor的间隔时间」有效范围为100ms～2000ms");
            [self presenteErrorWithMessage:LS(@"The effective range of interval time for Gsensor is 100ms to 2000ms")];
            return;
        }
    }
    
    // Gsensor2
    if (self.gSensor2Info_selectBtn.isSelected) {
        NSInteger newly_g_interval = self.gSensor2Info_intervalTF.text.integerValue;
        if (newly_g_interval < 100 || newly_g_interval > 2000) {
            NSLog(@"「Gsensor的间隔时间」有效范围为100ms～2000ms");
            [self presenteErrorWithMessage:LS(@"The effective range of interval time for Gsensor is 100ms to 2000ms")];
            return;
        }
    }
    
    // Key
    if (self.keyInfo_selectBtn.isSelected) {
        NSInteger newly_key_interval = self.keyInfo_intervalTF.text.integerValue;
        if (newly_key_interval < 100 || newly_key_interval > 2000) {
            NSLog(@"「Key的间隔时间」有效范围为100ms～2000ms");
            [self presenteErrorWithMessage:LS(@"The effective range of interval time for Key is 100ms to 2000ms")];
            return;
        }
    }
    
    // TLM
    if (self.tLMInfo_selectBtn.isSelected) {
        
    }
    
    // Longrange
    if (self.longRangeInfo_selectBtn.isSelected) {
        
    }
}

- (void)generateConfigutedBeaconManager {
    
    [self verificateInputedParameterValidity];
    
    // 名称
    if (self.nameInfo_selectBtn.isSelected) {
        self.beaconConfiguratedDic[kName] = self.nameInfoTF.text;
    }
    
    // 广播间隔
    if (self.IntervalInfo_selectBtn.isSelected) {
        NSString *interval_value = self.IntervalInfoTF.text;
        self.beaconConfiguratedDic[kInterval] = interval_value;
    }
    
    // Pin
    if (self.pinInfo_selectBtn.isSelected) {
        self.beaconConfiguratedDic[kPin] = self.pinInfoTF.text;
    }
    
    // TxPower
    if (self.txPowerInfo_selectBtn.isSelected) {
        NSString *txPower_value = self.txPowerInfo_value.text;
        self.beaconConfiguratedDic[kTxPower] = txPower_value;
    }
    
    // Gsensor3
    if (self.gSensor3Info_selectBtn.isSelected) {
        NSMutableArray *gsensor3_values = [NSMutableArray array];
        
        NSString *gSensor3Info_interval_value = self.gSensor3Info_intervalTF.text;
        gsensor3_values[0] = gSensor3Info_interval_value;
        
        NSString *gSensor3Info_duration_value = self.gSensor3Info_durationTF.text;
        gsensor3_values[1] = gSensor3Info_duration_value;
        
        NSString *gSensor3Info_sensitivity_value = self.gSensor3Info_sensitivityTF.text;
        gsensor3_values[2] = gSensor3Info_sensitivity_value;
        
        self.beaconConfiguratedDic[kGsensor] = gsensor3_values;
    }
    
    // Gsensor2
    if (self.gSensor2Info_selectBtn.isSelected) {
        NSMutableArray *gsensor2_values = [NSMutableArray array];
        
        NSString *gSensor2Info_interval_value = self.gSensor2Info_intervalTF.text;
        gsensor2_values[0] = gSensor2Info_interval_value;
        
        NSString *gSensor2Info_duration_value = self.gSensor2Info_durationTF.text;
        gsensor2_values[1] = gSensor2Info_duration_value;
        
        self.beaconConfiguratedDic[kGsensor] = gsensor2_values;
    }
    
    // Key
    if (self.keyInfo_selectBtn.isSelected) {
        NSMutableArray *keyValues = [NSMutableArray array];
        
        NSString *keyInfo_interval_value = self.keyInfo_intervalTF.text;
        keyValues[0] = keyInfo_interval_value;
        
        NSString *keyInfo_duration_value = self.keyInfo_durationTF.text;
        keyValues[1] = keyInfo_duration_value;
        
        self.beaconConfiguratedDic[kKey] = keyValues;
    }
    
    // TLM
    if (self.tLMInfo_selectBtn.isSelected) {
        NSString *tLM_value = [NSString stringWithFormat:@"%d", (int)self.tLMInfo_switch.isOn];
        self.beaconConfiguratedDic[kTLM] = tLM_value;
    }
    
    // Longrange
    if (self.longRangeInfo_selectBtn.isSelected) {
        NSString *longRange_value = [NSString stringWithFormat:@"%d", (int)self.longRangeInfo_switch.isOn];
        self.beaconConfiguratedDic[kLongRange] = longRange_value;
    }
    
    
    // 至少选择一项才能开始
    if (self.beaconConfiguratedDic.allKeys.count == 0) {
        [self presenteErrorWithMessage:LS(@"Please check the item to be modified")];
        return;
    }
    
    NSLog(@"self.beaconManager.names:%@", self.beaconConfiguratedDic.allKeys);
    NSLog(@"self.beaconManager.values:%@", self.beaconConfiguratedDic.allValues);
    
    // 断开当前的模块的连接
    [self.peripheralManager setCloseHandler:^(NSError * _Nullable error) {
    }];
    [self.peripheralManager.session closeSession];
    
    FWBatchSelectDeviceVC *batchSelectDeviceVC = [[FWBatchSelectDeviceVC alloc] initWithBeaconConfigurated:self.beaconConfiguratedDic filterModelType:self.peripheralManager.peripheralItem.modelIndex filterVersionMin:self.lowVersionTF.text filterVersionMax:self.hightVersionTF.text];
    [self.navigationController pushViewController:batchSelectDeviceVC animated:YES];
}

- (void)presenteErrorWithMessage:(NSString *)errorText {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:errorText
    message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault
    handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
