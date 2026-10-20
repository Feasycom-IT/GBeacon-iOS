//
//  FBBeaconBroadcastVC.m
//  FeasyBeacon
//
//  Created by chenchanghua on 2024/7/3.
//  Copyright © 2024 Feasycom. All rights reserved.
//

#import "FBBeaconBroadcastVC.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "FWPopoverViewController.h"
#include "sensor.h"

@interface FBBeaconBroadcastVC () <CBPeripheralManagerDelegate, UITextFieldDelegate>

- (void)startAdvertising;
- (void)stopAdvertising;

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@property (nonatomic, strong) NSDictionary *advertisementData;

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

// ----iBeacon
@property (nonatomic, strong) UILabel *uuidLabel;
@property (nonatomic, strong) UITextField *uuidTextField;

@property (nonatomic, strong) UILabel *majorLabel;
@property (nonatomic, strong) UITextField *majorTextField;

@property (nonatomic, strong) UILabel *minorLabel;
@property (nonatomic, strong) UITextField *minorTextField;

@property (nonatomic, strong) UILabel *txPowerAt1mLabel;
@property (nonatomic, strong) UITextField *txPowerAt1mTextField;

@property (nonatomic, strong) UISwitch *iBeaconSwitch;

// ----AoA Beacon
@property (nonatomic, strong) UILabel *macLabel;
@property (nonatomic, strong) UITextField *macTextField;

@property (nonatomic, strong) UISwitch *aoa_alarmSwitch;
@property (nonatomic, strong) UISwitch *aoa_movingSwitch;
@property (nonatomic, strong) UIButton *aoa_channelButton;
@property (nonatomic, assign) uint8_t aoa_channel;

@property (nonatomic, strong) UISwitch *aoaBeaconSwitch;

@end

@implementation FBBeaconBroadcastVC

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化CBPeripheralManager
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadData];
    [self setupNavigationContent];
    [self setupViewContent];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopAdvertising];
}

- (void)loadData {
    
}

