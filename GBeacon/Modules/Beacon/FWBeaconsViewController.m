//
//  FWBeaconsViewController.m
//  FeasyBeacon
//
//  Created by LIDONG on 14-2-28.
//  Copyright (c) 2014年 LIDONG. All rights reserved.
//

#import "FWBeaconsViewController.h"
#import "FWFilterViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "FWCentralIBeaconCell.h"
#import "FWCentralURLBeaconCell.h"
#import "FWCentralUIDBeaconCell.h"
#import "FWCentralTLMBeaconCell.h"
#import "FWCentralAltBeaconCell.h"
#import "NSString+HexStringToData.h"
#import <YYModel/YYModel.h>
#import "MJRefresh.h"
#import "NSData+DataToHexString.h"
#import "FWADView.h"
#import "FBCentrallBP104ELCell.h"
#import "FBSDKPublicHeader.h"
#import "FBBeaconUUIDConfigVC.h"
#import "FBBeaconBroadcastVC.h"

@interface FWBeaconsViewController () <UITableViewDataSource, UITableViewDelegate, FBBluetoothBrowserDelegate>

@property (nonatomic, strong) FBBluetoothBrowser *bluetoothBrowser;
@property (nonatomic, strong) NSTimer *refreshRSSITimer;


@end

@implementation FWBeaconsViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.bluetoothBrowser = [[FBBluetoothBrowser alloc] initWithType:FBBluetoothBrowserTypeBeacon];
        [self.bluetoothBrowser setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationView];
    
    // tableView
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerNib:[UINib nibWithNibName:@"FWCentralIBeaconCell" bundle:nil] forCellReuseIdentifier:@"FWCentralIBeaconCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FWCentralURLBeaconCell" bundle:nil] forCellReuseIdentifier:@"FWCentralURLBeaconCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FWCentralUIDBeaconCell" bundle:nil] forCellReuseIdentifier:@"FWCentralUIDBeaconCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FWCentralTLMBeaconCell" bundle:nil] forCellReuseIdentifier:@"FWCentralTLMBeaconCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FWCentralAltBeaconCell" bundle:nil] forCellReuseIdentifier:@"FWCentralAltBeaconCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FBCentrallBP104ELCell" bundle:nil] forCellReuseIdentifier:@"FBCentrallBP104ELCell"];
    
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.bluetoothBrowser startScanning];
        [strongSelf.tableView.mj_header endRefreshing];
    }];
    
    // 广告页显示
    [FWADView showWithSeconds:5];
    usleep(100);
}

- (void)setupNavigationView {
    
    self.title = @"Beacon";
    
    if (@available(iOS 13.0, *)) {
        NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                  NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]};
        
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor darkGrayColor];
        appearance.titleTextAttributes = dic;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    // 透明
    self.navigationController.navigationBar.translucent = YES;
    // navigation控件颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // navigation
    UINavigationItem *navigationItem = [self navigationItem];
    
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general_icon_sort"] style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonPressed)];
    
    UIBarButtonItem *broadcastItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general_icon_broadcast"] style:UIBarButtonItemStylePlain target:self action:@selector(broadcastItemAction)];
    
    [navigationItem setLeftBarButtonItems:@[sortItem, broadcastItem]];
//    [navigationItem setLeftBarButtonItem:sortItem];
    
    UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general_icon_filter"] style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonPressed)];
    
    UIBarButtonItem *showUUIDItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"UUID") style:UIBarButtonItemStylePlain target:self action:@selector(showUUIDItemAction)];
    [navigationItem setRightBarButtonItems:@[filterItem, showUUIDItem]];
