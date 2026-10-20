//
//  FWConfigureViewController.m
//  FeasycomWatch
//
//  Created by ericj on 2017/7/26.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import "FWParametersViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "NSData+DataToHexString.h"
#import "UUID.h"
#import "DLog.h"
#import "NSString+FscKit.h"
#import "NSString+HexStringToData.h"
#import "FWConfigureViewCell.h"
#import "FWConfigureTwoCell.h"
#import "FWConfigureFourCell.h"
#import "FWConfigurePowerCell.h"
#import "FWConfigureStateCell.h"
#import "FWGsensorCell.h"
#import "FWThresholdCell.h"
#import "FWAddViewController.h"
#import "FWUpdateViewController.h"
#import "FWAddEddystoneViewController.h"
#import "FWTeaCodeModem.h"
#import "FWCentralViewController.h"
#import "FWSecondViewController.h"
#import "MBProgressHUD.h"
#import "FWAppDelegate.h"
#import "FWRootViewController.h"
#import "FWPopoverViewController.h"
#import "FWDeviceManager.h"
#import "UIColor+FWColor.h"
#import "UIViewController+Extension.h"


#define SECTION_HEIGH 44

static NSString *cellID = @"cellID";
static NSString *footCellID = @"footCellID";
BOOL isFirst = YES;

typedef enum {
    //    BT_RCV_W4_DATA,
    BT_RCV_W4_BADVDATA,
    BT_RCV_W4_OPEN_AIR_CMD_RSP, // $OK,Opened$
    BT_RCV_W4_SETCMD_RSP,   // \r\nOK\r\n  or \r\nERROR\r\n
} BT_RCV_STATE_T;

typedef enum {
    CFG_MODULE_SND_OPEN_AT,   //$OpenFscAtEngine$
    CFG_MODULE_QUERY_DATA,    //AT+BADVDATA
    CFG_MODULE_QUERY_ADVIN,   //AT+ADVIN
    CFG_MODULE_QUERY_TXPOWER, //AT+TXPOWER
    CFG_MODULE_QUERY_GSCFG,   //AT+GSCFG
    CFG_MODULE_QUERY_KEYCFG,  //AT+KEYCFG
    CFG_MODULE_SND_BUZ,       //AT+BUZ=
    CFG_MODULE_SND_IBCCFG,    //AT+BADVDATA(beacon)
    CFG_MODULE_SND_EDSEN,     //AT+BADVDATA(url)
    CFG_MODULE_SND_EDSCFG,    //AT+BADVDATA(uid)
    CFG_MODULE_SND_ABCCFG,    //AT+BADVDATA(altBeacon)
    CFG_MODULE_SND_CFGMODE,   //AT+BWMODE
    CFG_MODULE_SND_ADVIN,     //AT+ADVIN=
    CFG_MODULE_SND_NAME,      //AT+NAME
    CFG_MODULE_SND_LENAME,    //AT+LENAME
    CFG_MODULE_SND_PIN,       //AT+PIN
    CFG_MODULE_SND_TLM,       //AT+TLM=
    CFG_MODULE_SND_TXPOWER,   //AT+TXPOWER=
//    CFG_MODULE_SND_LED,       //AT+LED=
    CFG_MODULE_SND_KEYCFG,    //AT+KEYCFG=
    CFG_MODULE_SND_GSCFG,     //AT+GSCFG=
    CFG_MODULE_QUERY_NAME,    //AT+NAME
    CFG_MODULE_QUERY_PIN,     //AT+PIN
    CFG_MODULE_QUERY_TLM,     //AT+TLM
    CFG_MODULE_COMPLETE,
    CFG_MODULE_END
} CONFIG_MODULE_STATE_T;

@interface FWParametersViewController () <CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate,CBCentralManagerDelegate, CLLocationManagerDelegate, UINavigationBarDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate>{
    FWDevice *_device;
    CBCentralManager *mCentralManager;
    CBPeripheral *mConnectedPeripheral;
    CBManager *configureManager;
    FWPeripheralWrapper *mPeripheralWrapper;
    CBCharacteristic *mNotifingCharacteristic;
    CBCharacteristic *mTransferCharacteristic;
    NSMutableData *mRespCachedData;
    NSMutableData *mRecvData;
    UIButton *deleteBtn;
    UIButton *_upgradeButton;
    
    // process air cmd.
    bool fscAirCmdOpened;
    BT_RCV_STATE_T btRcvState;
    CONFIG_MODULE_STATE_T btCfgState;
    
    NSTimer *_queryTimeoutTimer;
    NSTimer *_saveTimeoutTimer;
    NSTimer *_responseTimeoutTimer;
    
    NSMutableArray *_parameterNames;
    NSMutableArray *_parameterValues;
    NSMutableArray *sectionArrayM;
    // 广播数组
    NSArray *iBeaconArray;
    NSArray *urlArray;
    NSArray *uidArray;
    NSArray *altBeaconArray;
    
    NSMutableArray *deleteArrayM;
    
    int index;
    NSString *addressStr;
    BOOL isSend;
    BOOL firstOpen;
    BOOL isQuery;
    BOOL shouldQuery;
    BOOL shouldQueryName;
    BOOL shouldQueryPin;
    BOOL shouldQueryTLM;
    BOOL shouldQueryAdvin;
    BOOL _shouldSendOpenCommand;
    NSMutableString *_receivedString;
    
    NSString *nameString;
    NSString *intervalString;
    NSString *uuidString;
    NSString *majorString;
    NSString *minorString;
    NSString *beanconPowerString;
    NSString *urlString;
    NSString *urlPowerString;
    NSString *namespaceString;
    NSString *instanceString;
    NSString *reservedString;
    NSString *uidPowerString;
    
    NSMutableArray *equipmentDataArray;
    NSMutableArray *sectionNumberArrM;
    NSMutableArray *urlSectionNumberArrM;
    NSMutableArray *uidSectionNumberArrM;
    NSMutableArray *altBeaconSectionNumberArrM;
    // pin密码
    NSString *pwdString;
    UIActivityIndicatorView * activityIndicator;
    CBCharacteristic *readCharacteristic;
    BOOL openSuccessful;
    BOOL isDisconnected;
    NSString *versionString;
    BOOL shouldRect;
    NSMutableArray *uuidStringArrM;
    UIButton *_addBeaconButton;
    NSData *pwdData;
    NSString *string_random;
    NSString *string_pinData;
    BOOL isRandom;
    BOOL isclick;
    NSInteger commandsCount;
    BOOL shouldTxPower;
//    NSMutableArray *ibeaconBroadcasts;
//    NSMutableArray *eddystoneUrlBroadcasts;
//    NSMutableArray *eddystoneUidBroadcasts;
//    NSMutableArray *altBeaconBroadcasts;
    BOOL _hasKey;
    BOOL _hasGsensor;
    BOOL shouldLED;
    BOOL shouldBUZ;
    BOOL shouldGSSFG;
    BOOL shouldKEYCFG;
    BOOL shouldShow;
    BOOL keyboardState;
    BOOL canDisconnect;
    BOOL _disconnectInitiative;
    BOOL _timeout;
    
    UITextField *_intervalTextField;
    UITextField *_keyIntervalTextField;
    UITextField *_keyDurationTextField;
    UITextField *_gsensorIntervalTextField;
    UITextField *_gsensorDurationTextField;
    UITextField *_gsensorSensitivityTextField;
}

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, assign) int rect;
@property (nonatomic, assign) CGRect frame_first;
@property (nonatomic, assign) CGAffineTransform transform;
@property (nonatomic, assign) BOOL pwdError;
@property (nonatomic, assign) BOOL shouldDisconnect;
@property (nonatomic, strong) NSMutableArray *UUIDArrayM;
@property (nonatomic, assign) BOOL isSave;
@property (nonatomic, assign) BOOL hasTxPower;
@property (nonatomic, copy) NSString *txPowerString;
@property (nonatomic, strong) NSIndexPath *indexPath_save;
@property (nonatomic, assign) BOOL isExtend;
@property (nonatomic, strong) NSArray *intervalArray;

@end

@implementation FWParametersViewController

#define NELEM(a) (sizeof(a)/sizeof((a)[0]))
// interval(UI显示)
static const int BROADCAST_LED_MS[] = {
    0, 100, 150, 200, 300, 400, 550, 750, 850, 1000, 1300, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000
};

static const int BROADCAST_INTERVAL_MS[] = {
    100, 150, 200, 300, 400, 550, 750, 850, 1000, 1300, 2000
};

static const int BROADCAST_INTERVAL_MS_BP108N[] = {
    0, 100, 150, 200, 300, 400, 550, 750, 850, 1000, 1300, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000
};

// gsensor和key的广播间隔(UI显示)
static const int BROADCAST_STATE_MS[] = {
    0, 100, 150, 200, 300, 400, 550, 750, 850, 1000, 1300, 2000
};

// gsensor和key的广播间隔(发送给模块)
static const int BROADCAST_INTERVAL_SEND[] = {
    0, 100, 152, 211, 318, 417, 546, 760, 852, 1022, 1285, 2000 //, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000
};

// interval(发送给模块)
static const int BROADCAST_STATE_SEND[] = {
    0, 100, 152, 211, 318, 417, 546, 760, 852, 1022, 1285, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000
};

//static const int BROADCAST_INTERVAL_REVICE[] = {
//    0, 100, 200, 300, 400, 500, 600, 800, 900, 1100, 1300, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000
//};

static const int BROADCAST_GSENSOR_REVICE[] = {
    1000, 3000, 3500, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 60000
};

static const int BROADCAST_KEY_REVICE[] = {
    1000, 5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 60000
};

#if 0
static inline NSString *getIntervalLabel(int index) {
    char str[16];
    sprintf(str, "%dms", BROADCAST_INTERVAL_MS[index]);
    return [[NSString alloc] initWithUTF8String: str];
}
#endif

- (id)initWithPeripheral:(CBPeripheral *)peripheral centralManager:(CBCentralManager *)centralManager peripheralWrapper:(FWPeripheralWrapper *)peripheralWrapper pinString:(NSString *)pinString randomString:(NSString *)randomString pinData:(NSData *)pinData
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        if ([pinString isEqualToString:@"00000000"]) {
            pinString = @"0000";
        }
        if (pinString.length < 6 && pinString) {
            for (int i = 0; i < 8 - pinString.length; i++) {
                pinString = [@"0" stringByAppendingString:pinString];
                if (pinString.length >= 8) {
                    break;
                }
            }
        }
        [self setTitle:LS(@"Parameter Settings")];
        [self setHidesBottomBarWhenPushed:YES];
        
        pwdString = pinString;
        pwdData = pinData;
        string_random = randomString;
        mCentralManager = centralManager;
        mCentralManager.delegate = self;
        mConnectedPeripheral = peripheral;
        mPeripheralWrapper = peripheralWrapper;
        mRespCachedData = [[NSMutableData alloc]init];
        mRecvData = [[NSMutableData alloc]init];
        btCfgState = CFG_MODULE_COMPLETE;
        fscAirCmdOpened = FALSE;
        shouldQuery = false;
        shouldLED = false;
        shouldBUZ = false;
        shouldGSSFG = false;
        shouldKEYCFG = false;
        isSend = false;
        isRandom = YES;
        self.pwdError = NO;
        self.shouldDisconnect = YES;
        string_pinData = @"";
        self.isSave = NO;
        self.isExtend = NO;
        shouldShow = YES;
        keyboardState = NO;
        canDisconnect = NO;
        
        _receivedString = [[NSMutableString alloc] initWithCapacity:4096];
        
        mPeripheralWrapper.name = peripheralWrapper.name;
        equipmentDataArray = [[NSMutableArray alloc] init];
//        ibeaconBroadcasts = [[NSMutableArray alloc] init];
//        eddystoneUrlBroadcasts = [[NSMutableArray alloc] init];
//        eddystoneUidBroadcasts = [[NSMutableArray alloc] init];
//        altBeaconBroadcasts = [[NSMutableArray alloc] init];
        
        sectionNumberArrM = [[NSMutableArray alloc] init];
        urlSectionNumberArrM = [[NSMutableArray alloc] init];
        uidSectionNumberArrM = [[NSMutableArray alloc] init];
        altBeaconSectionNumberArrM = [[NSMutableArray alloc] init];
        self.UUIDArrayM = [[NSMutableArray alloc] init];
        
        _parameterNames = [[NSMutableArray alloc] initWithObjects:LS(@"Model:"), LS(@"Version:"), LS(@"Name:"), LS(@"Interval(ms):"), @"TLM:", nil];
        _parameterValues = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"",@NO, nil];
        iBeaconArray = @[@"UUID:",@"Major:",@"Minor:",@"RSSI at 1m:",@"Enabled:"];
        urlArray = @[@"URL:",@"RSSI at 0m:",@"Enabled:"];
        uidArray = @[@"Namespace:",@"Instance:",@"Reserved:",@"RSSI at 0m:",@"Enabled:"];
        altBeaconArray = @[@"ID1:",@"ID2:",@"ID3:",@"RSSI at 0m:",@"Manufacturer ID:",@"Manufacturer Reserved:",@"Enabled:"];
        self.intervalArray = @[@"0", @"100",@"150",@"200",@"300",@"400",@"550",@"750",@"850",@"1000",@"1300",@"2000"];
    }
    return self;
}

- (void)updateDevice:(FWDevice * _Nullable)device feature:(const UInt8)feature {
    if (device) {
        _device = device;
        _parameterValues[0] = _device.modelName;
        _hasTxPower = 0 < _device.txPowers.count;
        
        if (_hasTxPower) {
            [_parameterNames addObject:@"TxPower(dB):"];
            [_parameterValues addObject:@""];
        }
        
        if (feature & 0b01000000) {
            _hasGsensor = YES;
            [_parameterNames addObject:@"Gsensor(ms):"];
            if ([[_device modelName] isEqualToString:@"BP108N"]) {
                [_parameterValues addObject:[@[@"", @"", @""] mutableCopy]];
            } else {
                [_parameterValues addObject:[@[@"", @""] mutableCopy]];
            }
        }
        
        if (feature & 0b10000000) {
            _hasKey = YES;
            [_parameterNames addObject:@"Key(ms):"];
            [_parameterValues addObject:[@[@"", @""] mutableCopy]];
        }
        
        [self.tableView reloadData];
        
        [self sendOpenCommandIfPossible];
    } else {
        [self stopAllTimers];
        [_progressHUD hideAnimated:YES];
        [self showAlertControllerAndPopWithTitle:LS(@"Query parameters failed")];
    }
}