- (void)setupNavigationContent {
    self.title = LS(@"Beacon Broadcast");
    
    UINavigationItem *navigationItem = [self navigationItem];
    UIButton *beaconSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [beaconSwitchBtn setTitle:LS(@"Switch") forState:UIControlStateNormal];
    [beaconSwitchBtn addTarget:self action:@selector(beaconSwitchItemAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *beaconSwitchItem = [[UIBarButtonItem alloc] initWithCustomView:beaconSwitchBtn];
    [navigationItem setRightBarButtonItems:@[beaconSwitchItem]];
}

- (void)setupViewContent {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    /// !-------- iBeacon广播
    
    // 创建 iBeacon 配置容器视图
    UIView *iBeaconView = [[UIView alloc] init];
    iBeaconView.tag = 1001;
    [self.view addSubview:iBeaconView];
    [iBeaconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    UILabel *titleLabel_iBeacon = [[UILabel alloc] init];
    titleLabel_iBeacon.backgroundColor = [UIColor lightGrayColor];
    titleLabel_iBeacon.text = @"----iBeacon----";
    [iBeaconView addSubview:titleLabel_iBeacon];
    [titleLabel_iBeacon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(iBeaconView.mas_top).offset(100);
        make.left.mas_equalTo(iBeaconView.mas_left).offset(20);
    }];
    
    self.uuidLabel = [[UILabel alloc] init];
    self.uuidLabel.text = @"UUID";
    [iBeaconView addSubview:self.uuidLabel];
    [self.uuidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel_iBeacon.mas_bottom).offset(20);
        make.left.mas_equalTo(iBeaconView.mas_left).offset(20);
    }];
    
    self.uuidTextField = [[UITextField alloc] init];
    self.uuidTextField.font = [UIFont systemFontOfSize:12];
    self.uuidTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.uuidTextField.placeholder = @"0~9,A~F,8-4-4-4-12";
    self.uuidTextField.delegate = self;
    [self.uuidTextField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    [iBeaconView addSubview:self.uuidTextField];
    [self.uuidTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.uuidLabel.mas_centerY).offset(0);
        make.left.mas_equalTo(self.uuidLabel.mas_right).offset(10);
        make.right.mas_equalTo(iBeaconView.mas_right).offset(-20);
    }];
    
    self.majorLabel = [[UILabel alloc] init];
    self.majorLabel.text = @"Major";
    [iBeaconView addSubview:self.majorLabel];
    [self.majorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.uuidLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(iBeaconView.mas_left).offset(20);
    }];
    
    self.majorTextField = [[UITextField alloc] init];
    self.majorTextField.font = [UIFont systemFontOfSize:12];
    self.majorTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.majorTextField.placeholder = @"0～65535";
    self.majorTextField.delegate = self;
    self.majorTextField.keyboardType = UIKeyboardTypeNumberPad;
    [iBeaconView addSubview:self.majorTextField];
    [self.majorTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.majorLabel.mas_centerY).offset(0);
        make.left.mas_equalTo(self.majorLabel.mas_right).offset(10);
        make.right.mas_equalTo(iBeaconView.mas_right).offset(-20);
    }];
    
    self.minorLabel = [[UILabel alloc] init];
    self.minorLabel.text = @"Minor";
    [iBeaconView addSubview:self.minorLabel];
    [self.minorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.majorLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(iBeaconView.mas_left).offset(20);
    }];
    
    self.minorTextField = [[UITextField alloc] init];
    self.minorTextField.font = [UIFont systemFontOfSize:12];
    self.minorTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.minorTextField.placeholder = @"0～65535";
    self.minorTextField.delegate = self;
    self.minorTextField.keyboardType = UIKeyboardTypeNumberPad;
    [iBeaconView addSubview:self.minorTextField];
    [self.minorTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.minorLabel.mas_centerY).offset(0);
        make.left.mas_equalTo(self.minorLabel.mas_right).offset(10);
        make.right.mas_equalTo(iBeaconView.mas_right).offset(-20);
    }];
    
    self.txPowerAt1mLabel = [[UILabel alloc] init];
    self.txPowerAt1mLabel.text = @"TxPowerAt1m";
    [iBeaconView addSubview:self.txPowerAt1mLabel];
    [self.txPowerAt1mLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.minorLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(iBeaconView.mas_left).offset(20);
    }];
    
    self.txPowerAt1mTextField = [[UITextField alloc] init];
    self.txPowerAt1mTextField.font = [UIFont systemFontOfSize:12];
    self.txPowerAt1mTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.txPowerAt1mTextField.placeholder = @"-100～0";
    self.txPowerAt1mTextField.delegate = self;
    [iBeaconView addSubview:self.txPowerAt1mTextField];
    [self.txPowerAt1mTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.txPowerAt1mLabel.mas_centerY).offset(0);
        make.left.mas_equalTo(self.txPowerAt1mLabel.mas_right).offset(10);
        make.right.mas_equalTo(iBeaconView.mas_right).offset(-20);
    }];
    
    self.iBeaconSwitch = [[UISwitch alloc] init];
    [self.iBeaconSwitch setOn:NO];
    [self.iBeaconSwitch addTarget:self action:@selector(iBeaconSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [iBeaconView addSubview:self.iBeaconSwitch];
    [self.iBeaconSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.txPowerAt1mLabel.mas_bottom).offset(30);
        make.centerX.mas_equalTo(iBeaconView.mas_centerX);
    }];
    
    // 设置 UILabel 和 UITextField 的 content hugging 和 compression resistance 优先级
    [self.uuidLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.uuidLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.uuidTextField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.uuidTextField setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.majorLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.majorLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.majorTextField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.majorTextField setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.minorLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.minorLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.minorTextField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.minorTextField setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.txPowerAt1mLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.txPowerAt1mLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.txPowerAt1mTextField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.txPowerAt1mTextField setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    /// !-------- AoA Beacon广播
    
    // 创建 AoA Beacon 配置容器视图
    UIView *aoaBeaconView = [[UIView alloc] init];
    aoaBeaconView.tag = 1002;
    [self.view addSubview:aoaBeaconView];
    [aoaBeaconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    UILabel *titleLabel_aoaBeacon = [[UILabel alloc] init];
    titleLabel_aoaBeacon.backgroundColor = [UIColor lightGrayColor];
    titleLabel_aoaBeacon.text = @"----AoA Beacon----";
    [aoaBeaconView addSubview:titleLabel_aoaBeacon];
    [titleLabel_aoaBeacon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(aoaBeaconView.mas_top).offset(100);
        make.left.mas_equalTo(aoaBeaconView.mas_left).offset(20);
    }];
    
    self.macLabel = [[UILabel alloc] init];
    self.macLabel.text = LS(@"The last four digits of Mac");
    [aoaBeaconView addSubview:self.macLabel];
    [self.macLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel_aoaBeacon.mas_bottom).offset(20);
        make.left.mas_equalTo(aoaBeaconView.mas_left).offset(20);
    }];
    
    self.macTextField = [[UITextField alloc] init];
    self.macTextField.font = [UIFont systemFontOfSize:12];
    self.macTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.macTextField.placeholder = [NSString stringWithFormat:@"%@ 0000", LS(@"Default is")];
    [self.macTextField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    self.macTextField.delegate = self;
    [aoaBeaconView addSubview:self.macTextField];
    [self.macTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.macLabel.mas_centerY).offset(0);
        make.left.mas_equalTo(self.macLabel.mas_right).offset(10);
        make.right.mas_equalTo(aoaBeaconView.mas_right).offset(-20);
    }];
    
    UILabel *aoa_alarmLabel = [[UILabel alloc] init];
    aoa_alarmLabel.text = LS(@"Alarm");
    [aoaBeaconView addSubview:aoa_alarmLabel];
    [aoa_alarmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.macLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(aoaBeaconView.mas_left).offset(20);
    }];
    
    self.aoa_alarmSwitch = [[UISwitch alloc] init];
    [self.aoa_alarmSwitch setOn:NO];
    [aoaBeaconView addSubview:self.aoa_alarmSwitch];
    [self.aoa_alarmSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(aoa_alarmLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(aoa_alarmLabel.mas_centerY);
    }];
    
    UILabel *aoa_movingLabel = [[UILabel alloc] init];
    aoa_movingLabel.text = LS(@"Moving");
    [aoaBeaconView addSubview:aoa_movingLabel];
    [aoa_movingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(aoaBeaconView.mas_centerX).offset(0);
        make.centerY.mas_equalTo(aoa_alarmLabel.mas_centerY);
    }];
    
    self.aoa_movingSwitch = [[UISwitch alloc] init];
    [self.aoa_movingSwitch setOn:NO];
    [aoaBeaconView addSubview:self.aoa_movingSwitch];
    [self.aoa_movingSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(aoa_movingLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(aoa_alarmLabel.mas_centerY);
    }];
    
    UILabel *aoa_channelLabel = [[UILabel alloc] init];
    aoa_channelLabel.text = LS(@"Channel");
    [aoaBeaconView addSubview:aoa_channelLabel];
    [aoa_channelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(aoa_alarmLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(aoaBeaconView.mas_left).offset(20);
    }];
    
    self.aoa_channelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.aoa_channelButton setTitle:@"37" forState:UIControlStateNormal];
    [self.aoa_channelButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [self.aoa_channelButton addTarget:self action:@selector(aoa_channelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [aoaBeaconView addSubview:self.aoa_channelButton];
    [self.aoa_channelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(aoa_channelLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(aoa_channelLabel.mas_centerY);
    }];
    
    self.aoaBeaconSwitch = [[UISwitch alloc] init];
    [self.aoaBeaconSwitch setOn:NO];
    [self.aoaBeaconSwitch addTarget:self action:@selector(aoaBeaconSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [aoaBeaconView addSubview:self.aoaBeaconSwitch];
    [self.aoaBeaconSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(aoa_channelLabel.mas_bottom).offset(20);
        make.centerX.mas_equalTo(aoaBeaconView.mas_centerX);
    }];
    
    [self.macLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.macLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.macTextField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.macTextField setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    // 默认显示 iBeacon 配置，隐藏 AoA Beacon 配置
    aoaBeaconView.hidden = YES;
}

- (void)startAdvertising {
    // 自定义广播数据
    NSData *dataToBroadcast = [@"Hello, this is device A" dataUsingEncoding:NSUTF8StringEncoding];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"FFF0"];
    NSDictionary *advertisingData = @{
        CBAdvertisementDataLocalNameKey: @"DeviceA",
        CBAdvertisementDataServiceUUIDsKey: @[serviceUUID],
        CBAdvertisementDataServiceDataKey: @{serviceUUID: dataToBroadcast}
    };
    
    [self.peripheralManager startAdvertising:advertisingData];
}

- (void)stopAdvertising {
    [self.peripheralManager stopAdvertising];
}
    
- (void)startAdvertising_aoaBeacon {
    
    // 初始化广告数据字典
    NSMutableDictionary *advertisementData = [NSMutableDictionary dictionary];
    
    // 设置本地名称
    NSString *name = @"FeasyBeacon";
    advertisementData[CBAdvertisementDataLocalNameKey] = name;
    
    // mac地址后四位
    NSString *macText = self.macTextField.text.length == 4 ? self.macTextField.text : @"0000";
    unsigned int id;
    NSScanner *scanner = [NSScanner scannerWithString:[macText substringFromIndex:MAX((int)macText.length - 4, 0)]];
    [scanner scanHexInt:&id];
    id = id ?: 0x0000;
    
    // 警告开启与否
    UInt8 alarm = self.aoa_alarmSwitch.isOn ? 1 : 0;
    
    // 电池电量
    UIDevice *device = [UIDevice currentDevice];
    [device setBatteryMonitoringEnabled:YES];
    UInt8 battery = (UInt8)(device.batteryLevel * 10);
    
    // 移动与否
    UInt8 isStatic = self.aoa_movingSwitch.isOn ? 0 : 1;
    
    // 创建服务 UUID
    const UInt16 *data = coreaiot_generate_service_uuids(id, alarm, battery, self.aoa_channel, isStatic);
    int len = COREAIOT_NUMBER_OF_SERVICE_UUIDS;
    UInt16 arr[len];
    memset(arr, 0, sizeof(arr));
    
    for (int i = 0; i < len; i++) {
        arr[i] = data[i];
    }
    
    NSMutableArray *arrC = [NSMutableArray arrayWithCapacity:len];
    for (int i = 0; i < len; i++) {
        [arrC addObject:@(arr[i])];
    }
    
    NSLog(@"arr_c: %@", arrC);
    
    NSMutableArray *uuids = [NSMutableArray arrayWithCapacity:len];
    for (int i = 0; i < len; i++) {
        NSString *uuidString = [NSString stringWithFormat:@"%04x", arr[i]];
        NSLog(@"CBUUID: %@", uuidString);
        [uuids addObject:[CBUUID UUIDWithString:uuidString]];
    }
    
    // 设置服务 UUID 数组
    advertisementData[CBAdvertisementDataServiceUUIDsKey] = uuids;
    
    // 检查广告数据是否正确
    NSLog(@"广告数据: %@", advertisementData);
    
    // 计算数据长度
    int advDataLength = [name length] + 2.f; // Local Name 长度 + 2 个字节的长度前缀
    for (CBUUID *uuid in advertisementData[CBAdvertisementDataServiceUUIDsKey]) {
        advDataLength += uuid.data.length + 2; // 每个 UUID 的长度 + 2 个字节的长度前缀
    }
    NSLog(@"广告数据总长度: %d", advDataLength);
    
    if (advDataLength > 31) {
        NSLog(@"广告数据超出长度限制");
    }
    
    // 检查 peripheralManager 状态
    if (self.peripheralManager.state == CBManagerStatePoweredOn) {
        // 开始广告
        [self.peripheralManager startAdvertising:advertisementData];
        NSLog(@"开始广告发布");
    } else {
        NSLog(@"Peripheral Manager 状态不正确: %ld", (long)self.peripheralManager.state);
    }
}

- (void)startAdvertising_iBeacon {
    
    // 初始化广告数据字典
    NSMutableDictionary *advertisementData = [[self advertisementData_iBeacon] mutableCopy];
    
    // 设置本地名称
    advertisementData[CBAdvertisementDataLocalNameKey] = @"FeasyBeacon App";
    
    // 创建服务 UUID
    CBUUID *serviceUUID1 = [CBUUID UUIDWithString:@"FFF0"];
    CBUUID *serviceUUID2 = [CBUUID UUIDWithString:@"FEAA"];
    
    // 设置服务 UUID 数组
    NSArray *serviceUUIDs = @[serviceUUID1, serviceUUID2];
    advertisementData[CBAdvertisementDataServiceUUIDsKey] = serviceUUIDs;
    
    // 检查广告数据是否正确
    NSLog(@"广告数据: %@", advertisementData);
    
    // 检查 peripheralManager 状态
    if (self.peripheralManager.state == CBManagerStatePoweredOn) {
        // 开始广告
        [self.peripheralManager startAdvertising:advertisementData];
        NSLog(@"开始广告发布");
    } else {
        NSLog(@"Peripheral Manager 状态不正确: %ld", (long)self.peripheralManager.state);
    }
}

// MARK: - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
            NSLog(@"Bluetooth is powered on");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"Bluetooth is powered off");
            break;
        case CBManagerStateResetting:
            NSLog(@"Bluetooth is resetting");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"Bluetooth is unauthorized");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"Bluetooth is unsupported");
            break;
        case CBManagerStateUnknown:
            NSLog(@"Bluetooth state is unknown");
            break;
        default:
            NSLog(@"A previously unknown peripheral manager state occurred");
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didStartAdvertising:(NSError *)error {
    if (error) {
        NSLog(@"Error starting advertising: %@", [error localizedDescription]);
    } else {
        NSLog(@"Successfully started advertising.");
    }
}

