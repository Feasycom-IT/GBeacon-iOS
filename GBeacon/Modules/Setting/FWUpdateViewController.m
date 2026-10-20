//
//  FWUpdateViewController.m
//  FeasyBeacon
//
//  Created by ericj on 2017/10/9.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import "FWUpdateViewController.h"
#import "Masonry.h"
#import "XLCircle.h"
#import "XLCircleProgress.h"
#import "FWSettingsViewController.h"
#import "NSString+HexStringToData.h"
#import "FWBeaconsViewController.h"
#import "MYFileTableViewController.h"
#import "FEDFUFileTableViewController.h"
#import "NSString+FscKit.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "UIImage+Color.h"
#import "FEFirmwareInfoModel.h"
#import "FBSDKPublicHeader.h"

#define SOH  0x01
#define STX  0x02
#define EOT  0x04
#define ACK  0x06
#define NAK  0x15
#define CAN  0x18
#define CTRLZ 0x1A

#define DLY_1S 1000
#define MAXRETRANS 30

#define CONNECTTIMEOUT 3 //连接重试次数
#define WAITTIME  2 //等待1秒后开始

@interface FWUpdateViewController () {
    XLCircleProgress *_circleProgress;
    NSUserDefaults *_userDefaults;
    UIButton *_fileButton;
    UIButton *_importButton;
}

@property (nonatomic, strong) FBUpgradeManager *upgradeManager;

@property (nonatomic, copy) NSString *selectedPath;// 当前选中的升级固件文件

@property (nonatomic, strong) UILabel *fileNameLabel;// 文件名Lable（当前选中的升级固件文件）

@property (nonatomic, strong) UIButton *updateButton;// “开始升级”按钮

@property (nonatomic, strong) UILabel *moduleL;
@property (nonatomic, strong) UILabel *appVersionLabel;
@property (nonatomic, strong) UILabel *blVersionLabel;
@property (nonatomic, strong) UILabel *currentLabel;
@property (nonatomic, strong) UILabel *exceptLabel;

@property (nonatomic, assign) int currentModelNumber;
@property (nonatomic, strong) UILabel *currentModelLabel;
@property (nonatomic, strong) UILabel *currentVersionLabel;
@property (nonatomic, strong) UILabel *currentBlLabel;

@property (nonatomic, strong) UILabel *fileModelLabel;
@property (nonatomic, strong) UILabel *fileAppLabel;
@property (nonatomic, strong) UILabel *fileBlLabel;

@property (nonatomic, strong) FEFirmwareInfoModel *firmwareInfoModel;//升级固件信息

@property (nonatomic, strong) UILabel *updateLabel;
@property (nonatomic, strong) UISwitch *resetSwitch;

@end

@implementation FWUpdateViewController

- (instancetype)initWithPeripheralItem:(FBPeripheralItem *)peripheralItem PINCode:(NSString *)PINCode {
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self setHidesBottomBarWhenPushed:YES];
        
        self.upgradeManager = [[FBUpgradeManager alloc] initWithPeripheralItem:peripheralItem PINCode:PINCode];
        
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"Upgrading"];
        
        NSString *path = [_userDefaults stringForKey:@"upgradingFilePath"];
        
        if (path && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
            self.selectedPath = [path copy];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFilePath:) name:FWUpdateFilePathNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.upgradeManager.session closeSession];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self updateFromSelectedPath];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

// 点击“开始升级”按钮
- (void)clickToUpdate:(UIButton *)sender {
    if (self.selectedPath.length == 0) {
        [self showAlertControllerWithTitle:LS(@"Please import firmware")];
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.selectedPath]) {
        [self showAlertControllerWithTitle:LS(@"File is not exist")];
        return;
    }
    