- (void)loadData {

    NSLog(@"uuid : %@, name : %@, rssi : %ld, data : %@",mPeripheralWrapper.UUIDString,mPeripheralWrapper.name,(long)mPeripheralWrapper.RSSI,mPeripheralWrapper.rawAdvertisementData);

    [_parameterValues replaceObjectAtIndex:2 withObject:mPeripheralWrapper.name];
    
    NSDictionary *dict = [mPeripheralWrapper.rawAdvertisementData valueForKey:@"kCBAdvDataServiceData"];
    NSData *data = [dict objectForKey:[CBUUID UUIDWithString:@"FFF0"]];
    
    NSLog(@"dict: \n%@", dict);
    NSLog(@"DATA: %@", data);
    NSLog(@"DATA_LENGTH: %d", (int)data.length);
    
    NSString *str = [self fan_dataToHexString:data];
    const NSUInteger strLength = str.length;
    
    NSLog(@"str:\n%@",str);
    if (0 < strLength) {
        if (14 == strLength) {
            NSLog(@"旧版本");
            NSString *versionStr = [str substringWithRange:NSMakeRange(0, 4)];
            NSString *enableStr = [str substringWithRange:NSMakeRange(4, 2)];
            versionStr = [NSString stringWithFormat:@"%ld",strtoul([versionStr UTF8String],0,16)];
            versionString = versionStr;
            NSInteger one = [versionStr integerValue]/100;
            NSInteger two = [versionStr integerValue]%100/10;
            NSInteger three = [versionStr integerValue]%10;
            NSString *version = [NSString stringWithFormat:@"V%ld.%ld.%ld",(long)one,(long)two,(long)three];
            [_parameterValues replaceObjectAtIndex:1 withObject:version];
            [_parameterValues replaceObjectAtIndex:4 withObject:enableStr];
        } else {
            NSString *modelStr = [str substringWithRange:NSMakeRange(0, 2)];
            NSString *versionStr = [str substringWithRange:NSMakeRange(2, 4)];
            NSString *enableStr = [str substringWithRange:NSMakeRange(6, 2)];
            const int modelValue = (int)strtoul([modelStr UTF8String], 0, 16);
            
            NSLog(@"modelValue: %d", modelValue);
            
            [_parameterValues replaceObjectAtIndex:4 withObject:enableStr];
            
            NSLog(@"%@,%@",versionStr,enableStr);
            
            versionStr = [NSString stringWithFormat:@"%ld",strtoul([versionStr UTF8String],0,16)];
            versionString = versionStr;
            NSInteger one = [versionStr integerValue]/100;
            NSInteger two = [versionStr integerValue]%100/10;
            NSInteger three = [versionStr integerValue]%10;
            
            NSString *version = [NSString stringWithFormat:@"V%ld.%ld.%ld",(long)one,(long)two,(long)three];
            mPeripheralWrapper.version = version;
            
            [_parameterValues replaceObjectAtIndex:1 withObject:version];
            
            if (pwdString) {
                [_parameterNames addObject:@"Pin:"];
                [_parameterValues addObject:pwdString];
            }
            
            const Byte *bytes = (const Byte *)[data bytes];
            const Byte feature = bytes[3];
            
            NSLog(@"feature: %02x", feature);
            
            __weak __typeof(self) weakSelf = self;
            
            [[FWDeviceManager sharedManager] queryDeviceForValue:modelValue completionHandler:^(FWDevice * _Nullable device) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                
                [strongSelf updateDevice:device feature:feature];
            }];
        }
        
        [self showProgressHUDWithTitle:LS(@"Loading...")];
        
        _queryTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(queryParametersTimeout) userInfo:nil repeats:NO];
        mCentralManager.delegate = self;
        [mConnectedPeripheral setDelegate:self];
        [mCentralManager connectPeripheral:mConnectedPeripheral options:nil];
    }
}

-(void)createTableView{
    const CGRect bounds = [[UIScreen mainScreen] bounds];
    UITableView *tableView = self.tableView;
    
    tableView.frame = bounds;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.sectionHeaderHeight = 0;
    tableView.sectionFooterHeight = 0;
    
    tableView.tableHeaderView =  [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, bounds.size.width, CGFLOAT_MIN)];

    // 添加footView
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 200)];

    // 添加eddystone的按钮
    _addBeaconButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width - 20 - 150, 20, 150, 50)];
    [_addBeaconButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [_addBeaconButton addTarget:self action:@selector(clickToAddibeacon:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:_addBeaconButton];
    
    _upgradeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_upgradeButton setFrame:CGRectMake((bounds.size.width - 240) * 0.5, 120, 240, 50)];
    [_upgradeButton setBackgroundColor:[UIColor colorWithRed:88/255.0 green:133/255.0 blue:222/255.0 alpha:1]];
    [_upgradeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_upgradeButton setTitle:LS(@"Upgrade") forState:UIControlStateNormal];
    [_upgradeButton addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:_upgradeButton];
    
    tableView.tableFooterView = footerView;
}


- (void)addRightBtn {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Save") style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonClicked)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)update {
    [self disconnect];
    
    FWUpdateViewController *viewController = [[FWUpdateViewController alloc] initWithPeripheral:mConnectedPeripheral centralManager:mCentralManager peripheralWrapper:mPeripheralWrapper randomString:string_random pwdData:pwdData modelName:[_device modelName]];
    
    viewController.advertisementData = _advertisementData;
    
    NSMutableArray *viewControllers = [[[self navigationController] viewControllers] mutableCopy];
    
    [viewControllers replaceObjectAtIndex:1 withObject:viewController];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark - textField check
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIView *v = [textField superview];//获取父类view
    UITableViewCell *cell = (UITableViewCell *)[v superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];//获取cell对应的section
    NSLog(@"%@",cell);
    CGFloat rect1 = self.view.frame.size.height - (cell.frame.size.height + cell.frame.origin.y);
    self.rect = abs((int)rect1);
    self.indexPath_save = indexPath;
    
}

// 结束编辑时保存最终文本
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *text = textField.text;
    NSLog(@"texttext: %@", text);
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (0 < self.indexPath_save.section) {
        if (!keyboardState) {
            [[equipmentDataArray[self.indexPath_save.section - 1] lastObject] replaceObjectAtIndex:self.indexPath_save.row withObject:text];
        } else {
            keyboardState = NO;
        }
    }
}

- (void)updateTextColors {
    UIColor *darkTextColor = [UIColor darkTextColor];
    UIColor *redColor = [UIColor redColor];
    
    [_intervalTextField setTextColor:darkTextColor];
    [_keyIntervalTextField setTextColor:darkTextColor];
    [_keyDurationTextField setTextColor:darkTextColor];
    [_gsensorIntervalTextField setTextColor:darkTextColor];
    [_gsensorDurationTextField setTextColor:darkTextColor];
    [_gsensorSensitivityTextField setTextColor:darkTextColor];
    
    const NSInteger parameterCount = _parameterValues.count;
    
    int interval = [_parameterValues[3] intValue];
    int keyInterval = 0;
    int keyDuration = 0;
    int gsensorInterval = 0;
    int gsensorDuration = 0;
    int gsensorSensitivity = 0;
    
    NSLog(@"_parameterValues: %@", _parameterValues);
    
    if (_hasGsensor) {
        if (_hasKey) {
            keyInterval = [_parameterValues[parameterCount - 1][0] intValue];
            keyDuration = [_parameterValues[parameterCount - 1][1] intValue];
            gsensorInterval = [_parameterValues[parameterCount - 2][0] intValue];
            gsensorDuration = [_parameterValues[parameterCount - 2][1] intValue];
            
            if ([_device.modelName isEqualToString:@"BP108N"]) {
                gsensorSensitivity = [_parameterValues[parameterCount - 2][2] intValue];
            }
            
            int count = 0;
            
            if (100 <= interval && interval <= 2000) {
                count ++;
            }
            if (100 <= keyInterval && keyInterval <= 2000) {
                count ++;
            }
            if (100 <= gsensorInterval && gsensorInterval <= 2000) {
                count ++;
            }
            
            if (0 == count) {
                [_intervalTextField setTextColor:redColor];
                [_keyIntervalTextField setTextColor:redColor];
                [_gsensorIntervalTextField setTextColor:redColor];
            }
        } else {
            gsensorInterval = [_parameterValues[parameterCount - 1][0] intValue];
            gsensorDuration = [_parameterValues[parameterCount - 1][1] intValue];
            
            if ([_device.modelName isEqualToString:@"BP108N"]) {
                gsensorSensitivity = [_parameterValues[parameterCount - 1][2] intValue];
            }
            
            
            int count = 0;
            
            if (100 <= interval && interval <= 2000) {
                count ++;
            }
            if (100 <= gsensorInterval && gsensorInterval <= 2000) {
                count ++;
            }
            
            if (0 == count) {
                [_intervalTextField setTextColor:redColor];
                [_gsensorIntervalTextField setTextColor:redColor];
            }
            
        }
    } else {
        if (_hasKey) {
            keyInterval = [_parameterValues[parameterCount - 1][0] intValue];
            keyDuration = [_parameterValues[parameterCount - 1][1] intValue];
            
            int count = 0;
            
            if (100 <= interval && interval <= 2000) {
                count ++;
            }
            if (100 <= keyInterval && keyInterval <= 2000) {
                count ++;
            }
            
            if (0 == count) {
                [_intervalTextField setTextColor:redColor];
                [_keyIntervalTextField setTextColor:redColor];
            }
        } else {
            int count = 0;
            
            if (100 <= interval && interval <= 2000) {
                count ++;
            }
            
            if (0 == count) {
                [_intervalTextField setTextColor:redColor];
            }
        }
    }
    
    FWRange *intervalRange = _device.intervalRange;
    
    if (intervalRange) {
        if (0 != interval && (interval < intervalRange.minValue || interval > intervalRange.maxValue)) {
            [_intervalTextField setTextColor:redColor];
        }
    }
    
    FWRange *gsensorIntervalRange = _device.gsensorIntervalRange;
    
    if (gsensorIntervalRange) {
        if (0 != gsensorInterval && (gsensorInterval < gsensorIntervalRange.minValue || gsensorInterval > gsensorIntervalRange.maxValue)) {
            [_gsensorIntervalTextField setTextColor:redColor];
        }
    }
    
    FWRange *gsensorDurationRange = _device.gsensorDurationRange;
    
    if (gsensorDurationRange) {
        if (gsensorDuration < gsensorDurationRange.minValue || gsensorDuration > gsensorDurationRange.maxValue) {
            [_gsensorDurationTextField setTextColor:redColor];
        }
    }
    
    FWRange *gsensorSensitivityRange = _device.gsensorSensitivityRange;
    
    if (gsensorSensitivityRange) {
        if (gsensorSensitivity < gsensorSensitivityRange.minValue || gsensorSensitivity > gsensorSensitivityRange.maxValue) {
            [_gsensorSensitivityTextField setTextColor:redColor];
        }
    }
    
    FWRange *keyIntervalRange = _device.keyIntervalRange;
    
    if (keyIntervalRange) {
        if (0 != keyInterval && (keyInterval < keyIntervalRange.minValue || keyInterval > keyIntervalRange.maxValue)) {
            [_keyIntervalTextField setTextColor:redColor];
        }
    }
    
    FWRange *keyDurationRange = _device.keyDurationRange;
    
    if (keyDurationRange) {
        if (keyDuration < keyDurationRange.minValue || keyDuration > keyDurationRange.maxValue) {
            [_keyDurationTextField setTextColor:redColor];
        }
    }
}

- (BOOL)checkIntervalStates {
    const NSInteger parameterCount = _parameterValues.count;
    const int interval = [_parameterValues[3] intValue];
    
    if (_hasGsensor) {
        if (_hasKey) {
            const int keyInterval = [_parameterValues[parameterCount - 1][0] intValue];
            const int gsensorInterval = [_parameterValues[parameterCount - 2][0] intValue];
            int count = 0;
            
            if (100 <= interval && interval <= 2000) {
                count ++;
            }
            if (100 <= keyInterval && keyInterval <= 2000) {
                count ++;
            }
            if (100 <= gsensorInterval && gsensorInterval <= 2000) {
                count ++;
            }
            
            if (0 == count) {
                return NO;
            }
        } else {
            const int gsensorInterval = [_parameterValues[parameterCount - 1][0] intValue];
            int count = 0;
            
            if (100 <= interval && interval <= 2000) {
                count ++;
            }
            if (100 <= gsensorInterval && gsensorInterval <= 2000) {
                count ++;
            }
            
            if (0 == count) {
                return NO;
            }
            
        }
    } else {
        if (_hasKey) {
            const int keyInterval = [_parameterValues[parameterCount - 1][0] intValue];
            int count = 0;
            
            if (100 <= interval && interval <= 2000) {
                count ++;
            }
            if (100 <= keyInterval && keyInterval <= 2000) {
                count ++;
            }
            
            if (0 == count) {
                return NO;
            }
        } else {
            int count = 0;
            
            if (100 <= interval && interval <= 2000) {
                count ++;
            }
            
            if (0 == count) {
                return NO;
            }
        }
    }
    return YES;
}