- (void)iBeaconSwitchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [self startAdvertising_iBeacon];
        // 广播打开中，输入框中内容不能修改
        self.uuidTextField.enabled = NO;
        self.majorTextField.enabled = NO;
        self.minorTextField.enabled = NO;
        self.txPowerAt1mTextField.enabled = NO;
    } else {
        [self stopAdvertising];
        // 广播关闭中，输入框中内容可以修改
        self.uuidTextField.enabled = YES;
        self.majorTextField.enabled = YES;
        self.minorTextField.enabled = YES;
        self.txPowerAt1mTextField.enabled = YES;
    }
}

- (void)aoaBeaconSwitchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [self startAdvertising_aoaBeacon];
        // 广播打开中，输入框中内容不能修改
        self.macTextField.enabled = NO;
        self.aoa_alarmSwitch.enabled = NO;
        self.aoa_movingSwitch.enabled = NO;
        self.aoa_channelButton.enabled = NO;
    } else {
        [self stopAdvertising];
        // 广播打开中，输入框中内容不能修改
        self.macTextField.enabled = YES;
        self.aoa_alarmSwitch.enabled = YES;
        self.aoa_movingSwitch.enabled = YES;
        self.aoa_channelButton.enabled = YES;
    }
}

- (void)aoa_channelButtonAction:(UIButton *)sender {
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:@[@"37", @"38", @"39"] sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *phy) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([phy isEqualToString:@"38"]) {
                [strongSelf->_aoa_channelButton setTitle:@"38" forState:UIControlStateNormal];
                strongSelf->_aoa_channel = 1;
            } else if ([phy isEqualToString:@"39"]) {
                [strongSelf->_aoa_channelButton setTitle:@"39" forState:UIControlStateNormal];
                strongSelf->_aoa_channel = 2;
            } else {
                [strongSelf->_aoa_channelButton setTitle:@"37" forState:UIControlStateNormal];
                strongSelf->_aoa_channel = 0;
            }
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (NSDictionary *)advertisementData_iBeacon {
    // 设置 iBeacon 区域
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.uuidTextField.text];
    CLBeaconMajorValue major = [self.majorTextField.text intValue];
    CLBeaconMinorValue minor = [self.minorTextField.text intValue];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:@"com.feasycom.myBeacon"];
    // 广播数据
    NSDictionary *peripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:@([self.txPowerAt1mTextField.text intValue])];
    
    return peripheralData;
}