//    _moduleL.hidden = YES;
//    _appVersionLabel.hidden = YES;
//    _blVersionLabel.hidden = YES;
//    _currentLabel.hidden = YES;
//    _exceptLabel.hidden = YES;
//    _currentModelLabel.hidden = YES;
//    _currentVersionLabel.hidden = YES;
//    _currentBlLabel.hidden = YES;
//    _fileModelLabel.hidden = YES;
//    _fileAppLabel.hidden = YES;
//    _fileBlLabel.hidden = YES;
    
    _circleProgress.hidden = NO;
    _updateLabel.hidden = NO;

    _fileButton.enabled = NO;
    _importButton.enabled = NO;
    self.updateButton.enabled = NO;
    
    __weak __typeof(self) weakSelf = self;
    [self.upgradeManager upgradeWithFilePath:self.selectedPath restore:_resetSwitch.isOn infoHandler:^(NSDictionary * _Nullable info) {
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.currentModelLabel.text = info[kModelKey];
        strongSelf.currentVersionLabel.text = info[kAppVersionKey];
        strongSelf.currentBlLabel.text = info[kBLVersionKey];
        strongSelf.currentModelNumber = ((NSNumber *)info[kModelNumKey]).intValue;
        
        if ([strongSelf contrastDevideAndFirmwareForContinueUpgrading]) {
            NSLog(@"yes");
        }
        
    } progressHandler:^(CGFloat progress) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setProgress:progress];
    } completionHandler:^(NSError * _Nullable error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        const NSInteger code = error.code;
        if (0 == code) {
            [strongSelf showAlertControllerAndPopWithTitle:LS(@"Upgrade successful")];
        } else {
            [strongSelf showAlertControllerAndPopWithTitle:LS(@"Upgrade failed")];
        }
    }];
}

// 模块信息 vs 固件信息
- (BOOL)contrastDevideAndFirmwareForContinueUpgrading {
    // 模块序号的判断
    NSInteger device_num = self.currentModelNumber;
    NSInteger firmware_num = self.firmwareInfoModel.modelTypeNum;
    if (device_num == 0) {
        return YES;
    }
    if (device_num != firmware_num) {
        // device == BP109 && firmware == BT909  ==> pass
        if (device_num != 25 || firmware_num != 20) {
            return NO;
        }
    }
    // APP版本号的判断
    NSArray *verNums = [self.currentVersionLabel.text componentsSeparatedByString:@"."];
    NSString *verStr = [verNums componentsJoinedByString:@""];
    NSInteger device_ver = verStr.integerValue;
    
    NSArray *verRangeNums = [self.fileAppLabel.text componentsSeparatedByString:@"-"];
    NSString *fireVerStr = verRangeNums.firstObject;
    NSInteger firmware_ver = fireVerStr.integerValue;
    
    if (device_ver < firmware_ver) {
        return NO;
    }
    // BL版本号的判断
    NSArray *blNums = [self.currentBlLabel.text componentsSeparatedByString:@"."];
    NSString *blStr = [blNums componentsJoinedByString:@""];
    NSInteger device_bl = blStr.integerValue;
    
    NSString *firmBlStr = self.fileBlLabel.text;
    NSInteger firm_bl = firmBlStr.integerValue;
    
    if (device_bl < firm_bl) {
        return NO;
    }
    return YES;
}

-(void)setProgress:(CGFloat)progress {
    _updateLabel.text = [NSString stringWithFormat:@"%.1f%%", progress * 100.0];
    _circleProgress.progress = progress;
}