//输入检测
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"text: %@ --- string: %@",textField.text,string);
    
    if (textField == _intervalTextField || textField == _keyIntervalTextField || textField == _keyDurationTextField || textField == _gsensorIntervalTextField || textField == _gsensorIntervalTextField || textField == _gsensorDurationTextField || textField == _gsensorSensitivityTextField) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        const NSInteger parameterCount = _parameterValues.count;
        
        if (textField == _intervalTextField) {
            _parameterValues[3] = newString;
        } else if (textField == _keyIntervalTextField) {
            _parameterValues[parameterCount - 1][0] = newString;
        } else if (textField == _keyDurationTextField) {
            _parameterValues[parameterCount - 1][1] = newString;
        } else if (textField == _gsensorIntervalTextField) {
            if (_hasKey) {
                _parameterValues[parameterCount - 2][0] = newString;
            } else {
                _parameterValues[parameterCount - 1][0] = newString;
            }
        } else if (textField == _gsensorDurationTextField) {
            if (_hasKey) {
                _parameterValues[parameterCount - 2][1] = newString;
            } else {
                _parameterValues[parameterCount - 1][1] = newString;
            }
        } else if (textField == _gsensorSensitivityTextField) {
            if (_hasKey) {
                _parameterValues[parameterCount - 2][2] = newString;
            } else {
                _parameterValues[parameterCount - 1][2] = newString;
            }
        }
        
        [self updateTextColors];
        
        NSLog(@"_parameterValues: %@", _parameterValues);
        
        return YES;
    }
    
    // 编写正则表达式
    NSString *regular = @"^[\\u4e00-\\u9fa5]+$";
    // 创建谓词对象并设定条件的表达式
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    // 对字符串判断，该方法会返回BOOL值
    if ([numberPre evaluateWithObject:string]) {
        return NO;
    }
    UIView *v = [textField superview];//获取父类view
    FWConfigureFourCell *cell = (FWConfigureFourCell *)[v superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];//获取cell对应的section
    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;
    
    if (section == 0) {
        if (row == 2) {
            /*
            NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
            const NSInteger newLength = newText.length;
            
            if (0 == newLength) {
                return YES;
            } else if (0 == string.length) {
                return YES;
            }
            
            NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"[A-Za-z0-9_-]+" options:0 error:NULL];
            const NSRange matchedRange = { 0, string.length };
            NSTextCheckingResult *result = [regularExpression firstMatchInString:string options:0 range:matchedRange];
            const NSRange resultRange = result.range;
            
            if (0 == resultRange.location && string.length == resultRange.length) {
                return YES;
            }
            
            return NO;
             */
            return YES;
            
        } else if (row == 3) {
            if ([textField.text integerValue]*10 >= 2000) {
                if ([string isEqualToString:@""]) {
                    return YES;
                }
                if ([textField.text isEqualToString:@"200"] && [string isEqualToString:@"0"]) {
                    return YES;
                }
                return NO;
            } else {
                return YES;
            }
        } else if (row == 5 && pwdString) {
            NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
            const NSInteger newLength = newText.length;
            
            cell.inputTextField.textColor = [UIColor darkGrayColor];
            
            if (newLength != 6) {
                cell.inputTextField.textColor = [UIColor redColor];
            } else if (![newText isNumbers]) {
                cell.inputTextField.textColor = [UIColor redColor];
            }
            
            _parameterValues[5] = newText;
            
            return YES;
        }
    } else {
        if ([equipmentDataArray[section - 1][1] isEqualToString:@"iBeacon"]) {
            if (row == 0) {
                if (![self isHexString:string] && string.length < 2) {
                    return NO;
                }
                if (range.length + range.location > textField.text.length) {
                    return NO;
                }
                NSUInteger length = textField.text.length + string.length - range.length;
                if (length < 32) {
                    cell.textLabel.textColor = [UIColor redColor];
                    cell.inputTextField.textColor = [UIColor redColor];
                } else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.inputTextField.textColor = [UIColor darkGrayColor];
                }
                return length <= 32;
            } else if (row == 1) { // major -> 0 ~ 65535
                if (![self isNumberString:string]) {
                    return NO;
                }
                if ([textField.text integerValue]*10+[string integerValue] >= 65535) {
                    if ([string isEqualToString:@""]) {
                        return YES;
                    }
                    if ([textField.text isEqualToString:@"6553"] && [string isEqualToString:@"5"]) {
                        return YES;
                    }
                    return NO;
                } else {
                    NSUInteger length = textField.text.length + string.length - range.length;
                    return length <= 5;
//                    return YES;
                }
            } else if (row == 2) { // minor -> 0 ~ 65535
                if (![self isNumberString:string]) {
                    return NO;
                }
                if ([textField.text integerValue]*10+[string integerValue] >= 65535) {
                    if ([string isEqualToString:@""]) {
                        return YES;
                    }
                    if ([textField.text isEqualToString:@"6553"] && [string isEqualToString:@"5"]) {
                        return YES;
                    }
                    return NO;
                } else {
                    NSUInteger length = textField.text.length + string.length - range.length;
                    return length <= 5;
//                    return YES;
                }
            } else if (row == 3) {
                BOOL first;
                if ([textField.text hasPrefix:@"-"]) {
                    first = YES;
                } else {
                    first = NO;
                }
                if (![self isNumberString:string] && (first?YES:![string hasPrefix:@"-"])) {
                    return NO;
                }
                if ([textField.text integerValue]*10+[string integerValue] >= 127 || [textField.text integerValue]*10-[string integerValue] <= -128) {
                    if ([string isEqualToString:@""]) {
                        return YES;
                    }
                    if (([textField.text isEqualToString:@"12"] && [string isEqualToString:@"7"]) || ([textField.text isEqualToString:@"-12"] && [string isEqualToString:@"8"])) {
                        return YES;
                    }
                    return NO;
                } else {
                    NSUInteger length = textField.text.length + string.length - range.length;
                    return length <= 4;
//                    return YES;
                }
            }
        } else if ([equipmentDataArray[section - 1][1] isEqualToString:@"URL"]) {
            if (row == 1) {
                BOOL first;
                if ([textField.text hasPrefix:@"-"]) {
                    first = YES;
                } else {
                    first = NO;
                }
                if (![self isNumberString:string] && (first?YES:![string hasPrefix:@"-"])) {
                    return NO;
                }
                if ([textField.text integerValue]*10+[string integerValue] >= 127 || [textField.text integerValue]*10-[string integerValue] <= -128) {
                    if ([string isEqualToString:@""]) {
                        return YES;
                    }
                    if (([textField.text isEqualToString:@"12"] && [string isEqualToString:@"7"]) || ([textField.text isEqualToString:@"-12"] && [string isEqualToString:@"8"])) {
                        return YES;
                    }
                    return NO;
                } else {
                    NSUInteger length = textField.text.length + string.length - range.length;
                    return length <= 4;
//                    return YES;
                }
            }
        } else if ([equipmentDataArray[section - 1][1] isEqualToString:@"UID"]) {
            if (row == 0) {
                if (![self isHexString:string] && string.length < 2) {
                    return NO;
                }
                if (range.length + range.location > textField.text.length) {
                    return NO;
                }
                NSUInteger length = textField.text.length + string.length - range.length;
                if (length < 20) {
                    cell.textLabel.textColor = [UIColor redColor];
                    cell.inputTextField.textColor = [UIColor redColor];
                } else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.inputTextField.textColor = [UIColor darkGrayColor];
                }
                return length <= 20;
            } else if (row == 1) {
                if (![self isHexString:string] && string.length < 2) {
                    return NO;
                }
                if (range.length + range.location > textField.text.length) {
                    return NO;
                }
                NSUInteger length = textField.text.length + string.length - range.length;
                if (length < 12) {
                    cell.textLabel.textColor = [UIColor redColor];
                    cell.inputTextField.textColor = [UIColor redColor];
                } else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.inputTextField.textColor = [UIColor darkGrayColor];
                }
                return length <= 12;
            } else if (row == 2) {
                if (![self isHexString:string] && string.length < 2) {
                    return NO;
                }
                if (range.length + range.location > textField.text.length) {
                    return NO;
                }
                NSUInteger length = textField.text.length + string.length - range.length;
                if (length < 4) {
                    cell.textLabel.textColor = [UIColor redColor];
                    cell.inputTextField.textColor = [UIColor redColor];
                } else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.inputTextField.textColor = [UIColor darkGrayColor];
                }
                return length <= 4;
            } else if (row == 3) {
                BOOL first;
                if ([textField.text hasPrefix:@"-"]) {
                    first = YES;
                } else {
                    first = NO;
                }
                if (![self isNumberString:string] && (first?YES:![string hasPrefix:@"-"])) {
                    return NO;
                }
                if ([textField.text integerValue]*10+[string integerValue] >= 127 || [textField.text integerValue]*10-[string integerValue] <= -128) {
                    if ([string isEqualToString:@""]) {
                        return YES;
                    }
                    if (([textField.text isEqualToString:@"12"] && [string isEqualToString:@"7"]) || ([textField.text isEqualToString:@"-12"] && [string isEqualToString:@"8"])) {
                        return YES;
                    }
                    return NO;
                } else {
                    NSUInteger length = textField.text.length + string.length - range.length;
                    return length <= 4;
//                    return YES;
                }
            }
        } else if ([equipmentDataArray[section - 1][1] isEqualToString:@"AltBeacon"]) {
            if (row == 0) {
                if (![self isHexString:string] && string.length < 2) {
                    return NO;
                }
                if (range.length + range.location > textField.text.length) {
                    return NO;
                }
                NSUInteger length = textField.text.length + string.length - range.length;
                if (length < 32) {
                    cell.textLabel.textColor = [UIColor redColor];
                    cell.inputTextField.textColor = [UIColor redColor];
                } else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.inputTextField.textColor = [UIColor darkGrayColor];
                }
                return length <= 32;
            } else if (row == 1) {
                if (![self isHexString:string] && string.length < 2) {
                    return NO;
                }
                if (range.length + range.location > textField.text.length) {
                    return NO;
                }
                NSUInteger length = textField.text.length + string.length - range.length;
                return length <= 4;
            } else if (row == 2) {
                if (![self isHexString:string] && string.length < 2) {
                    return NO;
                }
                if (range.length + range.location > textField.text.length) {
                    return NO;
                }
                NSUInteger length = textField.text.length + string.length - range.length;
                return length <= 4;
            } else if (row == 3) {
                BOOL first;
                if ([textField.text hasPrefix:@"-"]) {
                    first = YES;
                } else {
                    first = NO;
                }
                if (![self isNumberString:string] && (first?YES:![string hasPrefix:@"-"])) {
                    return NO;
                }
                if ([textField.text integerValue]*10+[string integerValue] >= 127 || [textField.text integerValue]*10-[string integerValue] <= -128) {
                    if ([string isEqualToString:@""]) {
                        return YES;
                    }
                    if (([textField.text isEqualToString:@"12"] && [string isEqualToString:@"7"]) || ([textField.text isEqualToString:@"-12"] && [string isEqualToString:@"8"])) {
                        return YES;
                    }
                    return NO;
                } else {
                    NSUInteger length = textField.text.length + string.length - range.length;
                    return length <= 4;
//                    return YES;
                }
            } else if (row == 5) {
                if (![self isNumberString:string]) {
                    return NO;
                }
                if ([textField.text integerValue]*10+[string integerValue] >= 65535) {
                    if ([string isEqualToString:@""]) {
                        return YES;
                    }
                    if ([textField.text isEqualToString:@"6553"] && [string isEqualToString:@"5"]) {
                        return YES;
                    }
                    return NO;
                } else {
                    NSUInteger length = textField.text.length + string.length - range.length;
                    return length <= 5;
//                    return YES;
                }
            } else if (row == 6) {
                if (![self isHexString:string] && string.length < 2) {
                    return NO;
                }
                if (range.length + range.location > textField.text.length) {
                    return NO;
                }
                NSUInteger length = textField.text.length + string.length - range.length;
                if (length < 2) {
                    cell.textLabel.textColor = [UIColor redColor];
                    cell.inputTextField.textColor = [UIColor redColor];
                } else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.inputTextField.textColor = [UIColor darkGrayColor];
                }
                return length <= 2;
            }
        }
    }
    return YES;
}
//检查输入的是否为16进制
- (BOOL)isHexString:(NSString *)string {
    if ([string isEqualToString:@"A"]) {
        return YES;
    } else if ([string isEqualToString:@"B"]) {
        return YES;
    } else if ([string isEqualToString:@"C"]) {
        return YES;
    } else if ([string isEqualToString:@"D"]) {
        return YES;
    } else if ([string isEqualToString:@"E"]) {
        return YES;
    } else if ([string isEqualToString:@"F"]) {
        return YES;
    } else if ([string isEqualToString:@"a"]) {
        return YES;
    } else if ([string isEqualToString:@"b"]) {
        return YES;
    } else if ([string isEqualToString:@"c"]) {
        return YES;
    } else if ([string isEqualToString:@"d"]) {
        return YES;
    } else if ([string isEqualToString:@"e"]) {
        return YES;
    } else if ([string isEqualToString:@"f"]) {
        return YES;
    } else if ([string isEqualToString:@"0"]) {
        return YES;
    } else if ([string isEqualToString:@"1"]) {
        return YES;
    } else if ([string isEqualToString:@"2"]) {
        return YES;
    } else if ([string isEqualToString:@"3"]) {
        return YES;
    } else if ([string isEqualToString:@"4"]) {
        return YES;
    } else if ([string isEqualToString:@"5"]) {
        return YES;
    } else if ([string isEqualToString:@"6"]) {
        return YES;
    } else if ([string isEqualToString:@"7"]) {
        return YES;
    } else if ([string isEqualToString:@"8"]) {
        return YES;
    } else if ([string isEqualToString:@"9"]) {
        return YES;
    } else if ([string isEqualToString:@""]){
        return YES;
    } else {
        return NO;
    }
}
//检查输入的是否为数字
- (BOOL)isNumberString:(NSString *)string {
    if ([string isEqualToString:@"0"]) {
        return YES;
    } else if ([string isEqualToString:@"1"]) {
        return YES;
    } else if ([string isEqualToString:@"2"]) {
        return YES;
    } else if ([string isEqualToString:@"3"]) {
        return YES;
    } else if ([string isEqualToString:@"4"]) {
        return YES;
    } else if ([string isEqualToString:@"5"]) {
        return YES;
    } else if ([string isEqualToString:@"6"]) {
        return YES;
    } else if ([string isEqualToString:@"7"]) {
        return YES;
    } else if ([string isEqualToString:@"8"]) {
        return YES;
    } else if ([string isEqualToString:@"9"]) {
        return YES;
    } else if ([string isEqualToString:@""]){
        return YES;
    } else {
        return NO;
    }
}

- (void)saveButtonClicked {
    DLog(@"saveButtonClicked");
    if (pwdString) {
        NSString *code = _parameterValues[5];
        
        if (6 != code.length || ![code isNumbers]) {
            [self showAlertControllerWithTitle:LS(@"Please input six digits's PIN code")];
            return;
        }
    }
    if (![self checkIntervalStates]) {
        [self showAlertControllerWithTitle:LS(@"At least one item of the broadcast interval is less than or equal to 2000 and not 0, otherwise the module may be unusable after setting!")];
        return;
    }
    
    FWRange *intervalRange = _device.intervalRange;
    
    if (intervalRange && _intervalTextField) {
        const int interval = [_intervalTextField.text intValue];
        
        if (0 != interval && (interval < intervalRange.minValue || interval > intervalRange.maxValue)) {
            [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"%@%@%d~%d%@", LS(@"Interval"), LS(@" is out of range "), intervalRange.minValue, intervalRange.maxValue, LS(@" and not 0")]];
            return;
        }
    }
    
    FWRange *gsensorIntervalRange = _device.gsensorIntervalRange;
    
    if (gsensorIntervalRange && _gsensorIntervalTextField) {
        const int gsensorInterval = [_gsensorIntervalTextField.text intValue];
        
        if (0 != gsensorInterval && (gsensorInterval < gsensorIntervalRange.minValue || gsensorInterval > gsensorIntervalRange.maxValue)) {
            [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"Gsensor %@%@%d~%d%@", LS(@"interval"), LS(@" is out of range "), gsensorIntervalRange.minValue, gsensorIntervalRange.maxValue, LS(@" and not 0")]];
            return;
        }
    }
    
    FWRange *gsensorDurationRange = _device.gsensorDurationRange;
    
    if (gsensorDurationRange && _gsensorDurationTextField) {
        const int gsensorDuration = [_gsensorDurationTextField.text intValue];
        
        if (gsensorDuration < gsensorDurationRange.minValue || gsensorDuration > gsensorDurationRange.maxValue) {
            [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"Gsensor %@%@%d~%d", LS(@"duration"), LS(@" is out of range "), gsensorDurationRange.minValue, gsensorDurationRange.maxValue]];
            return;
        }
    }
    
    FWRange *gsensorSensitivityRange = _device.gsensorSensitivityRange;
    
    if (gsensorSensitivityRange && _gsensorSensitivityTextField) {
        const int gsensorSensitivity = [_gsensorSensitivityTextField.text intValue];
        
        if (gsensorSensitivity < gsensorSensitivityRange.minValue || gsensorSensitivity > gsensorSensitivityRange.maxValue) {
            [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"Gsensor %@%@%d~%d", LS(@"sensitivity"), LS(@" is out of range "), gsensorSensitivityRange.minValue, gsensorSensitivityRange.maxValue]];
            return;
        }
    }
    
    FWRange *keyIntervalRange = _device.keyIntervalRange;
    
    if (keyIntervalRange && _keyIntervalTextField) {
        const int keyInterval = [_keyIntervalTextField.text intValue];
        
        if (0 != keyInterval && (keyInterval < keyIntervalRange.minValue || keyInterval > keyIntervalRange.maxValue)) {
            [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"Key %@%@%d~%d%@", LS(@"interval"), LS(@" is out of range "), keyIntervalRange.minValue, keyIntervalRange.maxValue, LS(@" and not 0")]];
            return;
        }
    }
    
    FWRange *keyDurationRange = _device.keyDurationRange;
    
    if (keyDurationRange && _keyDurationTextField) {
        const int keyDuration = [_keyDurationTextField.text intValue];
        
        if (keyDuration < keyDurationRange.minValue || keyDuration > keyDurationRange.maxValue) {
            [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"Key %@%@%d~%d", LS(@"duration"), LS(@" is out of range "), keyDurationRange.minValue, keyDurationRange.maxValue]];
            return;
        }
    }
    
    index = 0;
    isSend = YES;
    commandsCount = 0;
    firstOpen = false;
    shouldQuery = false;
    [_receivedString setString:@""];
    isclick = YES;
    _isSave = YES;
    [self showProgressHUDWithTitle:LS(@"Saving...")];
    [self startCfg];
    
    _saveTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(saveParametersTimeout) userInfo:nil repeats:NO];
}

- (void)saveParametersTimeout {
    [self stopAllTimers];
    
    if (!_timeout) {
        _timeout = YES;
        
        [_progressHUD hideAnimated:YES];
        [self showAlertControllerAndPopWithTitle:LS(@"Set parameters timeout")];
    }
}

- (void)stopAllTimers {
    STOP_TIMER(_queryTimeoutTimer);
    STOP_TIMER(_saveTimeoutTimer);
    STOP_TIMER(_responseTimeoutTimer);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!shouldShow) {
        canDisconnect = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopAllTimers];
    
    if ((shouldShow || canDisconnect) && ![self.navigationController.viewControllers containsObject:self]) {
        isFirst = YES;
        // 返回的时候断开蓝牙
        [self disconnect];
    }
}