- (void)beaconSwitchItemAction:(UIButton *)sender {
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:@[@"iBeacon", @"AoA"] sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *type) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            UIView *iBeaconView = [strongSelf.view viewWithTag:1001];
            UIView *aoaBeaconView = [strongSelf.view viewWithTag:1002];
            
            if ([type isEqualToString:@"iBeacon"]) {
                if (strongSelf.aoaBeaconSwitch.isOn) {
                    [strongSelf.aoaBeaconSwitch setOn:NO];
                    [strongSelf aoaBeaconSwitchChanged:strongSelf.aoaBeaconSwitch];
                }
                iBeaconView.hidden = NO;
                aoaBeaconView.hidden = YES;
            } else if ([type isEqualToString:@"AoA"]) {
                if (strongSelf.iBeaconSwitch.isOn) {
                    [strongSelf.iBeaconSwitch setOn:NO];
                    [strongSelf iBeaconSwitchChanged:strongSelf.iBeaconSwitch];
                }
                iBeaconView.hidden = YES;
                aoaBeaconView.hidden = NO;
            }
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.uuidTextField) {
        // 合并现有文本和新输入的文本
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // 允许删除操作
        if ([string isEqualToString:@""]) {
            return YES;
        }
        
        // 限制输入长度为36个字符 (8-4-4-4-12 的格式)
        if (newString.length > 36) {
            return NO;
        }
        
        // 定义有效的十六进制字符集
        NSCharacterSet *hexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
        // 定义有效字符集包含十六进制字符和破折号
        NSCharacterSet *validCharacterSet = [hexCharacterSet invertedSet];
        
        // 检查输入字符是否有效
        if ([string rangeOfCharacterFromSet:validCharacterSet].location != NSNotFound) {
            return NO;
        }
        
        // 根据新输入的文本格式化UUID
        if (newString.length > 8 && newString.length <= 9) {
            newString = [NSString stringWithFormat:@"%@-%@", [newString substringToIndex:8], [newString substringFromIndex:8]];
        } else if (newString.length > 13 && newString.length <= 14) {
            newString = [NSString stringWithFormat:@"%@-%@", [newString substringToIndex:13], [newString substringFromIndex:13]];
        } else if (newString.length > 18 && newString.length <= 19) {
            newString = [NSString stringWithFormat:@"%@-%@", [newString substringToIndex:18], [newString substringFromIndex:18]];
        } else if (newString.length > 23 && newString.length <= 24) {
            newString = [NSString stringWithFormat:@"%@-%@", [newString substringToIndex:23], [newString substringFromIndex:23]];
        }
        
        textField.text = newString.uppercaseString;
        return NO;
    } else if (textField == self.majorTextField || textField == self.minorTextField) {
        // 合并现有文本和新输入的文本
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // 允许删除操作
        if ([string isEqualToString:@""]) {
            return YES;
        }
        
        // 定义有效的数字字符集
        NSCharacterSet *numbersSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSCharacterSet *invertedNumbersSet = [numbersSet invertedSet];
        
        // 检查输入字符是否有效
        if ([string rangeOfCharacterFromSet:invertedNumbersSet].location != NSNotFound) {
            return NO;
        }
        
        // 检查输入值是否在0到65535之间
        NSInteger newValue = [newString integerValue];
        if (newValue < 0 || newValue > 65535) {
            return NO;
        }
        
        return YES;
    } else if (textField == self.txPowerAt1mTextField) {
        // 合并现有文本和新输入的文本
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // 允许删除操作
        if ([string isEqualToString:@""]) {
            return YES;
        }
        
        // 定义有效的数字和负号字符集
        NSCharacterSet *numbersSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789-"];
        NSCharacterSet *invertedNumbersSet = [numbersSet invertedSet];
        
        // 检查输入字符是否有效
        if ([string rangeOfCharacterFromSet:invertedNumbersSet].location != NSNotFound) {
            return NO;
        }
        
        // 检查是否有多个负号
        if ([[newString componentsSeparatedByString:@"-"] count] > 2) {
            return NO;
        }
        
        // 检查负号是否在第一位
        if ([newString rangeOfString:@"-"].location > 0) {
            return NO;
        }
        
        // 检查输入值是否在合理范围内
        NSInteger newValue = [newString integerValue];
        if (newValue < -100 || newValue > 0) {
            return NO;
        }
        
        return YES;
    } else if (textField == self.macTextField) {
        // 合并现有文本和新输入的文本
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // 允许删除操作
        if ([string isEqualToString:@""]) {
            return YES;
        }
        
        // 限制输入长度为4个字符
        if (newString.length > 4) {
            return NO;
        }
        
        // 定义有效的十六进制字符集
        NSCharacterSet *hexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
        NSCharacterSet *invertedHexCharacterSet = [hexCharacterSet invertedSet];
        
        // 检查输入字符是否有效
        if ([string rangeOfCharacterFromSet:invertedHexCharacterSet].location != NSNotFound) {
            return NO;
        }
        
        return YES;
    }
    
    return YES;
}

@end