- (void)setupUI {
    UIView *view = self.view;
    
    UIImage *image = [[UIImage imageWithColor:[UIColor colorWithRed:0 green:0.5 blue:0.75 alpha:1.f] borderColor:[UIColor darkGrayColor] size:CGSizeMake(44, 44) radius:10] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 22, 0, 22)];
    
    UIButton *fileButton = [[UIButton alloc] init];
    
    [fileButton setBackgroundImage:image forState:UIControlStateNormal];
    [fileButton setTitle:LS(@"selectFirmware") forState:UIControlStateNormal];
    fileButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [fileButton addTarget:self action:@selector(clickToSelectFile:) forControlEvents:UIControlEventTouchUpInside];
    fileButton.adjustsImageWhenHighlighted = NO;
    [view addSubview:fileButton];
    
    _fileButton = fileButton;
    
    UIButton *importButton = [[UIButton alloc] init];
    
    [importButton setBackgroundImage:image forState:UIControlStateNormal];
    [importButton setTitle:LS(@"importFirmware") forState:UIControlStateNormal];
    importButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [importButton addTarget:self action:@selector(importFile:) forControlEvents:UIControlEventTouchUpInside];
    importButton.adjustsImageWhenHighlighted = NO;
    [view addSubview:importButton];
    
    _importButton = importButton;
    
    __weak __typeof(self) weakSelf = self;
    
    [fileButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(kNavBar_Height+10);
        make.left.equalTo(weakSelf.view).offset(10);
        make.width.equalTo(@120);
        make.height.equalTo(@44);
    }];
    
    [importButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fileButton);
        make.left.equalTo(fileButton.mas_right).offset(10);
        make.width.equalTo(@120);
        make.height.equalTo(@44);
    }];
    
    self.fileNameLabel = [[UILabel alloc] init];
    self.fileNameLabel.text = LS(@"Upgrade file:");
    self.fileNameLabel.font = [UIFont systemFontOfSize:14];
    self.fileNameLabel.numberOfLines = 2;
    [view addSubview:self.fileNameLabel];
    
    UILabel *updateFileLabel = [[UILabel alloc] init];
    
    updateFileLabel.textAlignment = NSTextAlignmentLeft;
    updateFileLabel.numberOfLines = 0;
    updateFileLabel.font = [UIFont systemFontOfSize:14];
    [view addSubview:updateFileLabel];
    
    UILabel *currentLabel = [self createLabelWithText:LS(@"Device") withFontOfSize:14];
    [view addSubview:currentLabel];
    UILabel *fileLabel = [self createLabelWithText:LS(@"Firmware") withFontOfSize:14];
    [view addSubview:fileLabel];
    UILabel *appVersionLabel = [self createLabelWithText:LS(@"App Version") withFontOfSize:14];
    [view addSubview:appVersionLabel];
    UILabel *blLabel = [self createLabelWithText:LS(@"BL Version") withFontOfSize:14];
    [view addSubview:blLabel];
    UILabel *modelLabel = [self createLabelWithText:LS(@"Model") withFontOfSize:14];
    [view addSubview:modelLabel];
    UILabel *currentModelLabel = [self createLabelWithText:@"-" withFontOfSize:14];
    [view addSubview:currentModelLabel];
    UILabel *currentVersionLabel = [self createLabelWithText:@"-" withFontOfSize:14];
    [view addSubview:currentVersionLabel];
    UILabel *currentBlLabel = [self createLabelWithText:@"-" withFontOfSize:14];
    [view addSubview:currentBlLabel];
    UILabel *fileModelLabel = [self createLabelWithText:@"-" withFontOfSize:14];
    [view addSubview:fileModelLabel];
    UILabel *fileAppLabel = [self createLabelWithText:@"-" withFontOfSize:14];
    [view addSubview:fileAppLabel];
    UILabel *fileBlLabel = [self createLabelWithText:@"-" withFontOfSize:14];
    [view addSubview:fileBlLabel];
    UISwitch *reSwitch = [[UISwitch alloc] init];
    [view addSubview:reSwitch];
    UILabel *reLabel = [self createLabelWithText:LS(@"Restore factory setting") withFontOfSize:16];
    [view addSubview:reLabel];
    
    self.updateButton = [[UIButton alloc] init];
    [self.updateButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.updateButton setTitle:LS(@"Start upgrade") forState:UIControlStateNormal];
    [self.updateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.updateButton addTarget:self action:@selector(clickToUpdate:) forControlEvents:UIControlEventTouchUpInside];
    [self.updateButton setEnabled:NO];
    [view addSubview:self.updateButton];
    
    [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fileButton.mas_bottom).offset(20);
        make.left.equalTo(view).offset(20);
        make.right.equalTo(view).offset(-20);
        make.height.equalTo(@40);
    }];
    
    [updateFileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fileNameLabel.mas_right).offset(5);
        make.top.equalTo(self.fileNameLabel);
        make.right.equalTo(view).offset(-20);
    }];
    [self.fileNameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];;
    [updateFileLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    [currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileNameLabel.mas_bottom).offset(80);
        make.left.equalTo(self.fileNameLabel);
    }];
    [fileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(currentLabel.mas_bottom).offset(20);
        make.left.equalTo(currentLabel);
    }];
    [modelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileNameLabel.mas_bottom).offset(50);
        make.left.greaterThanOrEqualTo(currentLabel.mas_right).offset(30);
        make.left.greaterThanOrEqualTo(fileLabel.mas_right).offset(30);
    }];
    [appVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(modelLabel.mas_right).offset(30);
        make.top.equalTo(modelLabel);
    }];
    [blLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(appVersionLabel);
        make.left.equalTo(appVersionLabel.mas_right).offset(30);
    }];
    [fileModelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(modelLabel);
        make.centerY.equalTo(fileLabel);
    }];
    [fileAppLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(appVersionLabel);
        make.centerY.equalTo(fileModelLabel);
    }];
    [fileBlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(blLabel);
        make.centerY.equalTo(fileAppLabel);
    }];
    [currentModelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(fileModelLabel);
        make.centerY.equalTo(currentLabel);
    }];
    [currentVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(fileAppLabel);
        make.centerY.equalTo(currentModelLabel);
    }];
    [currentBlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(fileBlLabel);
        make.centerY.equalTo(currentVersionLabel);
    }];
    [self.updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.right.equalTo(view).offset(-20);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(view).offset(-(49+34+10));
    }];
    [reSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.updateButton);
        make.bottom.equalTo(self.updateButton.mas_top).offset(-8);
    }];
    [reLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(reSwitch.mas_right).offset(8);
        make.centerY.equalTo(reSwitch);
    }];
    
    //进度图
    _circleProgress = [[XLCircleProgress alloc] initWithFrame:CGRectMake(view.frame.size.width/2.0-100, 200, 200, 200)];
    _circleProgress.hidden = YES;
    _circleProgress.alpha = 0.5;
    [view addSubview:_circleProgress];
    
    _updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width/2.0-100, 200, 200, 200)];
    _updateLabel.font = [UIFont systemFontOfSize:40];
    _updateLabel.textAlignment = NSTextAlignmentCenter;
    _updateLabel.text = @"0.00%";
    _updateLabel.hidden = YES;
    _updateLabel.alpha = 0.5;
    [view addSubview:_updateLabel];
    
    _moduleL = modelLabel;
    _appVersionLabel = appVersionLabel;
    _blVersionLabel = blLabel;
    _currentLabel = currentLabel;
    _exceptLabel = fileLabel;
    
    _currentModelLabel = currentModelLabel;
    _currentVersionLabel = currentVersionLabel;
    _currentBlLabel = currentBlLabel;
    
    _fileModelLabel = fileModelLabel;
    _fileAppLabel = fileAppLabel;
    _fileBlLabel = fileBlLabel;
    _resetSwitch = reSwitch;
    
}