- (void)disconnect {
    if (mConnectedPeripheral) {
        _disconnectInitiative = YES;
        [mCentralManager cancelPeripheralConnection:mConnectedPeripheral];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    deleteArrayM = [[NSMutableArray alloc] init];
    uuidStringArrM = [[NSMutableArray alloc] init];

    [deleteArrayM addObject:@"iBeacon"];
    [deleteArrayM addObject:@"URL"];
    [deleteArrayM addObject:@"UID"];
    [deleteArrayM addObject:@"AltBeacon"];
    
    [self loadData];
    [self addRightBtn];
    [self createTableView];
    //注册观察键盘的变化
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transformView:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)showProgressHUDWithTitle:(NSString *)title {
    UIView *view = self.view;
    
    if (nil == _progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:view];
    }
    
    _progressHUD.label.text = title;
    
    NSLog(@"1 _progressHUD: %@", _progressHUD);
    
    [view addSubview:_progressHUD];
    
    [_progressHUD showAnimated:YES];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"%@",error);
    }
    if (equipmentDataArray.count > 0 && isSend) {
        for (int i = 0; i < equipmentDataArray.count; i++) {
            if ([equipmentDataArray[i][1] isEqualToString:deleteArrayM.firstObject] && [[[equipmentDataArray[i] lastObject] lastObject] isEqualToString:@"1"]) {
                if ([[[equipmentDataArray[i] lastObject] firstObject] isEqualToString:@"0"]) {
                    [[equipmentDataArray[i] lastObject] replaceObjectAtIndex:0 withObject:@"00000000000000000000000000000000"];
                }
                [uuidStringArrM addObject:[[equipmentDataArray[i] lastObject] firstObject]];
            }
        }
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *uuidStringArr_sub = [userDefaults valueForKey:@"uuid"];
    NSMutableArray *uuidStringArrM_sub = uuidStringArr_sub.mutableCopy;
    if (!uuidStringArrM_sub) {
        uuidStringArrM_sub = [[NSMutableArray alloc] init];
    }
    for (NSString *str in uuidStringArrM) {
        if (![uuidStringArrM_sub containsObject:str]) {
            [uuidStringArrM_sub addObject:str];
        }
    }
    [userDefaults setObject:uuidStringArrM_sub forKey:@"uuid"];
    
    [self stopAllTimers];
    
    [_progressHUD hideAnimated:YES];
    
    if (!_disconnectInitiative) {
        [self showAlertControllerAndPopWithTitle:LS(@"Disconnected")];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 删除按钮
- (void)clickToDeleteCell:(UIButton *)sender {
    keyboardState = YES;
    [equipmentDataArray removeObjectAtIndex:sender.tag-1];
    if (equipmentDataArray.count < 10) {
        _addBeaconButton.hidden = NO;
    }
    [self.tableView reloadData];
}

// 添加eddystone
- (void)clickToAddibeacon:(UIButton *)sender{
    shouldShow = NO;
    __weak typeof(self) weakSelf = self;
    FWAddEddystoneViewController *vc = [[FWAddEddystoneViewController alloc] initWithDataModel:equipmentDataArray];
    vc.dataBlock = ^(NSArray *dataArray) {
        [equipmentDataArray addObject:dataArray];
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return equipmentDataArray.count+1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    //创建一个用于返回效果的UIView，用来承接文字或图片
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, SECTION_HEIGH)] ;
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 50, 44)];
    numLabel.text = [NSString stringWithFormat:@"%ld",(long)section];
    //自定义文字效果
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((customView.frame.size.width-100)/2.0, 0, 100, SECTION_HEIGH)];
    headerLabel.center = customView.center;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.opaque =NO;
    headerLabel.highlightedTextColor = [UIColor blackColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:17];
    headerLabel.text = equipmentDataArray[section - 1][1];

    UIButton *btn = [[UIButton alloc] init];
    btn.frame = CGRectMake(customView.frame.size.width-28, (SECTION_HEIGH-20)/2, 20, 20);
    [btn setImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickToDeleteCell:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = section;

    [customView addSubview:headerLabel];
    [customView addSubview:numLabel];
    [customView addSubview:btn];
    
    return customView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    return v;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _parameterNames.count;
    }
    return [[equipmentDataArray[section - 1] lastObject] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return SECTION_HEIGH;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (equipmentDataArray.count == 10) {
        _addBeaconButton.hidden = YES;
    }
    FWConfigureViewCell *oneCell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigure" owner:self options:nil] firstObject];
    FWConfigureTwoCell *twoCell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureTwoCell" owner:self options:nil] firstObject];
    FWConfigureFourCell *fourCell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureFourCell" owner:self options:nil] firstObject];
    FWConfigurePowerCell *powerCell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePowerCell" owner:self options:nil] firstObject];
    FWConfigureStateCell *stateCell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureStateCell" owner:self options:nil] firstObject];
    fourCell.inputTextField.delegate = self;
    oneCell.selectionStyle = UITableViewCellSelectionStyleNone;
    twoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    fourCell.selectionStyle = UITableViewCellSelectionStyleNone;
    powerCell.selectionStyle = UITableViewCellSelectionStyleNone;
    stateCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    const NSInteger parametersCount = _parameterNames.count;
    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;
    
    NSLog(@"section: %d, row: %d, parametersCount: %d", (int)section, (int)row, (int)parametersCount);
    NSLog(@"_parameterNames:\n%@", _parameterNames);
    NSLog(@"_parameterValues:\n%@", _parameterValues);
    
    if (section == 0) {
        if (row == parametersCount - 1) {
            if (_hasKey) {
                stateCell.titleLabel.text = _parameterNames[row];
                
                _keyIntervalTextField = stateCell.intervalTextField;
                _keyDurationTextField = stateCell.durationTextField;
                
                _keyIntervalTextField.delegate = self;
                _keyDurationTextField.delegate = self;
                
                NSArray *values = _parameterValues[row];
                
                _keyIntervalTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[0] intValue]];
                _keyDurationTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[1] intValue]];
                
                [self updateTextColors];
                
                return stateCell;
            } else if (_hasGsensor) {
                if ([[_device modelName] isEqualToString:@"BP108N"]) {
                    FWThresholdCell *thresholdCell = [[[NSBundle mainBundle] loadNibNamed:@"FWThresholdCell" owner:self options:nil] firstObject];
                    
                    thresholdCell.titleLabel.text = _parameterNames[row];
                    
                    NSArray *values = _parameterValues[row];
                    
                    _gsensorIntervalTextField = thresholdCell.intervalTextField;
                    _gsensorDurationTextField = thresholdCell.durationTextField;
                    _gsensorSensitivityTextField = thresholdCell.sensitiveTextField;
                    
                    _gsensorIntervalTextField.delegate = self;
                    _gsensorDurationTextField.delegate = self;
                    _gsensorSensitivityTextField.delegate = self;
                    
                    _gsensorIntervalTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[0] intValue]];
                    _gsensorDurationTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[1] intValue]];
                    _gsensorSensitivityTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[2] intValue]];
                    
                    [self updateTextColors];
                    
                    return thresholdCell;
                }
                
                FWGsensorCell *gsensorCell = [[[NSBundle mainBundle] loadNibNamed:@"FWGsensorCell" owner:self options:nil] firstObject];
                
                gsensorCell.titleLabel.text = _parameterNames[row];
                
                NSArray *values = _parameterValues[row];
                
                _gsensorIntervalTextField = gsensorCell.intervalTextField;
                _gsensorDurationTextField = gsensorCell.durationTextField;
                
                _keyIntervalTextField.delegate = self;
                _keyDurationTextField.delegate = self;
                
                _gsensorIntervalTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[0] intValue]];
                _gsensorDurationTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[1] intValue]];
                
                [self updateTextColors];
                
                return gsensorCell;
            } else {
                if (_hasTxPower) {
                    powerCell.powerLabel.text = _parameterNames[row];
                    [powerCell.powerButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
                    powerCell.txPowerLabel.text = _parameterValues.count >= 6 ? _parameterValues[6] : nil;
                    return powerCell;
                } else if (!pwdString && !_hasTxPower) {
                    twoCell.textLabel.text = _parameterNames[row];
                    twoCell.textLabel.font = [UIFont systemFontOfSize:17];
                    twoCell.switchBtn.on = [_parameterValues[row] isEqualToString:@"00"] ? NO : YES;
                    __weak NSMutableArray *weak_parameterValues = _parameterValues;
                    twoCell.indexPathBlock = ^(NSIndexPath *newIndexPath, BOOL switchBtnState) {
                        [weak_parameterValues replaceObjectAtIndex:newIndexPath.row withObject:(switchBtnState == YES ? @"01" : @"00")];
                    };
                    return twoCell;
                } else {
                    fourCell.textLabel.text = _parameterNames[row];
                    fourCell.textLabel.font = [UIFont systemFontOfSize:17];
                    fourCell.inputTextField.text = _parameterValues[row];
                    fourCell.inputTextField.textColor = [UIColor colorWithHexString:@"0e74bd"];
                    fourCell.inputTextField.delegate = self;
                    return fourCell;
                }
            }
        } else if (row == parametersCount - 2 && _hasGsensor && _hasKey) {
            if ([[_device modelName] isEqualToString:@"BP108N"]) {
                FWThresholdCell *thresholdCell = [[[NSBundle mainBundle] loadNibNamed:@"FWThresholdCell" owner:self options:nil] firstObject];
                
                thresholdCell.titleLabel.text = _parameterNames[row];
                
                NSArray *values = _parameterValues[row];
                
                _gsensorIntervalTextField = thresholdCell.intervalTextField;
                _gsensorDurationTextField = thresholdCell.durationTextField;
                _gsensorSensitivityTextField = thresholdCell.sensitiveTextField;
                
                _gsensorIntervalTextField.delegate = self;
                _gsensorDurationTextField.delegate = self;
                _gsensorSensitivityTextField.delegate = self;
                
                _gsensorIntervalTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[0] intValue]];
                _gsensorDurationTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[1] intValue]];
                _gsensorSensitivityTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[2] intValue]];
                
                [self updateTextColors];
                
                return thresholdCell;
            }
            
            FWGsensorCell *gsensorCell = [[[NSBundle mainBundle] loadNibNamed:@"FWGsensorCell" owner:self options:nil] firstObject];
            
            gsensorCell.titleLabel.text = _parameterNames[row];
            
            NSArray *values = _parameterValues[row];
            
            _gsensorIntervalTextField = gsensorCell.intervalTextField;
            _gsensorDurationTextField = gsensorCell.durationTextField;
            
            _gsensorIntervalTextField.delegate = self;
            _gsensorDurationTextField.delegate = self;
            
            _gsensorIntervalTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[0] intValue]];
            _gsensorDurationTextField.text = [[NSString alloc] initWithFormat:@"%d", [values[1] intValue]];
            
            [self updateTextColors];
            
            return gsensorCell;
        } else if (row == 6 && _hasKey) {
            powerCell.powerLabel.text = _parameterNames[row];
            [powerCell.powerButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            powerCell.txPowerLabel.text = _parameterValues.count>=6?_parameterValues[6]:nil;
            return powerCell;
        } else if (row == 0 || row == 1) {
            oneCell.textLabel.text = _parameterNames[row];
            oneCell.nameLabel.text = _parameterValues[row];
            oneCell.textLabel.font = [UIFont systemFontOfSize:17];
            oneCell.nameLabel.textColor = [UIColor colorWithHexString:@"7b7b7b"];
            return oneCell;
        } else if (row == 3) {
            fourCell.textLabel.text = _parameterNames[row];
            fourCell.textLabel.font = [UIFont systemFontOfSize:17];
            
            _intervalTextField = fourCell.inputTextField;
            
            _intervalTextField.delegate = self;
            _intervalTextField.text = [[NSString alloc] initWithFormat:@"%d", [_parameterValues[row] intValue]];
            
            [self updateTextColors];
            
            return fourCell;
        } else if (row == 4) {
            twoCell.textLabel.text = _parameterNames[row];
            twoCell.textLabel.font = [UIFont systemFontOfSize:17];
            twoCell.switchBtn.on = [_parameterValues[row] boolValue];
            
            __weak NSMutableArray *weak_parameterValues = _parameterValues;
            
            twoCell.indexPathBlock = ^(NSIndexPath *newIndexPath, BOOL switchBtnState) {
                [weak_parameterValues replaceObjectAtIndex:4 withObject:@(switchBtnState)];
            };
            return twoCell;
        } else if (row == 5 && pwdString) {
            fourCell.textLabel.text = _parameterNames[row];
            fourCell.textLabel.font = [UIFont systemFontOfSize:17];
            fourCell.inputTextField.text = _parameterValues[row];
            fourCell.inputTextField.textColor = [UIColor colorWithHexString:@"0e74bd"];
            fourCell.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
            return fourCell;
        } else {
            fourCell.textLabel.text = _parameterNames[row];
            fourCell.textLabel.font = [UIFont systemFontOfSize:17];
            fourCell.inputTextField.text = _parameterValues[row];
            fourCell.inputTextField.textColor = [UIColor colorWithHexString:@"0e74bd"];
            return fourCell;
        }

    } else {

        if (row == [[equipmentDataArray[section - 1] lastObject] count]-1) {
            twoCell.switchBtn.on = [[[equipmentDataArray[section - 1] lastObject] lastObject] isEqualToString:@"1"]?YES:NO;
            twoCell.textLabel.text = [equipmentDataArray[section - 1] firstObject][row];
            twoCell.textLabel.font = [UIFont systemFontOfSize:17];
            __weak NSMutableArray *weakEquipmentDataArray = equipmentDataArray;
            twoCell.indexPathBlock = ^(NSIndexPath *newIndexPath, BOOL switchBtnState) {
                [[weakEquipmentDataArray[newIndexPath.section - 1] lastObject] replaceObjectAtIndex:newIndexPath.row withObject:(switchBtnState == YES ? @"1" : @"0")];
            };
            twoCell.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
            twoCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, twoCell.bounds.size.width);
            return twoCell;
        }
        fourCell.inputTextField.text = [equipmentDataArray[section - 1] lastObject][row];
        fourCell.textLabel.text = [equipmentDataArray[section - 1] firstObject][row];
        fourCell.textLabel.font = [UIFont systemFontOfSize:17];
        [fourCell.textLabel sizeToFit];
        fourCell.inputTextField.textColor = [UIColor darkGrayColor];
        if ([fourCell.textLabel.text isEqualToString:@"UUID:"] || [fourCell.textLabel.text isEqualToString:@"ID1:"]) {
            fourCell.inputTextField.font = [UIFont systemFontOfSize:12];
        } else {
            fourCell.inputTextField.font = [UIFont systemFontOfSize:14];
        }

        fourCell.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
        fourCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, fourCell.bounds.size.width);
        return fourCell;

    }
}