//    [navigationItem setRightBarButtonItems:@[filterItem]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.refreshRSSITimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshRSSI) userInfo:nil repeats:YES];
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.bluetoothBrowser stopScanning];
    if (self.refreshRSSITimer) {
        [self.refreshRSSITimer invalidate];
        self.refreshRSSITimer = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

// 刷新信号值UI
- (void)refreshRSSI {
    const NSInteger count = self.bluetoothBrowser.peripheralItems.count;
    for (NSInteger i = 0; i < count; i++) {
        FWCentralURLBeaconCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if ([cell respondsToSelector:@selector(refreshRSSI:)]) {
//            [cell refreshRSSI:[self.bluetoothBrowser.peripheralItems[i] RSSI]];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.bluetoothBrowser.peripheralItems.count;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FBPeripheralItem *peripheralItem = self.bluetoothBrowser.peripheralItems[section];
    
    UIView * bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor lightGrayColor];
    if (peripheralItem.lastestBeacon.type == FBBeaconTypeIBeacon) {
        UILabel *deviceName = [[UILabel alloc] init];
        deviceName.text = @"iBeacon";
        deviceName.font = [UIFont systemFontOfSize:17];
        deviceName.textAlignment = NSTextAlignmentLeft;
        [bgView addSubview:deviceName];
        [deviceName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_top).offset(10);
            make.left.mas_equalTo(bgView.mas_left).offset(10);
        }];
        
        UILabel *accuracyLabel = [[UILabel alloc] init];
        accuracyLabel.text = [NSString stringWithFormat:@"%.1f m", peripheralItem.lastestBeacon.accuracy];
        accuracyLabel.font = [UIFont systemFontOfSize:14];
        accuracyLabel.textAlignment = NSTextAlignmentLeft;
        [bgView addSubview:accuracyLabel];
        [accuracyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(deviceName.mas_bottom).offset(5);
            make.left.mas_equalTo(bgView.mas_left).offset(10);
        }];
        
        UILabel *proximityTypeLabel = [[UILabel alloc] init];
        NSString *proximityMessage = @"";
        if (FBProximityTypeUnknown == peripheralItem.lastestBeacon.proximityType) {
            proximityMessage = @"Unknow";
        } else if (FBProximityTypeImmediate == peripheralItem.lastestBeacon.proximityType) {
            proximityMessage = @"Immediate";
        } else if (FBProximityTypeNear == peripheralItem.lastestBeacon.proximityType) {
            proximityMessage = @"Near";
        } else if (FBProximityTypeFar == peripheralItem.lastestBeacon.proximityType) {
            proximityMessage = @"Far";
        }
        proximityTypeLabel.text = [NSString stringWithFormat:@"(%@)", proximityMessage];
        proximityTypeLabel.font = [UIFont systemFontOfSize:14];
        proximityTypeLabel.textAlignment = NSTextAlignmentLeft;
        [bgView addSubview:proximityTypeLabel];
        [proximityTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(deviceName.mas_bottom).offset(5);
            make.left.mas_equalTo(accuracyLabel.mas_right).offset(2);
        }];
        
        UILabel *rssiValue = [[UILabel alloc] init];
        rssiValue.text = [NSString stringWithFormat:@"%lddBm", (long)peripheralItem.RSSI];
        rssiValue.font = [UIFont systemFontOfSize:14];
        rssiValue.textAlignment = NSTextAlignmentRight;
        [bgView addSubview:rssiValue];
        [rssiValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_top).offset(10);
            make.right.mas_equalTo(bgView.mas_right).offset(-10);
            make.width.mas_equalTo(60);
        }];
        
        UILabel *intervalLabel = [[UILabel alloc] init];
        intervalLabel.text = [NSString stringWithFormat:@"<->%.0lfms", peripheralItem.advertisementRate / 1000.0];
        intervalLabel.font = [UIFont systemFontOfSize:14];
        intervalLabel.textAlignment = NSTextAlignmentRight;
        [bgView addSubview:intervalLabel];
        [intervalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_top).offset(10);
            make.right.mas_equalTo(rssiValue.mas_left).offset(-10);
            make.width.mas_equalTo(100);
        }];
    } else {
        UILabel *deviceName = [[UILabel alloc] init];
        deviceName.text = peripheralItem.displayedName;
        deviceName.font = [UIFont systemFontOfSize:17];
        deviceName.textAlignment = NSTextAlignmentLeft;
        [bgView addSubview:deviceName];
        [deviceName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_top).offset(10);
            make.left.mas_equalTo(bgView.mas_left).offset(10);
        }];
        
        UILabel *deviceMac = [[UILabel alloc] init];
        deviceMac.text = peripheralItem.macAddress;
        deviceMac.font = [UIFont systemFontOfSize:14];
        deviceMac.textAlignment = NSTextAlignmentLeft;
        [bgView addSubview:deviceMac];
        [deviceMac mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(deviceName.mas_bottom).offset(5);
            make.left.mas_equalTo(bgView.mas_left).offset(10);
        }];
        
        UILabel *rssiValue = [[UILabel alloc] init];
        rssiValue.text = [NSString stringWithFormat:@"%lddBm", (long)peripheralItem.RSSI];
        rssiValue.font = [UIFont systemFontOfSize:14];
        rssiValue.textAlignment = NSTextAlignmentRight;
        [bgView addSubview:rssiValue];
        [rssiValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_top).offset(10);
            make.right.mas_equalTo(bgView.mas_right).offset(-10);
            make.width.mas_equalTo(60);
        }];
        
        UILabel *intervalLabel = [[UILabel alloc] init];
        intervalLabel.text = [NSString stringWithFormat:@"<->%.0lfms", peripheralItem.advertisementRate / 1000.0];
        intervalLabel.font = [UIFont systemFontOfSize:14];
        intervalLabel.textAlignment = NSTextAlignmentRight;
        [bgView addSubview:intervalLabel];
        [intervalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_top).offset(10);
            make.right.mas_equalTo(rssiValue.mas_left).offset(-10);
            make.width.mas_equalTo(100);
        }];
    }
    
    return bgView;;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    FBPeripheralItem *peripheralItem = self.bluetoothBrowser.peripheralItems[section];
    return peripheralItem.beacons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FBPeripheralItem *item = self.bluetoothBrowser.peripheralItems[indexPath.section];
    BOOL isIBeacon = item.lastestBeacon.type == FBBeaconTypeIBeacon;
    if (YES == isIBeacon) {
        FBBeacon *ibeacon = item.beacons.firstObject;
        FWCentralIBeaconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FWCentralIBeaconCell" forIndexPath:indexPath];
        cell.iBeaconUUID.text = ibeacon.proximityUUID;
        cell.iBeaconMajor.text = [[NSString alloc] initWithFormat:@"%d", ibeacon.major];
        cell.iBeaconMinor.text = [[NSString alloc] initWithFormat:@"%d", ibeacon.minor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        FBBeacon *beacon = item.beacons[indexPath.row];
        FBBeaconType beaconType = beacon.type;
        
        if (beaconType == FBBeaconTypeURL) {
            FWCentralURLBeaconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FWCentralURLBeaconCell" forIndexPath:indexPath];
            cell.eddystonePower.text = [[NSString alloc] initWithFormat:@"%ld", beacon.calibratedTxPowerAt0m_url];
            [cell setupUrlPath:beacon.URLString];
            [cell.addressButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (beaconType == FBBeaconTypeUID) {
            FWCentralUIDBeaconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FWCentralUIDBeaconCell" forIndexPath:indexPath];
            cell.eddystoneUIDPower.text = [[NSString alloc] initWithFormat:@"%ld", beacon.calibratedTxPowerAt0m_uid];
            cell.nameSpace.text = beacon.namespaceString;
            cell.instance.text = beacon.instanceString;
            cell.reserved.text = beacon.reservedString;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (beaconType == FBBeaconTypeTLM) {
            FWCentralTLMBeaconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FWCentralTLMBeaconCell" forIndexPath:indexPath];
            cell.tlmVersionLabel.text = [[NSString alloc] initWithFormat:@"%ld", beacon.tlmVersion];
            // 温度
            if (beacon.beaconTemperature == -128) {
                cell.beaconTemperatureLabel.text = @"Not supported";
            } else {
                cell.beaconTemperatureLabel.text = [[NSString alloc] initWithFormat:@"%lf ˚C", beacon.beaconTemperature];
            }
            cell.batteryVoltageLabel.text = [[NSString alloc] initWithFormat:@"%ld", beacon.batteryVoltage];
            cell.advertisingPDUCountLabel.text = [[NSString alloc] initWithFormat:@"%ld", beacon.advertisingPDUCount];
            cell.timeSincePowerOnOrRebootLabel.text = [self convertSecondsToDHMS:beacon.timeSincePowerOnOrReboot];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (beaconType == FBBeaconTypeAltBeacon) {
            FWCentralAltBeaconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FWCentralAltBeaconCell" forIndexPath:indexPath];
            cell.mfgID.text = [[NSString alloc] initWithFormat:@"<0x%@>", beacon.manufacturerID];
            cell.altID.text = beacon.IDString;
            cell.altPower.text = [[NSString alloc] initWithFormat:@"%ld", beacon.calibratedTxPowerAt1m_alt];
            cell.altReserved.text = beacon.manufacturerReservedString;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            return nil;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    FBPeripheralItem *item = self.bluetoothBrowser.peripheralItems[indexPath.section];
    FBBeacon *beacon = item.beacons[indexPath.row];
    const FBBeaconType beaconType = beacon.type;
    if (FBBeaconTypeUID == beaconType) {
        return 115;
    } else if (FBBeaconTypeAltBeacon == beaconType) {
        return 157;
    } else if (FBBeaconTypeIBeacon == beaconType) {
        return 95;
    } else if (FBBeaconTypeURL == beaconType) {
        return 75;
    } else if (FBBeaconTypeTLM == beaconType) {
        return 140;
    } else if(item.modelIndex == 78){
        return 110;
    }
    return 0;
}

#pragma mark - FBBluetoothBrowserDelegate

// 添加了新设备
- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didAddPeripheralItem:(FBPeripheralItem *)peripheralItem {
    const NSInteger section = [self.bluetoothBrowser.peripheralItems indexOfObject:peripheralItem];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    if (section != NSNotFound) {
        [self.tableView reloadData];
    }
}

// 设备数组已更新
- (void)bluetoothBrowserDidUpdatePeripheralItems:(FBBluetoothBrowser *)bluetoothBrowser {
    [self.tableView reloadData];
}

// 中心蓝牙状态发生改变
- (void)bluetoothBrowserDidChangeState:(FBBluetoothBrowser *)bluetoothBrowser {
    const CBManagerState state = self.bluetoothBrowser.state;
    if (state == CBManagerStateUnknown || state == CBManagerStatePoweredOn) {
        [self.tableView.mj_header beginRefreshing];
    }
}

// 是否添加新设备
- (BOOL)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser shouldAddPeripheralItem:(FBPeripheralItem *)peripheralItem {
    if (peripheralItem.lastestBeacon.type == FBBeaconTypeIBeacon) {
        return YES;
    }
    return (!self.tableView.isDragging && !self.tableView.isDecelerating && !self.tableView.isTracking);
}

// 设备名字已改变
- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemName:(FBPeripheralItem *)peripheralItem {
    
}

// 设备广播包中的名字发生改变
- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemAdvertisingName:(FBPeripheralItem *)peripheralItem {
    const NSInteger section = [self.bluetoothBrowser.peripheralItems indexOfObject:peripheralItem];
    if (section != NSNotFound) {
        [self.tableView reloadData];
    }
}

// 设备的RSSI值发生变化
- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemRSSI:(FBPeripheralItem *)peripheralItem {
    
    if (peripheralItem.lastestBeacon.type == FBBeaconTypeIBeacon) {
        NSLog(@"[debug] 设备的RSSI值发生变化, peripheralItem.rssi = %d, type = %d", peripheralItem.RSSI, peripheralItem.lastestBeacon.type);
    }
    
    const NSInteger section = [self.bluetoothBrowser.peripheralItems indexOfObject:peripheralItem];
    if (section != NSNotFound) {
        [self.tableView reloadData];
    }
}

// 点击打开网址
- (void)click:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:sender.titleLabel.text];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            NSLog(@"openURL result: %d", success);
        }];
    }
}
// 内存报警
- (void)didReceiveMemoryWarning { 
    [super didReceiveMemoryWarning];
}
// 排序操作
- (void)sortButtonPressed {
    [self.bluetoothBrowser sortByRSSI];
}
// 进入过滤控制器
- (void)filterButtonPressed {
    FWFilterViewController *viewController = [[FWFilterViewController alloc] initWithFilter:self.bluetoothBrowser.filter];
    [self.navigationController pushViewController:viewController animated:YES];
}
// 进入iBeacon的UUID配置页面
- (void)showUUIDItemAction {
    FBBeaconUUIDConfigVC *viewController = [[FBBeaconUUIDConfigVC alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}
// 进入Beacon广播发送页面
- (void)broadcastItemAction {
    FBBeaconBroadcastVC *viewController = [[FBBeaconBroadcastVC alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (NSString *)convertSecondsToDHMS:(NSInteger)seconds {
    // 计算秒数
    NSInteger totalSeconds = seconds / 10;
    // 计算毫秒数
    NSInteger milliseconds = seconds % 10 * 100;
    // 计算天数
    NSInteger days = totalSeconds / 86400;
    totalSeconds = totalSeconds % 86400;
    // 计算小时数
    NSInteger hours = totalSeconds / 3600;
    totalSeconds = totalSeconds % 3600;
    // 计算分钟数
    NSInteger minutes = totalSeconds / 60;
    totalSeconds = totalSeconds % 60;
    
    return [NSString stringWithFormat:@"%ld days + %02ld:%02ld:%02ld.%ld", days, (long)hours, minutes, totalSeconds, milliseconds];
}

@end