- (UILabel *)createLabelWithText:(NSString *)text withFontOfSize:(CGFloat)size {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size];
    return label;
}

// 选择升级文件
- (void)clickToSelectFile:(UIButton *)sender {
    MYFileTableViewController *vc = [[MYFileTableViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

// 导入升级文件
- (void)importFile:(id)sender {
    FEDFUFileTableViewController *viewController = [[FEDFUFileTableViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

// 【通知】重新选择了升级固件文件
- (void)updateFilePath:(NSNotification *)noti {
    self.selectedPath = [noti.userInfo[@"url"] copy];
    /* e.g /var/mobile/Containers/Data/Application/2DC41C8F-047C-4D13-9E34-35E276DD9B1E/Documents/BP104_521.dfu */
    [_userDefaults setValue:self.selectedPath forKey:@"upgradingFilePath"];
    [_userDefaults synchronize];
    [self updateFromSelectedPath];
}

// 从拿到的升级固件中读取相关信息
- (void)updateFromSelectedPath {
    if(nil == self.selectedPath){
        return;
    }
    
    self.fileNameLabel.text = [self.selectedPath lastPathComponent];
    self.updateButton.enabled = YES;
    
    // 读取固件文件中的信息
    NSData *selectedFileData = [[NSData alloc] initWithContentsOfFile:self.selectedPath];
    __weak __typeof(self) weakSelf = self;
    [self.upgradeManager infoFromData:selectedFileData complete:^(NSString *bootloader, NSString *binCrc, NSInteger length, NSString *versionRange, NSString * _Nullable modelType, NSInteger modelTypeNum, NSString *uploadModel, NSString *crc) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.firmwareInfoModel.bootloader = bootloader;
        strongSelf.firmwareInfoModel.binCrc = binCrc;
        strongSelf.firmwareInfoModel.length = length;
        strongSelf.firmwareInfoModel.versionRange = versionRange;
        strongSelf.firmwareInfoModel.modelType = modelType;
        strongSelf.firmwareInfoModel.modelTypeNum = modelTypeNum;
        strongSelf.firmwareInfoModel.uploadModel = uploadModel;
        strongSelf.firmwareInfoModel.crc = crc;
        // 固件信息
        strongSelf.fileModelLabel.text = modelType;
        strongSelf.fileAppLabel.text = versionRange;
        strongSelf.fileBlLabel.text = bootloader;
        
    } faile:^{
        // 解析文件失败（无效文件）
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.firmwareInfoModel.modelTypeNum = -1;
        [strongSelf showAlertControllerWithTitle:@"所选固件文件无效，请重新选择"];
    }];
}

#pragma mark - getter
- (FEFirmwareInfoModel *)firmwareInfoModel {
    if (!_firmwareInfoModel) {
        _firmwareInfoModel = [[FEFirmwareInfoModel alloc] init];
    }
    return _firmwareInfoModel;
}

@end