- (void)click:(UIButton *)sender {
    FWPopoverViewController * popoverViewController = [[FWPopoverViewController alloc] initWithTitles:_device.txPowers sourceView:sender];
    __weak typeof(self) weakSelf = self;
    
    popoverViewController.selectionHandler = ^(NSString *powerString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.txPowerString = powerString;
        if (strongSelf->_parameterValues.count > 6) {
            [strongSelf->_parameterValues replaceObjectAtIndex:6 withObject:powerString];
        } else {
            [strongSelf->_parameterValues addObject:powerString];
        }
        [strongSelf.tableView reloadData];
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

// 选择广播间隔
- (void)clickInterval:(UIButton *)sender {
    NSMutableArray *arrM = [[NSMutableArray alloc] init];
    if ([[_device modelName] isEqualToString:@"BP108N"]) {
        for (int i=0; i<NELEM(BROADCAST_INTERVAL_MS_BP108N); i++) {
            [arrM addObject:[NSString stringWithFormat:@"%d",BROADCAST_INTERVAL_MS_BP108N[i]]];
        }
    } else if (_hasKey) {
        for (int i=0; i<NELEM(BROADCAST_LED_MS); i++) {
            [arrM addObject:[NSString stringWithFormat:@"%d",BROADCAST_LED_MS[i]]];
        }
    } else {
        for (int i=0; i<NELEM(BROADCAST_INTERVAL_MS); i++) {
            [arrM addObject:[NSString stringWithFormat:@"%d",BROADCAST_INTERVAL_MS[i]]];
        }
    }
    FWPopoverViewController * popoverViewController = [[FWPopoverViewController alloc] initWithTitles:arrM sourceView:sender];
    __weak typeof(self) weakSelf = self;
    
    popoverViewController.selectionHandler = ^(NSString *intervalString) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf->_parameterValues[3] = intervalString;
        [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        if (2000 <= [intervalString integerValue]) {
            [strongSelf showAlertControllerWithTitle:LS(@"INTERVAL_PROMPT")];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

// 选择广播间隔(key)
- (void)clickKeyInterval:(UIButton *)sender {
    NSMutableArray *arrM = [[NSMutableArray alloc] init];
    for (int i=0; i<NELEM(BROADCAST_STATE_MS); i++) {
        [arrM addObject:[NSString stringWithFormat:@"%d",BROADCAST_STATE_MS[i]]];
    }
    FWPopoverViewController * popoverViewController = [[FWPopoverViewController alloc] initWithTitles:arrM sourceView:sender];
    __weak typeof(self) weakSelf = self;
    
    popoverViewController.selectionHandler = ^(NSString *keyIntervalString) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        const NSInteger index = strongSelf->_parameterValues.count - 1;
        
        strongSelf->_parameterValues[index][0] = keyIntervalString;
        [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

// 选择广播间隔(_hasGsensor)
- (void)clickGsensorInterval:(UIButton *)sender {
    NSMutableArray *arrM = [[NSMutableArray alloc] init];
    for (int i=0; i<NELEM(BROADCAST_STATE_MS); i++) {
        [arrM addObject:[NSString stringWithFormat:@"%d",BROADCAST_STATE_MS[i]]];
    }
    FWPopoverViewController * popoverViewController = [[FWPopoverViewController alloc] initWithTitles:arrM sourceView:sender];
    __weak typeof(self) weakSelf = self;
    
    popoverViewController.selectionHandler = ^(NSString *gsensorIntervalString) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf->_hasKey) {
            strongSelf->_parameterValues[_parameterValues.count - 2][0] = gsensorIntervalString;
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_parameterValues.count - 2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            strongSelf->_parameterValues[_parameterValues.count - 1][0] = gsensorIntervalString;
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_parameterValues.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (void)clickWithGsensorArray:(UIButton *)sender {
    NSMutableArray *arrM = [[NSMutableArray alloc] init];
    for (int i=0; i<NELEM(BROADCAST_GSENSOR_REVICE); i++) {
        [arrM addObject:[NSString stringWithFormat:@"%d",BROADCAST_GSENSOR_REVICE[i]]];
    }
    FWPopoverViewController * popoverViewController = [[FWPopoverViewController alloc] initWithTitles:arrM sourceView:sender];
    __weak typeof(self) weakSelf = self;
    
    popoverViewController.selectionHandler = ^(NSString *gsensorString) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSInteger index;
        
        if (strongSelf->_hasKey) {
            index = strongSelf->_parameterValues.count - 2;
        } else {
            index = strongSelf->_parameterValues.count - 1;
        }
        strongSelf->_parameterValues[index][1] = gsensorString;
        [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (void)clickThreshold:(UIButton *)sender {
    NSMutableArray *arrM = [[NSMutableArray alloc] init];
    for (int i=2; i<=127; i++) {
        [arrM addObject:[NSString stringWithFormat:@"%d",i]];
    }
    FWPopoverViewController * popoverViewController = [[FWPopoverViewController alloc] initWithTitles:arrM sourceView:sender];
    
    __weak typeof(self) weakSelf = self;
    
    popoverViewController.selectionHandler = ^(NSString *thresholdString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSInteger index;
        
        if (strongSelf->_hasKey) {
            index = strongSelf->_parameterValues.count - 2;
        } else {
            index = strongSelf->_parameterValues.count - 1;
        }
        strongSelf->_parameterValues[index][2] = thresholdString;
        [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (void)clickWithKeyArray:(UIButton *)sender {
    NSMutableArray *arrM = [[NSMutableArray alloc] init];
    for (int i=0; i<NELEM(BROADCAST_KEY_REVICE); i++) {
        [arrM addObject:[NSString stringWithFormat:@"%d",BROADCAST_KEY_REVICE[i]]];
    }
    FWPopoverViewController * popoverViewController = [[FWPopoverViewController alloc] initWithTitles:arrM sourceView:sender];
    
    __weak typeof(self) weakSelf = self;
    
    popoverViewController.selectionHandler = ^(NSString *keyString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        const NSInteger index = strongSelf->_parameterValues.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [strongSelf->_parameterValues[index] replaceObjectAtIndex:1 withObject:keyString];
        [strongSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}

// 十六进制数据转字符串
-(NSString *)fan_dataToHexString:(NSData *)data{
    Byte *bytehex =(Byte *) data.bytes;
    NSMutableString *hexString=[[NSMutableString alloc]init];
    for (int i=0; i<data.length; i++) {
        Byte b=bytehex[i];
        [hexString appendFormat:@"%02x",b];
    }
    return hexString;
}
//将NSUInteger转换成十六进制的字符串
- (NSString *)stringWithHexNumber:(NSUInteger)hexNumber length:(NSInteger)length{
    char hexChar[20];
    sprintf(hexChar, "%x", (int)hexNumber);
    NSString *hexString = [NSString stringWithCString:hexChar encoding:NSUTF8StringEncoding];
    if (hexString.length < length) {
        NSInteger count = length - hexString.length;
        for (int i = 0; i < count; i++) {
            hexString = [@"0" stringByAppendingString:hexString];
            if (hexString.length == length) {
                break;
            }
        }
    }
    return hexString;
}

#pragma mark - bluetooth
- (void)cleanup {
    [self disconnect];
}
//超时断开
- (void)queryParametersTimeout {
    [self stopAllTimers];
    
    if (!_timeout) {
        _timeout = YES;
        
        [self disconnect];
        [self showAlertControllerAndPopWithTitle:LS(@"Query parameters timeout")];
    }
}

// 调用此方法来写入数据
- (void)writeCommand:(NSString *)command {
    if (!_timeout && 0 < command.length) {
        NSLog(@"write_command: %@", command);
        [mConnectedPeripheral writeValue:[command dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:mTransferCharacteristic type: CBCharacteristicWriteWithoutResponse];
    }
}
// 写入数据之后的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"%@",error);
        return;
    }
    NSLog(@"%@--------------------%@",peripheral,characteristic);

}

-(void)startCfg {
    NSLog(@"_parameterValues_444: %@", _parameterValues);

    if (equipmentDataArray.count == 0) {
        btCfgState = CFG_MODULE_SND_CFGMODE;
        [self sendNextCfg];
        return;
    }

    if ([equipmentDataArray[index][1] isEqualToString:deleteArrayM.firstObject]) { //beacon
        btCfgState = CFG_MODULE_SND_IBCCFG;
        [self sendNextCfg];
    } else if ([equipmentDataArray[index][1] isEqualToString:deleteArrayM[1]]) { //url
        btCfgState = CFG_MODULE_SND_EDSEN;
        [self sendNextCfg];
    } else if ([equipmentDataArray[index][1] isEqualToString:deleteArrayM[2]]) { //uid
        btCfgState = CFG_MODULE_SND_EDSCFG;
        [self sendNextCfg];
    } else if ([equipmentDataArray[index][1] isEqualToString:deleteArrayM.lastObject]) { //altBeacon
        btCfgState = CFG_MODULE_SND_ABCCFG;
        [self sendNextCfg];
    } else {
        return;
    }
    index++;

}

- (void)sendOpenCommandIfPossible {
    if (_shouldSendOpenCommand && nil != _device) {
        _shouldSendOpenCommand = NO;
        btCfgState = CFG_MODULE_SND_OPEN_AT;
        [self sendNextCfg];
        firstOpen = true;
    }
}

// 拼接广播并发送到设备
- (void)sendNextCfg {
    switch(btCfgState)
    {
        case CFG_MODULE_SND_OPEN_AT:
            // 打开空中指令
            [self writeCommand:@"$OpenFscAtEngine$"];
            btRcvState = BT_RCV_W4_OPEN_AIR_CMD_RSP;
            shouldQuery = true;
            break;
        case CFG_MODULE_QUERY_DATA:
            // 查询
            [self writeCommand:@"AT+BADVDATA\r\n"];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            shouldQueryName = YES;
            break;
        case CFG_MODULE_QUERY_NAME:
            [self writeCommand:@"AT+NAME\r\n"];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            shouldQueryPin = YES;
            shouldQueryName = NO;
            break;
        case CFG_MODULE_QUERY_PIN:
            [self writeCommand:@"AT+PIN\r\n"];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            shouldQueryTLM = YES;
            shouldQueryPin = NO;
            break;
        case CFG_MODULE_QUERY_TLM:
            [self writeCommand:@"AT+TLM\r\n"];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            shouldQueryAdvin = YES;
            shouldQueryTLM = NO;
            break;
        case CFG_MODULE_QUERY_ADVIN:
            // 查询广播间隔
            [self writeCommand:@"AT+ADVIN\r\n"];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            shouldQueryAdvin = NO;
            if (_hasTxPower) {
                shouldTxPower = YES;
            } else {
                if (_hasGsensor) {
                    shouldGSSFG = YES;
                } else if (_hasKey) {
                    shouldKEYCFG = YES;
                } else {
                    shouldBUZ = YES;
                }
            }
            break;
        case CFG_MODULE_QUERY_TXPOWER:
            // 查询txPower
            [self writeCommand:@"AT+TXPOWER\r\n"];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            shouldTxPower = NO;
            if (_hasGsensor) {
                shouldGSSFG = YES;
            } else if (_hasKey) {
                shouldKEYCFG = YES;
            } else {
                shouldBUZ = YES;
            }
            break;
        case CFG_MODULE_QUERY_GSCFG:
            [self writeCommand:@"AT+GSCFG\r\n"];
            shouldGSSFG = NO;
            if (_hasKey) {
                shouldKEYCFG = YES;
            } else {
                shouldBUZ = YES;
            }
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            break;
        case CFG_MODULE_QUERY_KEYCFG:
            [self writeCommand:@"AT+KEYCFG\r\n"];
            shouldKEYCFG = NO;
            shouldBUZ = YES;
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            break;
        case CFG_MODULE_SND_BUZ:
        {
            [self writeCommand:@"AT+BUZ=1,100\r\n"];
            shouldBUZ = NO;
            btRcvState = BT_RCV_W4_SETCMD_RSP;
        }
            break;
        case CFG_MODULE_SND_IBCCFG: // NOTE: NEED MODIFY.
            // 将UUID,Major,Minor,Power的设置发给终端
        {
            NSArray *arr = [equipmentDataArray[index] lastObject];
            [self writeCommand:[NSString stringWithFormat:@"AT+BADVDATA=%d,%@%@%@%@%@,%@\r\n",index,HANDSTRING,[arr.firstObject length]==32?arr.firstObject:@"00000000000000000000000000000000", [self stringWithHexNumber:[arr[1] integerValue] length:4], [self stringWithHexNumber:[arr[2] integerValue] length:4], [[NSString turnStringToSignedHex:[arr[3] intValue]] length]==2?[NSString turnStringToSignedHex:[arr[3] intValue]]:@"00",arr.lastObject]];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            break;
        }
        case CFG_MODULE_SND_EDSEN:
            // 将eddystone(url)的设置发给终端
        {
            NSArray *arr = [equipmentDataArray[index] lastObject];
            addressStr = [NSString stringWithFormat:@"%@%@",[self transformAddressHandString:arr.firstObject]?[self transformAddressHandString:arr.firstObject]:@"00",[self HexConvertToASCII:arr.firstObject]?[self HexConvertToASCII:arr.firstObject]:[self HexConvertToASCII:@"http://www.feasycom.com"]];
            //计算有效位: 地址长度 + power长度 + @"16AAFE"标识位长度 + url标识位长度
            NSInteger length = addressStr.length/2 + [[NSString turnStringToSignedHex:[arr[1] intValue]] length]/2 + 3 + 1;
            NSString *lengthStr = [NSString getHexByDecimal:(int)length];
            if (lengthStr.length < 2) {
                lengthStr = [@"0" stringByAppendingString:lengthStr];
            }
            [self writeCommand:[NSString stringWithFormat:@"AT+BADVDATA=%d,%@%@%@%@%@%@,%@\r\n",index,URLHEAD,lengthStr,URLTAIL,@"10",[[NSString turnStringToSignedHex:[arr[1] intValue]] length]==2?[NSString turnStringToSignedHex:[arr[1] intValue]]:@"00",addressStr,arr.lastObject]];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            break;
        }
        case CFG_MODULE_SND_EDSCFG: // NOTE NEED MODIFY.
            // 将eddystone(uid)的设置发给终端
        {
            NSArray *arr = [equipmentDataArray[index] lastObject];
            [self writeCommand:[NSString stringWithFormat:@"AT+BADVDATA=%d,%@%@%@%@%@%@,%@\r\n",index,UIDHEAD,@"00",[[NSString turnStringToSignedHex:[arr[3] intValue]] length]==2?[NSString turnStringToSignedHex:[arr[3] intValue]]:@"00",[arr.firstObject length]==20?arr.firstObject:@"00000000000000000000",[arr[1] length]==12?arr[1]:@"000000000000",[arr[2] length]==4?arr[2]:@"0000",arr.lastObject]];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            break;
        }
        case CFG_MODULE_SND_ABCCFG:
            // 将altBeacon的设置发给终端
        {
            NSLog(@"equipmentDataArray.count: %d", (int)equipmentDataArray.count);
            NSLog(@"index: %d", (int)index);
            NSArray *arr = [equipmentDataArray[index] lastObject];
            [self writeCommand:[NSString stringWithFormat:@"AT+BADVDATA=%d,%@%@%@%@%@%@%@%@,%@\r\n",index,ALTBEACONSTRING,[NSString addZero:[NSString turnStringToSignedHex:[arr[4] intValue]] length:4],@"BEAC",[arr.firstObject length]==32?arr.firstObject:@"00000000000000000000000000000000",[NSString addZero:arr[1] length:4],[NSString addZero:arr[2] length:4],[[NSString turnStringToSignedHex:[arr[3] intValue]] length]==2?[NSString turnStringToSignedHex:[arr[3] intValue]]:@"00",[NSString addZero:arr[5] length:2],arr.lastObject]];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            break;
        }
        case CFG_MODULE_SND_CFGMODE:
            if (pwdString) {
                // 0 代表可被连接
                [self writeCommand:[NSString stringWithFormat:@"AT+BWMODE=0\r\n"]];
                btRcvState = BT_RCV_W4_SETCMD_RSP;
            } else {
                if(_parameterValues[4])
                    // 0 代表可被连接
                    [self writeCommand:[NSString stringWithFormat:@"AT+BWMODE=0\r\n"]];
                else
                    // 1 代表不可被连接
                    [self writeCommand:[NSString stringWithFormat:@"AT+BWMODE=1\r\n"]];
                btRcvState = BT_RCV_W4_SETCMD_RSP;
            }
                break;
        case CFG_MODULE_SND_ADVIN:
            // 设置广播间隔
            if (_hasKey) {
                [self writeCommand:[NSString stringWithFormat:@"AT+ADVIN=%ld\r\n",(long)[self sendInterval_led:[_parameterValues[3] integerValue]]]];
            } else {
                [self writeCommand:[NSString stringWithFormat:@"AT+ADVIN=%ld\r\n",(long)[self sendInterval:[_parameterValues[3] integerValue]]]];
            }
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            break;

        case CFG_MODULE_SND_NAME: // NOTE NEED MODIFY
            // 设置 SPP 名字
            [self writeCommand:[NSString stringWithFormat:@"AT+NAME=%@\r\n",_parameterValues[2]]];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            break;

        case CFG_MODULE_SND_LENAME: // NOTE: NEED MODIFY
            // 设置 BLE 名字
            [self writeCommand:[NSString stringWithFormat:@"AT+LENAME=%@\r\n",_parameterValues[2]]];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            break;
        case CFG_MODULE_SND_PIN:
        {
            if (pwdString) {
                // 发送pin密码
                [self writeCommand:[NSString stringWithFormat:@"AT+PIN=%@\r\n",_parameterValues[5]]];
                btRcvState = BT_RCV_W4_SETCMD_RSP;
            }
            break;
        }
        case CFG_MODULE_SND_TLM:
        {
            [self writeCommand:[NSString stringWithFormat:@"AT+TLM=%d\r\n", [_parameterValues[4] intValue]]];
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            break;
        }
        case CFG_MODULE_SND_TXPOWER:
        {
            if (_hasTxPower) {
                if (_parameterValues.count > 6) {
                    if ([[_device modelName] isEqualToString:@"BP671"]) {
                        NSString *powerString = _parameterValues[6];
                        
                        powerString = [powerString stringByReplacingOccurrencesOfString:@"db" withString:@""];
                        
                        const NSInteger value = (NSInteger)roundf([powerString floatValue] * 10.f);
                        
                        [self writeCommand:[NSString stringWithFormat:@"AT+TXPOWER=%d\r\n", (int)value]];
                    } else {
                        NSInteger index = [_device.txPowers indexOfObject:_parameterValues[6]];
                        NSString *str = [NSString getHexByDecimal:(int)index];
                        [self writeCommand:[NSString stringWithFormat:@"AT+TXPOWER=%@\r\n",str]];
                    }
                } else {
                    [self writeCommand:[NSString stringWithFormat:@"AT+TXPOWER=7\r\n"]];
                }
                btRcvState = BT_RCV_W4_SETCMD_RSP;
            }
            break;
        }
//        case CFG_MODULE_SND_LED:
//        {
////            [self writeCommand:[NSString stringWithFormat:@"AT+LED=%@\r\n",_parameterValues[4]]];
////            btRcvState = BT_RCV_W4_SETCMD_RSP;
////            break;
//        }
//            break;
        case CFG_MODULE_SND_KEYCFG:
        {
            if (_hasKey) {
                [self writeCommand:[NSString stringWithFormat:@"AT+KEYCFG=%ld,%@\r\n",(long)[self sendInterval:[[_parameterValues[_parameterValues.count-1] firstObject] integerValue]],[_parameterValues[_parameterValues.count-1] lastObject]]];
                btRcvState = BT_RCV_W4_SETCMD_RSP;
            }
            break;
        }
        case CFG_MODULE_SND_GSCFG:
        {
            if (_hasGsensor) {
                NSArray *values = _hasKey ? _parameterValues[_parameterValues.count - 2] : _parameterValues[_parameterValues.count - 1];
                
                if ([[_device modelName] isEqualToString:@"BP108N"]) {
                    [self writeCommand:[NSString stringWithFormat:@"AT+GSCFG=%ld,%@,%@\r\n",(long)[values[0] integerValue], values[1], values[2]]];
                } else {
                    [self writeCommand:[NSString stringWithFormat:@"AT+GSCFG=%ld,%@\r\n",(long)[values[0] integerValue], values[1]]];
                }
            }
            btRcvState = BT_RCV_W4_SETCMD_RSP;
            break;
        }
        default:
            break;
    }
}

// 检查设备返回的信息
- (void)processBTReceive:(NSData *)data {

    char *p = (char *)[data bytes];
    NSInteger len = [data length];
    NSInteger status = 0;
    BOOL sent = NO;

    if (firstOpen) {
        btRcvState = BT_RCV_W4_OPEN_AIR_CMD_RSP;
    } else {
        btRcvState = BT_RCV_W4_SETCMD_RSP;
    }
    
    switch(btRcvState)
    {
        case BT_RCV_W4_OPEN_AIR_CMD_RSP:
            if(len >= 11) {
                // only check last 11 bytes
                if(memcmp(p+len-11, "$OK,Opened$", 11) == 0) {
                    DLog(@"Open Fsc At Engine Successful");
                    
                    btCfgState = CFG_MODULE_QUERY_DATA;
                    [self sendNextCfg];
                    
                    [_receivedString setString:@""];
                    
                    openSuccessful = YES;
                    firstOpen = false;
                    fscAirCmdOpened = 1;
                    sent = YES;
                    status = 1;
                } else {
                    DLog(@"Open Fsc At Engine Failed");
                    status = 2;
                }
            }
            break;
        case BT_RCV_W4_SETCMD_RSP:
            if(len >= 6) {
                /* only check last 6 bytes */
                if(memcmp(p+len-6, "\r\nOK\r\n", 6) == 0) {
                    DLog(@"recv \\r\\nOK\\r\\n");
                    
                    commandsCount++;
                    if (shouldQueryName) {
                        btCfgState = CFG_MODULE_QUERY_NAME;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldQueryPin) {
                        btCfgState = CFG_MODULE_QUERY_PIN;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldQueryTLM) {
                        btCfgState = CFG_MODULE_QUERY_TLM;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldQueryAdvin) {
                        btCfgState = CFG_MODULE_QUERY_ADVIN;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldTxPower) {
                        btCfgState = CFG_MODULE_QUERY_TXPOWER;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldGSSFG) {
                        btCfgState = CFG_MODULE_QUERY_GSCFG;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldKEYCFG) {
                        btCfgState = CFG_MODULE_QUERY_KEYCFG;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldBUZ) {
                        btCfgState = CFG_MODULE_SND_BUZ;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    }
                    status = 1;
                } else if (memcmp(p+len-9, "\r\nERROR\r\n", 9) == 0) {
                    DLog(@"recv \\r\\nERROR\\r\\n");
                    
                    status = 2;
                    commandsCount++;
                    
                    if (shouldQueryName) {
                        btCfgState = CFG_MODULE_QUERY_NAME;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldQueryPin) {
                        btCfgState = CFG_MODULE_QUERY_PIN;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldQueryTLM) {
                        btCfgState = CFG_MODULE_QUERY_TLM;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldQueryAdvin) {
                        btCfgState = CFG_MODULE_QUERY_ADVIN;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldTxPower) {
                        btCfgState = CFG_MODULE_QUERY_TXPOWER;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldGSSFG) {
                        btCfgState = CFG_MODULE_QUERY_GSCFG;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldKEYCFG) {
                        btCfgState = CFG_MODULE_QUERY_KEYCFG;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    } else if (shouldBUZ) {
                        btCfgState = CFG_MODULE_SND_BUZ;
                        [self sendNextCfg];
                        [_receivedString setString:@""];
                        sent = YES;
                    }
                }
            }
            break;
        default:
            break;
    }

    if(status && index < equipmentDataArray.count && isSend && !sent) {
        if (memcmp(p+len-6, "\r\nOK\r\n", 6) == 0 || memcmp(p+len-9, "\r\nERROR\r\n", 9) == 0) {
            [_receivedString setString:@""];
            
            if ([equipmentDataArray[index][1] isEqualToString:deleteArrayM[0]]) { //beacon
                btCfgState = CFG_MODULE_SND_IBCCFG;
                [self sendNextCfg];
            } else if ([equipmentDataArray[index][1] isEqualToString:deleteArrayM[1]]) { //url
                btCfgState = CFG_MODULE_SND_EDSEN;
                [self sendNextCfg];
            } else if ([equipmentDataArray[index][1] isEqualToString:deleteArrayM[2]]) { //uid
                btCfgState = CFG_MODULE_SND_EDSCFG;
                [self sendNextCfg];
            } else if ([equipmentDataArray[index][1] isEqualToString:deleteArrayM[3]]) { //altBeacon
                btCfgState = CFG_MODULE_SND_ABCCFG;
                [self sendNextCfg];
            } else {
                [self sendNextCfg];
            }
            index++;
        }

    } else if (status && index >= equipmentDataArray.count && isSend) {
        if (memcmp(p+len-6, "\r\nOK\r\n", 6) == 0 || memcmp(p+len-9, "\r\nERROR\r\n", 9) == 0) {
            if (btCfgState == CFG_MODULE_END) {
                [_receivedString setString:@""];
                [self disconnect];
                return;
            }
            if (index<10 && !sent) {
                [self writeCommand:[NSString stringWithFormat:@"AT+BADVDATA=%d,00,0\r\n",index]];
                index ++;
                [_receivedString setString:@""];
                return;
            }
            if (!sent) {
                btCfgState = index + 1;
                NSLog(@"btCfgStatebtCfgState = %d", btCfgState);
                [self sendNextCfg];
                [_receivedString setString:@""];
                index ++;
            }
        }
    }
}

// 搜索服务的回调函数
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        DLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// 搜索特征值的回调函数
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@" ---- 搜索特征");
    if (error) {
        DLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    // 遍历特征值
    if ([service.UUID.UUIDString isEqualToString:@"FFF0"]) {
        
        for (CBCharacteristic *characteristic in service.characteristics) {
            const CBCharacteristicProperties properties = [characteristic properties];
            DLog(@"%@ peroperties: %x", characteristic, (int)properties);
            if (CBCharacteristicPropertyRead & properties) {
                readCharacteristic = characteristic;
//                [peripheral readValueForCharacteristic:characteristic];
            }
            if (CBCharacteristicPropertyNotify & properties) {
                if (mNotifingCharacteristic == nil) {
                    mNotifingCharacteristic = characteristic;
                    [peripheral setNotifyValue:YES forCharacteristic:mNotifingCharacteristic];
                    DLog(@"Find Notify UUID: %@", mNotifingCharacteristic);
                }
            }
            if ((CBCharacteristicPropertyWriteWithoutResponse & properties) || (CBCharacteristicPropertyWrite & properties)) {
                if (mTransferCharacteristic == nil ) {
                    mTransferCharacteristic = characteristic;
                    if (pwdString) {
                        NSLog(@"发送密码: %@", pwdData);
                        if ([[UIDevice currentDevice].systemVersion doubleValue] < 10.0) {
                            [NSThread sleepForTimeInterval:2];
                        }
                        [peripheral writeValue:pwdData forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                    } else {
                        _shouldSendOpenCommand = YES;
                        [self sendOpenCommandIfPossible];
                    }
                }
            }
        }
    }
}

// 设备返回信息的回调函数
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        DLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    STOP_TIMER(_responseTimeoutTimer);
    
    if (_timeout) {
        return;
    }

    NSData * data = characteristic.value;
    NSLog(@" ******* %@",data);
    char *str = (char *)[data bytes];
    if (str == nil) {
        return;
    }
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"string111: \n%@ length: %d",string, (int)string.length);
    
    if (string) {
        [_receivedString appendString:string];
        NSLog(@"_receivedString:\n%@", _receivedString);
    }
    
    if (!self.isSave) {
        if (isRandom) {
            //判断随机数是否正确
            NSString *repStr = [self fan_dataToHexString:data];
//            if ([repStr isEqualToString:@"53696c69636f6e204c616273"] || [repStr isEqualToString:@"02"]) {
//                return;
//            }
            if ([repStr hasPrefix:@"41555448"]) {
                NSString *randomStr = [[repStr substringWithRange:NSMakeRange(repStr.length-12, 12)] uppercaseString];
                //随机数不对时断开连接
                if (![randomStr isEqualToString:string_random]) {
                    [self disconnect];
                    self.pwdError = YES;
                    self.shouldDisconnect = NO;
                    [self showAlertControllerAndPopWithTitle:LS(@"PIN Code failed")];
                    return;
                }
                string_pinData = nil;
                isRandom = NO;
                _shouldSendOpenCommand = YES;
                [self sendOpenCommandIfPossible];
                return;
            } else {
                [self disconnect];
                self.pwdError = YES;
                self.shouldDisconnect = NO;
                [self showAlertControllerAndPopWithTitle:LS(@"PIN Code failed")];
                return;
            }
        }
        
        if (shouldQuery) {
            if ((CFG_MODULE_QUERY_TLM == btCfgState) && [string isEqualToString:@"\r\nERROR\r\n"]) {
                _parameterValues[4] = @NO;
            }
            // 广播间隔
            if ([_receivedString rangeOfString:@"ADVIN="].location != NSNotFound) {
                NSArray *vinArr = [_receivedString componentsSeparatedByString:@"ADVIN="];
                if ([vinArr.lastObject rangeOfString:@"\r"].location != NSNotFound) {
                    NSString *vinStr = [vinArr.lastObject substringToIndex:[vinArr.lastObject rangeOfString:@"\r"].location];
                    [_parameterValues replaceObjectAtIndex:3 withObject:vinStr];
                }
            }
            if ([_receivedString rangeOfString:@"NAME="].location != NSNotFound) {
                NSArray *nameArray = [_receivedString componentsSeparatedByString:@"NAME="];
                NSArray *nameArray2 = [nameArray[1] componentsSeparatedByString:@"\r\n"];
                
                if (0 < nameArray2.count) {
                    mPeripheralWrapper.name = nameArray2[0];
                    _parameterValues[2] = mPeripheralWrapper.name;
                }
            }
            if ([_receivedString rangeOfString:@"PIN="].location != NSNotFound) {
                NSArray *pinArray = [_receivedString componentsSeparatedByString:@"PIN="];
                NSArray *pinArray2 = [pinArray[1] componentsSeparatedByString:@"\r\n"];
                
                if (0 < pinArray2.count) {
                    pwdString = pinArray2[0];
                    _parameterValues[5] = pwdString;
                }
            }
            if ([_receivedString rangeOfString:@"TLM="].location != NSNotFound) {
                NSArray *tlmArray = [_receivedString componentsSeparatedByString:@"TLM="];
                NSArray *tlmArray2 = [tlmArray[1] componentsSeparatedByString:@"\r\n"];
                
                if (0 < tlmArray2.count) {
                    _parameterValues[4] = tlmArray2[0];
                }
            }
            if ([_receivedString rangeOfString:@"TXPOWER="].location != NSNotFound) {
                NSArray *txPowerArr = [_receivedString componentsSeparatedByString:@"TXPOWER="];
                if ([txPowerArr.lastObject rangeOfString:@"\r"].location != NSNotFound) {
                    NSString *txPowerStr = [txPowerArr.lastObject substringToIndex:[txPowerArr.lastObject rangeOfString:@"\r"].location];
                    
                    if ([[_device modelName] isEqualToString:@"BP671"]) {
                        CGFloat value = [txPowerStr floatValue];
                        
                        if (7.0 == value) {
                            value = 0.f;
                        } else {
                            value /= 10.f;
                        }
                        
                        NSString *stringValue = [NSString stringWithFormat:@"%.1f", value];
                        
                        if (6 < _parameterValues.count) {
                            [_parameterValues replaceObjectAtIndex:6 withObject:stringValue];
                        } else {
                            [_parameterValues addObject:stringValue];
                        }
                    } else {
                        NSInteger powerValue = [[self numberHexString:txPowerStr] integerValue];
                        if (powerValue < _device.txPowers.count) {
                            NSString *txPowerStr_new = _device.txPowers[powerValue];
                            [_parameterValues replaceObjectAtIndex:6 withObject:txPowerStr_new];
                        }
                    }
                }
            }
            if ([_receivedString rangeOfString:@"GSCFG="].location != NSNotFound) {
                NSArray *gsArr = [_receivedString componentsSeparatedByString:@"GSCFG="];
                if ([gsArr.lastObject rangeOfString:@"\r"].location != NSNotFound) {
                    NSString *gsStr = [gsArr.lastObject substringToIndex:[gsArr.lastObject rangeOfString:@"\r"].location];
                    NSMutableArray *gsArr_temp = [[gsStr componentsSeparatedByString:@","] mutableCopy];
                    NSLog(@"gsArr_temp: %@", gsArr_temp);
                    [_parameterValues replaceObjectAtIndex:_parameterValues.count-2 withObject:gsArr_temp];
                }
            }
            if ([_receivedString rangeOfString:@"KEYCFG="].location != NSNotFound) {
                NSArray *keyArr = [_receivedString componentsSeparatedByString:@"KEYCFG="];
                if ([keyArr.lastObject rangeOfString:@"\r"].location != NSNotFound) {
                    NSString *keyStr = [keyArr.lastObject substringToIndex:[keyArr.lastObject rangeOfString:@"\r"].location];
                    NSMutableArray *keyArr_temp = [[keyStr componentsSeparatedByString:@","] mutableCopy];
                    NSLog(@"keyArr_temp: %@", keyArr_temp);
                    [_parameterValues replaceObjectAtIndex:_parameterValues.count-1 withObject:keyArr_temp];
                }
            }
            
            //$OK,Opened$ -- OK
            if ([_receivedString rangeOfString:@"\r\nOK\r\n"].location != NSNotFound) {
                NSArray *stringArray = [_receivedString componentsSeparatedByString:@"+BADVDATA=,"];
                
                for (int i = 0; i < stringArray.count; i++) {
                    if ([stringArray[i] rangeOfString:@"0201061AFF4C0002"].location != NSNotFound) {
                        NSLog(@"找到ibeacon了");
                        NSString *newStr = [stringArray[i] substringFromIndex:[stringArray[i] rangeOfString:@"0201061AFF4C0002"].location+16];
                        NSArray *arr = [newStr componentsSeparatedByString:@","];
                        if ([arr.firstObject length] >= 42) {
                            NSLog(@"arr.firstObject: %@", arr.firstObject);
                            
                            // 此字节代表后面有多少位有效字节
                            NSString *lengthStr = [newStr substringToIndex:2];
                            lengthStr = [NSString stringWithFormat:@"%ld",strtoul([lengthStr UTF8String],0,16)];
                            NSLog(@"lengthStr: %@", lengthStr);
                            // uuid,major,minor,power...
                            NSString *beaconStr = [newStr substringWithRange:NSMakeRange(2,[lengthStr integerValue]*2)];
                            NSLog(@"beaconStr: %@", beaconStr);
                            // uuid
                            NSString *uuidStr = [beaconStr substringToIndex:32];
                            mPeripheralWrapper.uuid = uuidStr;
                            // major
                            NSString *majorStr = [beaconStr substringWithRange:NSMakeRange(32, 4)];
                            majorStr = [NSString stringWithFormat:@"%ld",strtoul([majorStr UTF8String],0,16)];
                            mPeripheralWrapper.major = majorStr;
                            // minor
                            NSString *minorStr = [beaconStr substringWithRange:NSMakeRange(36, 4)];
                            minorStr = [NSString stringWithFormat:@"%ld",strtoul([minorStr UTF8String],0,16)];
                            mPeripheralWrapper.minor = minorStr;
                            // power
                            NSString *powerStr = [beaconStr substringWithRange:NSMakeRange(40, 2)];
                            NSNumber *number = [self signedHexTurnString:[NSData dataForHexString:powerStr]];
                            powerStr = [NSString stringWithFormat:@"%@",number];
                            mPeripheralWrapper.ibeaconPower = powerStr;
                            NSString *beaconEnableStr = [arr[1] substringWithRange:NSMakeRange(0, 1)];
                            mPeripheralWrapper.beaconEnable = [beaconEnableStr isEqualToString:@"1"] ? YES : NO;
                            
                            NSString *sectionStr = [stringArray[i] substringWithRange:NSMakeRange([stringArray[i] rangeOfString:@"0201061AFF4C0002"].location - 2, 1)];
                            NSLog(@"sectionStr: %@", sectionStr);
                            if (![sectionNumberArrM containsObject:sectionStr]) {
                                [sectionNumberArrM addObject:sectionStr];
                                NSMutableArray *beaconArrM = [[NSMutableArray alloc] init];
                                NSMutableArray *beaconModel = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"",@"", nil];
                                [beaconModel replaceObjectAtIndex:0 withObject:uuidStr];
                                [beaconModel replaceObjectAtIndex:1 withObject:majorStr];
                                [beaconModel replaceObjectAtIndex:2 withObject:minorStr];
                                [beaconModel replaceObjectAtIndex:3 withObject:powerStr];
                                [beaconModel replaceObjectAtIndex:4 withObject:beaconEnableStr];
                                // 数据与textlabel的数组
                                [beaconArrM addObject:iBeaconArray];
                                [beaconArrM addObject:deleteArrayM.firstObject];
                                [beaconArrM addObject:beaconModel];
                                
                                [equipmentDataArray addObject:beaconArrM];
                                
                            }
                            
                        }
                        
                    }
                    if ([stringArray[i] rangeOfString:@"16AAFE10"].location != NSNotFound) {
                        NSLog(@"找到url了");
                        NSString *urlStr = [stringArray[i] substringFromIndex:[stringArray[i] rangeOfString:@"16AAFE10"].location+8];
                        NSArray *urlArr = [urlStr componentsSeparatedByString:@","];
                        NSString *urlPowerStr = [urlArr.firstObject substringToIndex:2];
                        //                    urlPowerStr = [NSString stringWithFormat:@"%ld",strtoul([urlPowerStr UTF8String],0,16)];
                        NSNumber *number = [self signedHexTurnString:[NSData dataForHexString:urlPowerStr]];
                        urlPowerStr = [NSString stringWithFormat:@"%@",number];
                        mPeripheralWrapper.urlPower = urlPowerStr;
                        NSString *urlAddressStr = [urlArr.firstObject substringFromIndex:2];
                        urlAddressStr = [self getAddress:urlAddressStr];
                        if ([urlAddressStr hasSuffix:@"http://www."]) {
                            urlAddressStr = @"https://www.feasycom.com";
                        }
                        mPeripheralWrapper.url = urlAddressStr;
                        NSString *urlEnableStr = [urlArr[1] substringWithRange:NSMakeRange(0, 1)];
                        mPeripheralWrapper.urlEnable = [urlEnableStr isEqualToString:@"1"] ? YES : NO;
                        
                        NSString *urlSectionStr = [stringArray[i] substringWithRange:NSMakeRange([stringArray[i] rangeOfString:@"16AAFE10"].location-18, 1)];
                        if (![urlSectionNumberArrM containsObject:urlSectionStr]) {
                            [urlSectionNumberArrM addObject:urlSectionStr];
                            NSMutableArray *urlArrM = [[NSMutableArray alloc] init];
                            NSMutableArray *urlModel = [[NSMutableArray alloc] initWithObjects:@"",@"",@"", nil];
                            [urlModel replaceObjectAtIndex:0 withObject:urlAddressStr];
                            [urlModel replaceObjectAtIndex:1 withObject:urlPowerStr];
                            [urlModel replaceObjectAtIndex:2 withObject:urlEnableStr];
                            
                            [urlArrM addObject:urlArray];
                            [urlArrM addObject:deleteArrayM[1]];
                            [urlArrM addObject:urlModel];
                            [equipmentDataArray addObject:urlArrM];
                        }
                        
                    }
                    if ([stringArray[i] rangeOfString:@"16AAFE00"].location != NSNotFound) {
                        NSLog(@"找到uid了");
                        if ([stringArray[i] substringFromIndex:[stringArray[i] rangeOfString:@"16AAFE00"].location+8].length>=38) {
                            
                            NSString *newStr = [stringArray[i] substringFromIndex:[stringArray[i] rangeOfString:@"16AAFE00"].location+8];
                            NSArray *uidArr = [newStr componentsSeparatedByString:@","];
                            NSString *uidStr = uidArr.firstObject;
                            NSString *uidPower = [uidStr substringToIndex:2];
                            NSString *nameSpaceStr = [uidStr substringWithRange:NSMakeRange(2, 20)];
                            NSString *instanceStr = [uidStr substringWithRange:NSMakeRange(22, 12)];
                            NSString *reservedStr = [uidStr substringWithRange:NSMakeRange(34, 4)];
                            NSNumber *number = [self signedHexTurnString:[NSData dataForHexString:uidPower]];
                            uidPower = [NSString stringWithFormat:@"%@",number];
                            mPeripheralWrapper.uidPower = uidPower;
                            mPeripheralWrapper.namespaceStr = nameSpaceStr;
                            mPeripheralWrapper.instance = instanceStr;
                            mPeripheralWrapper.reserved = reservedStr;
                            NSString *uidEnableStr = [uidArr[1] substringWithRange:NSMakeRange(0, 1)];
                            mPeripheralWrapper.uidEnable = [uidEnableStr isEqualToString:@"1"] ? YES : NO;
                            
                            NSString *uidSectionStr = [stringArray[i] substringWithRange:NSMakeRange([stringArray[i] rangeOfString:@"16AAFE00"].location-18, 1)];
                            if (![uidSectionNumberArrM containsObject:uidSectionStr]) {
                                [uidSectionNumberArrM addObject:uidSectionStr];
                                NSMutableArray *uidArrM = [[NSMutableArray alloc] init];
                                NSMutableArray *uidModel = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"",@"", nil];
                                [uidModel replaceObjectAtIndex:0 withObject:nameSpaceStr];
                                [uidModel replaceObjectAtIndex:1 withObject:instanceStr];
                                [uidModel replaceObjectAtIndex:2 withObject:reservedStr];
                                [uidModel replaceObjectAtIndex:3 withObject:uidPower];
                                [uidModel replaceObjectAtIndex:4 withObject:uidEnableStr];
                                
                                [uidArrM addObject:uidArray];
                                [uidArrM addObject:deleteArrayM[2]];
                                [uidArrM addObject:uidModel];
                                [equipmentDataArray addObject:uidArrM];
                            }
                            
                        }
                    }
                    
                    if ([stringArray[i] rangeOfString:@"0201061BFF"].location != NSNotFound) {
                        NSLog(@"找到AltBeacon了");
                        if ([stringArray[i] substringFromIndex:[stringArray[i] rangeOfString:@"0201061BFF"].location+10].length>=56) {
                            NSString *altBeacon = [stringArray[i] substringFromIndex:[stringArray[i] rangeOfString:@"0201061BFF"].location+10];
                            NSString *mfgID = [altBeacon substringWithRange:NSMakeRange(0, 4)];
                            mfgID = [NSString stringWithFormat:@"%ld",strtoul([mfgID UTF8String],0,16)];
                            NSString *uuidStr = [altBeacon substringWithRange:NSMakeRange(8, 32)];
                            NSString *majorStr = [altBeacon substringWithRange:NSMakeRange(40, 4)];
//                            majorStr = [NSString stringWithFormat:@"%ld",strtoul([majorStr UTF8String],0,16)];
                            NSString *minorStr = [altBeacon substringWithRange:NSMakeRange(44, 4)];
//                            minorStr = [NSString stringWithFormat:@"%ld",strtoul([minorStr UTF8String],0,16)];
                            NSString *rssiStr = [altBeacon substringWithRange:NSMakeRange(48, 2)];
                            NSNumber *number = [self signedHexTurnString:[NSData dataForHexString:rssiStr]];
                            rssiStr = [NSString stringWithFormat:@"%@",number];
                            NSString *reservedStr = [altBeacon substringWithRange:NSMakeRange(50, 2)];
                            NSString *altBeaconEnableStr = [altBeacon substringWithRange:NSMakeRange(52+1, 1)];
                            
                            NSString *altBeaconSectionStr = [stringArray[i] substringWithRange:NSMakeRange([stringArray[i] rangeOfString:@"0201061BFF"].location-2, 1)];
                            if (![altBeaconSectionNumberArrM containsObject:altBeaconSectionStr]) {
                                [altBeaconSectionNumberArrM addObject:altBeaconSectionStr];
                                NSMutableArray *altBeaconArrM = [[NSMutableArray alloc] init];
                                NSMutableArray *altBeaconModel = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"",@"",@"",@"", nil];
                                [altBeaconModel replaceObjectAtIndex:0 withObject:uuidStr];
                                [altBeaconModel replaceObjectAtIndex:1 withObject:majorStr];
                                [altBeaconModel replaceObjectAtIndex:2 withObject:minorStr];
                                [altBeaconModel replaceObjectAtIndex:3 withObject:rssiStr];
                                [altBeaconModel replaceObjectAtIndex:4 withObject:mfgID];
                                [altBeaconModel replaceObjectAtIndex:5 withObject:reservedStr];
                                [altBeaconModel replaceObjectAtIndex:6 withObject:altBeaconEnableStr];
                                
                                [altBeaconArrM addObject:altBeaconArray];
                                [altBeaconArrM addObject:deleteArrayM.lastObject];
                                [altBeaconArrM addObject:altBeaconModel];
                                [equipmentDataArray addObject:altBeaconArrM];
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (CFG_MODULE_SND_TLM == btCfgState && [string isEqualToString:@"\r\nERROR\r\n"]) {
        _parameterValues[4] = @NO;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if (CFG_MODULE_SND_BUZ == btCfgState && ([string isEqualToString:@"\r\nOK\r\n"] || [string isEqualToString:@"\r\nERROR\r\n"])) {
        STOP_TIMER(_queryTimeoutTimer);
        STOP_TIMER(_saveTimeoutTimer);
        [_progressHUD hideAnimated:YES];
        [self performSelector:@selector(hudDidHide) withObject:nil afterDelay:1];
        [self.tableView reloadData];
        return;
    }
    
    if (((_hasGsensor && CFG_MODULE_SND_GSCFG == btCfgState) || (!_hasGsensor && _hasKey && CFG_MODULE_SND_KEYCFG == btCfgState) || (!_hasGsensor && !_hasKey && _hasTxPower && CFG_MODULE_SND_TXPOWER == btCfgState) || (!_hasGsensor && !_hasKey && !_hasTxPower && CFG_MODULE_SND_TLM == btCfgState)) && ([string isEqualToString:@"\r\nOK\r\n"] || [string isEqualToString:@"\r\nERROR\r\n"])) {
        STOP_TIMER(_queryTimeoutTimer);
        STOP_TIMER(_saveTimeoutTimer);
        [_progressHUD hideAnimated:YES];
        
        if ([string isEqualToString:@"\r\nOK\r\n"]) {
            [self showAlertControllerAndPopWithTitle:LS(@"SET_SUCCESSFUL")];
        } else if (CFG_MODULE_SND_TLM == btCfgState) {
            [self showAlertControllerAndPopWithTitle:LS(@"SET_SUCCESSFUL")];
        } else if (CFG_MODULE_SND_GSCFG == btCfgState) {
            [self showAlertControllerAndPopWithTitle:LS(@"Saving Gsensor parameters failed")];
        } else {
            [self showAlertControllerAndPopWithTitle:LS(@"SET_FAILED")];
        }
        return;
    }
    
    [self processBTReceive:[_receivedString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // parse cmd resp when 1s not rcv data.
    _responseTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(responseTimeout) userInfo:nil repeats:NO];
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        DLog(@"Error changing notification state: %@", error.localizedDescription);
    }
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@" ---- 连接成功");
    mConnectedPeripheral = peripheral;
    mConnectedPeripheral.delegate = self;
    [mConnectedPeripheral discoverServices:nil];
    [mCentralManager stopScan];
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didFailToConnectPeripheral: %@",error);
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOff:
            NSLog(@"蓝牙未打开");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"蓝牙已打开");
        default:
            break;
    }
}
// 网址->16进制字符串
- (NSString *)HexConvertToASCII:(NSString *)hexString{
    NSString *numStr = @"";
    NSString *hexStr = @"";
    NSArray *array = [hexString componentsSeparatedByString:@"//"];
    if (array.count<2) {
        return nil;
    }
    if ([array[1] hasPrefix:@"www"]) {
        hexString = [array[1] substringFromIndex:4];
    } else {
        hexString = array[1];
    }
    NSArray *newArray = [hexString componentsSeparatedByString:@"."];
    NSString *str_sub;
    for (int i = 0; i < newArray.count; i++) {
        str_sub = newArray[i];
        if ([self getAddressTailString:[@"." stringByAppendingString:str_sub]] && [str_sub isEqualToString:newArray.lastObject]) {
            hexStr = [hexStr stringByAppendingString:[self getAddressTailString:[@"." stringByAppendingString:str_sub]]];
            break;
        }
        if ([str_sub rangeOfString:@"/"].location != NSNotFound) {
            NSString *str_new = [str_sub substringToIndex:[str_sub rangeOfString:@"/"].location];
            str_new = [str_new stringByAppendingString:@"/"];
            str_new = [self getAddressTailString:str_new];
            if (str_new) {
                hexStr = [hexStr stringByAppendingString:str_new];
                //                }
                int loca = (int)str_new.length;
                for (int j = loca+1; j < str_sub.length; j++) {
                    NSString *str1 = [str_sub substringWithRange:NSMakeRange(j, 1)];
                    unichar theChar = [str1 characterAtIndex:0];
                    numStr = [NSString stringWithFormat:@"%d",theChar];
                    numStr = [NSString getHexByDecimal:(unsigned int)[numStr integerValue]];
                    hexStr = [hexStr stringByAppendingString:numStr];
                }
            } else {
                if (i != 0) {
                    str_sub = [@"." stringByAppendingString:str_sub];
                }
                for (int i = 0; i < str_sub.length; i++) {
                    NSString *str2 = [str_sub substringWithRange:NSMakeRange(i, 1)];
                    unichar theChar = [str2 characterAtIndex:0];
                    numStr = [NSString stringWithFormat:@"%d",theChar];
                    numStr = [NSString getHexByDecimal:(unsigned int)[numStr integerValue]];
                    hexStr = [hexStr stringByAppendingString:numStr];
                }
            }
        } else {
            if (i != 0) {
                str_sub = [@"." stringByAppendingString:str_sub];
            }
            for (int i = 0; i < str_sub.length; i++) {
                NSString *str2 = [str_sub substringWithRange:NSMakeRange(i, 1)];
                unichar theChar = [str2 characterAtIndex:0];
                numStr = [NSString stringWithFormat:@"%d",theChar];
                numStr = [NSString getHexByDecimal:(unsigned int)[numStr integerValue]];
                hexStr = [hexStr stringByAppendingString:numStr];
            }
        }
    }
    
    if (hexStr.length%2) {
        hexStr = [hexStr substringToIndex:hexStr.length-1];
        return hexStr;
    }
    return hexStr;
}

// 转换地址头部
- (NSString *)transformAddressHandString:(NSString *)string {
    if ([string hasPrefix:@"https://"]) {
        if ([string hasPrefix:@"https://www."]) {
            return @"01";
        }
        return @"03";
    } else if ([string hasPrefix:@"http://"]) {
        if ([string hasPrefix:@"http://www."]) {
            return @"00";
        }
        return @"02";
    }
    return nil;
}
//
// 地址解析
- (NSString *)getAddress:(NSString *)string {
    NSString *handStr = [self getAddressHandString:string];
    NSString *bodyStr = [self getAddressFromHexString:string];
//    NSString *tailStr = [self tailStringToHexString:string];
//    if (!tailStr) {
        return [NSString stringWithFormat:@"%@%@",handStr,bodyStr];
//    }
//    return [NSString stringWithFormat:@"%@%@%@",handStr,bodyStr,tailStr];
}

// 反转地址头部
- (NSString *)getAddressHandString:(NSString *)string {
    if ([string hasPrefix:@"03"]) {
        return @"https://";
    } else if ([string hasPrefix:@"02"]) {
        return @"http://";
    } else if ([string hasPrefix:@"01"]) {
        return @"https://www.";
    } else if ([string hasPrefix:@"00"]) {
        return @"http://www.";
    }
    return nil;
}

// 16进制字符串->网址
- (NSString *)getAddressFromHexString:(NSString *)string {
    NSString *str = @"";
    NSString *newStr = @"";
    string = [string substringWithRange:NSMakeRange(2, string.length-2)];
    for (int i = 0; i < string.length/2; i++) {
        str = [string substringWithRange:NSMakeRange(i*2, 2)];
        NSString *str1 = [NSString stringWithFormat:@"%ld",strtoul([str UTF8String],0,16)];
        str1 = [self hexStringChange:str1];
        if ([str1 intValue] >= 0 && [str1 intValue] <= 13) {
            if (str1.length == 1) {
                str1 = [@"0" stringByAppendingString:str1];
            }
            str1 = [self tailStringToHexString:str1];
            newStr = [newStr stringByAppendingString:str1];
        } else {
            str = [NSString stringWithFormat:@"%ld",strtoul([str UTF8String],0,16)];
            str = [NSString stringWithFormat:@"%c",[str intValue]];
            newStr = [newStr stringByAppendingString:str];
        }
    }
    return newStr;
}


// 转换地址尾部
- (NSString *)getAddressTailString:(NSString *)string {
    if ([string hasSuffix:@".com/"]) {
        return @"00";
    } else if ([string hasSuffix:@".org/"]) {
        return @"01";
    } else if ([string hasSuffix:@".edu/"]) {
        return @"02";
    } else if ([string hasSuffix:@".net/"]) {
        return @"03";
    } else if ([string hasSuffix:@".info/"]) {
        return @"04";
    } else if ([string hasSuffix:@".biz/"]) {
        return @"05";
    } else if ([string hasSuffix:@".gov/"]) {
        return @"06";
    } else if ([string hasSuffix:@".com"]) {
        return @"07";
    } else if ([string hasSuffix:@".org"]) {
        return @"08";
    } else if ([string hasSuffix:@".edu"]) {
        return @"09";
    } else if ([string hasSuffix:@".net"]) {
        return @"0A";
    } else if ([string hasSuffix:@".info"]) {
        return @"0B";
    } else if ([string hasSuffix:@".biz"]) {
        return @"0C";
    } else if ([string hasSuffix:@".gov"]) {
        return @"0D";
    }
    return nil;
}

// 后缀->16进制
- (NSString *)tailStringToHexString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return nil;
    }
    NSString *lastStr = [string substringWithRange:NSMakeRange(string.length-2, 2)];
    if ([lastStr isEqualToString:@"00"]) {
        return @".com/";
    } else if ([lastStr isEqualToString:@"01"]) {
        return @".org/";
    } else if ([lastStr isEqualToString:@"02"]) {
        return @".edu/";
    } else if ([lastStr isEqualToString:@"03"]) {
        return @".net/";
    } else if ([lastStr isEqualToString:@"04"]) {
        return @".info/";
    } else if ([lastStr isEqualToString:@"05"]) {
        return @".biz/";
    } else if ([lastStr isEqualToString:@"06"]) {
        return @".gov/";
    } else if ([lastStr isEqualToString:@"07"]) {
        return @".com";
    } else if ([lastStr isEqualToString:@"08"]) {
        return @".org";
    } else if ([lastStr isEqualToString:@"09"]) {
        return @".edu";
    } else if ([lastStr isEqualToString:@"0A"]) {
        return @".net";
    } else if ([lastStr isEqualToString:@"0B"]) {
        return @".info";
    } else if ([lastStr isEqualToString:@"0C"]) {
        return @".biz";
    } else if ([lastStr isEqualToString:@"0D"]) {
        return @".gov";
    } else {
        return nil;
    }
}

- (NSString *)hexStringChange:(NSString *)hexString {
    if ([hexString isEqualToString:@"10"]) {
        return @"0A";
    } else if ([hexString isEqualToString:@"11"]) {
        return @"0B";
    } else if ([hexString isEqualToString:@"12"]) {
        return @"0C";
    } else if ([hexString isEqualToString:@"13"]) {
        return @"0D";
    } else {
        return hexString;
    }
}

//有符号16进制data转10进制
- (NSNumber *)signedHexTurnString:(NSData *)data
{
    NSLog(@"%@", data);
    if (!data)
    {
        return nil;
    }
    //获取data的长度
    NSInteger lenth = [data length];
    //获取16进制最大值
    NSString *maxHexString = [self headString:@"F" trilString:@"F" strLenth:lenth];
    //获取16进制分界点
    NSString *centerHexString = [self headString:@"8" trilString:@"0" strLenth:lenth];
    //获取data字符串
    NSString *string = [self fan_dataToHexString:data];
    
    if ([[self numberHexString:string] longLongValue] - [[self numberHexString:centerHexString] longLongValue] < 0) {
        return [self numberHexString:string];
    }
    return [NSNumber numberWithLongLong:[[self numberHexString:string] longLongValue] - [[self numberHexString:maxHexString] longLongValue]-1];
}
-(NSString *)headString:(NSString *)headStr trilString:(NSString *)trilStr strLenth:(NSInteger)lenth
{
    if (!headStr || !trilStr)
    {
        return nil;
    }
    //16进制获取最大值  和16进制有符号分界点
    NSMutableString *string = [NSMutableString stringWithFormat:@"0x%@", headStr];
    for (int i = 0; i < lenth * 2 - 1; i++)
    {
        [string appendString:trilStr];
    }
    return string;
}
// 16进制转10进制
- (NSNumber *)numberHexString:(NSString *)aHexString{
    // 为空,直接返回.
    if (nil == aHexString) {
        return nil;
    }
    NSScanner *scanner = [NSScanner scannerWithString:aHexString];
    unsigned long long longlongValue;
    [scanner scanHexLongLong:&longlongValue];
    //将整数转换为NSNumber,存储到数组中,并返回.
    NSNumber *hexNumber = [NSNumber numberWithLongLong:longlongValue];
    return hexNumber;
}

// 间隔
- (NSInteger)getInterval:(NSInteger)interval {
    switch (interval) {
        case 100:
            return 100;
            break;
        case 150:
            return 152;
            break;
        case 200:
            return 211;
            break;
        case 300:
            return 318;
            break;
        case 400:
            return 417;
            break;
        case 550:
            return 546;
            break;
        case 750:
            return 760;
            break;
        case 850:
            return 852;
            break;
        case 1000:
            return 1022;
            break;
        case 1300:
            return 1285;
            break;
        case 2000:
            return 2000;
            break;
        default:
            return 0;
            break;
    }
}

// 反馈的间隔
- (NSInteger)reciveInterval:(NSInteger)interval {//BROADCAST_GSENSOR_REVICE
    if (interval < 1) {
        return 0;
    }
    for (int i=0; i<NELEM(BROADCAST_STATE_MS); i++) {
        if (interval == BROADCAST_STATE_MS[i]) {
            return interval;
        }
        if (interval < BROADCAST_STATE_MS[i]) {
            if (i != 0) {
                if ((BROADCAST_STATE_MS[i] - BROADCAST_STATE_MS[i-1])/2.0 > (BROADCAST_STATE_MS[i] - interval)) {
                    return BROADCAST_STATE_MS[i];
                } else {
                    return BROADCAST_STATE_MS[i-1];
                }
            } else {
                return BROADCAST_STATE_MS[i];
            }
        }
    }
    return 0;
}

// 反馈的间隔
- (NSInteger)reciveInterval_led:(NSInteger)interval {
    if (interval < 1) {
        return 0;
    }
    for (int i=0; i<NELEM(BROADCAST_LED_MS); i++) {
        if (interval == BROADCAST_LED_MS[i]) {
            return interval;
        }
        if (interval < BROADCAST_LED_MS[i]) {
            if (i != 0) {
                if ((BROADCAST_LED_MS[i] - BROADCAST_LED_MS[i-1])/2.0 > (BROADCAST_LED_MS[i] - interval)) {
                    return BROADCAST_LED_MS[i];
                } else {
                    return BROADCAST_LED_MS[i-1];
                }
            } else {
                return BROADCAST_LED_MS[i];
            }
        }
    }
    return 0;
}

// 反馈的间隔
- (NSInteger)reciveGsensorInterval:(NSInteger)interval {
    if (interval < 1) {
        return 0;
    }
    for (int i=0; i<NELEM(BROADCAST_GSENSOR_REVICE); i++) {
        if (interval == BROADCAST_GSENSOR_REVICE[i]) {
            return interval;
        }
        if (interval < BROADCAST_GSENSOR_REVICE[i]) {
            if (i != 0) {
                if ((BROADCAST_GSENSOR_REVICE[i] - BROADCAST_GSENSOR_REVICE[i-1])/2.0 > (BROADCAST_GSENSOR_REVICE[i] - interval)) {
                    return BROADCAST_GSENSOR_REVICE[i];
                } else {
                    return BROADCAST_GSENSOR_REVICE[i-1];
                }
            } else {
                return BROADCAST_GSENSOR_REVICE[i];
            }
        }
    }
    return 0;
}

// 发送的间隔
- (NSInteger)sendInterval:(NSInteger)interval {
    if (interval < 1) {
        return 0;
    }
    for (int i=0; i<NELEM(BROADCAST_INTERVAL_SEND); i++) {
        if (interval == BROADCAST_INTERVAL_SEND[i]) {
            return interval;
        }
        if (interval < BROADCAST_INTERVAL_SEND[i]) {
            if (i != 0) {
                if ((BROADCAST_INTERVAL_SEND[i] - BROADCAST_INTERVAL_SEND[i-1])/2.0 > (BROADCAST_INTERVAL_SEND[i] - interval)) {
                    return BROADCAST_INTERVAL_SEND[i];
                } else {
                    return BROADCAST_INTERVAL_SEND[i-1];
                }
            } else {
                return BROADCAST_INTERVAL_SEND[i];
            }
        }
    }
    return 0;
}

// 发送的间隔
- (NSInteger)sendInterval_led:(NSInteger)interval {
    if (interval < 1) {
        return 0;
    }
    for (int i=0; i<NELEM(BROADCAST_STATE_SEND); i++) {
        if (interval == BROADCAST_STATE_SEND[i]) {
            return interval;
        }
        if (interval < BROADCAST_STATE_SEND[i]) {
            if (i != 0) {
                if ((BROADCAST_STATE_SEND[i] - BROADCAST_STATE_SEND[i-1])/2.0 > (BROADCAST_STATE_SEND[i] - interval)) {
                    return BROADCAST_STATE_SEND[i];
                } else {
                    return BROADCAST_STATE_SEND[i-1];
                }
            } else {
                return BROADCAST_STATE_SEND[i];
            }
        }
    }
    return 0;
}


#pragma mark - timer hander
- (void)responseTimeout {
    [self stopAllTimers];
    
    if (!_timeout) {
        _timeout = YES;
        
        [_progressHUD hideAnimated:YES];
        [self showAlertControllerAndPopWithTitle:LS(_isSave ? @"Save parameters timeout" : @"Query parameters timeout")];
        [self performSelector:@selector(hudDidHide) withObject:nil afterDelay:1];
    }
    
}

- (void)hudDidHide {
    self.tableView.userInteractionEnabled = YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.returnKeyType = UIReturnKeyDone;
    [textField resignFirstResponder];
    return YES;
}

//移动UIView
-(void)transformView:(NSNotification *)aNSNotification
{
    //获取键盘弹出前的Rect
    NSValue *keyBoardBeginBounds=[[aNSNotification userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyBoardBeginBounds CGRectValue];

    //获取键盘弹出后的Rect
    NSValue *keyBoardEndBounds = [[aNSNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect  endRect = [keyBoardEndBounds CGRectValue];

    //获取键盘位置变化前后纵坐标Y的变化值
    CGFloat deltaY = endRect.origin.y-beginRect.origin.y;
//    NSLog(@"弹起时看看这个变化的Y值:%f",deltaY);
//    NSLog(@"弹起时rect = %d",self.rect);
    if (self.rect < deltaY) {
        [UIView animateWithDuration:0.25f animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+deltaY, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    }
}
//键盘回收
-(void)keyboardWillDisappear:(NSNotification *)notification {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (void)dealloc {
    NSLog(@"销毁通知");
    [_progressHUD hideAnimated:NO];
    isFirst = YES;
    isDisconnected = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [mCentralManager setDelegate:nil];
}


@end

