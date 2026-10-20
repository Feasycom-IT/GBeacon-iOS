
//
//  FWSettingsViewController.m
//  FeasyBeacon
//
//  Created by LIDONG on 14-2-28.
//  Copyright (c) 2014年 LIDONG. All rights reserved.
//
////-28.27
//AT+TEMCFG=-28.27,20000
#import "FWSensorViewController.h"
#import "FWParametersViewController.h"
#import "FWSensorViewCell.h"
#import "FBGSensorViewCell.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "NSString+HexStringToData.h"
#import "MJRefresh.h"
#import "FWFilterViewController.h"
#import "FBSDKPublicHeader.h"
#import "NSData+DataToHexString.h"

@interface FWSensorViewController ()<FBBluetoothBrowserDelegate, UITextFieldDelegate> {
    FBBluetoothBrowser *_bluetoothBrowser;
}
//刷新信号值定时器
@property (nonatomic, strong) NSTimer *refreshRSSITimer;

@end

@implementation FWSensorViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = LS(@"Sensor");
        
        [self setupNavigationContent];
        
        _bluetoothBrowser = [[FBBluetoothBrowser alloc] initWithType:FBBluetoothBrowserTypeSensor];
        [_bluetoothBrowser setDelegate:self];
        
        [_bluetoothBrowser setupDecryptKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"User-DecryptKey"]];
    }
    
    return self;
}

- (void)setupNavigationContent {
    UINavigationItem *navigationItem = [self navigationItem];
    
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general_icon_sort"] style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonPressed)];
    [navigationItem setLeftBarButtonItem:sortItem];
    
    UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general_icon_filter"] style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonPressed)];
    
    UIBarButtonItem *decryptKeyItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general_icon_key"] style:UIBarButtonItemStylePlain target:self action:@selector(decryptKeyItemAction)];
    [navigationItem setRightBarButtonItems:@[filterItem, decryptKeyItem]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.refreshRSSITimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshRSSI) userInfo:nil repeats:YES];
    [[NSRunLoop alloc]addTimer:self.refreshRSSITimer forMode:NSRunLoopCommonModes];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.refreshRSSITimer) {
        [self.refreshRSSITimer invalidate];
        self.refreshRSSITimer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]};
        
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
    
    // tableView
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 40;
    self.tableView.allowsSelection = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"FWSensorViewCell" bundle:nil] forCellReuseIdentifier:@"SensorCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FBGSensorViewCell" bundle:nil] forCellReuseIdentifier:@"GSensorCell"];
    
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf->_bluetoothBrowser stopScanning];
        [strongSelf->_bluetoothBrowser startScanning];
        [strongSelf.tableView.mj_header endRefreshing];
    }];
}


//刷新信号值
- (void)refreshRSSI {
    const NSInteger count = [_bluetoothBrowser.peripheralItems count];
    
    for (NSInteger i = 0; i < count; i++) {
        FWSensorViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        //        [cell refreshRSSI:[_bluetoothBrowser.peripheralItems[i] RSSI]];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _bluetoothBrowser.peripheralItems.count;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FBPeripheralItem *peripheralItem = _bluetoothBrowser.peripheralItems[section];
    
    UIView * bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor lightGrayColor];
    
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
    
    return bgView;;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    FBPeripheralItem *item = _bluetoothBrowser.peripheralItems[section];
    if (item.isSensor && item.isGSensor) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBPeripheralItem *item = _bluetoothBrowser.peripheralItems[indexPath.section];
    if (indexPath.row == 0 && item.isSensor) {
        FWSensorViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SensorCell" forIndexPath:indexPath];
        
        //温度
        cell.temperature.text = item.temperature;
        //湿度
        cell.humidity.text = item.humidity;
        //电量
        cell.electricity.text = [NSString stringWithFormat:@"%d%%", item.quantityOfElectricity];
        //电量icon
        cell.batteryImageView.image = [UIImage imageNamed:[self imageNameForQuantityOfElectricity:item.quantityOfElectricity]];
        return cell;
    } else if (indexPath.row == 0 && item.isGSensor) {
        FBGSensorViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GSensorCell" forIndexPath:indexPath];
        
        //X
        cell.xAxisRawLabel.text = [NSString stringWithFormat:@"X: %0.3f g", (long)item.xAxisRaw/1000.0];
        //Y
        cell.yAxisRawLabel.text = [NSString stringWithFormat:@"Y: %0.3f g", (long)item.yAxisRaw/1000.0];
        //Z
        cell.zAxisRawLabel.text = [NSString stringWithFormat:@"Z: %0.3f g", (long)item.zAxisRaw/1000.0];
        return cell;
    } else if (indexPath.row == 1 && item.isGSensor) {
        FBGSensorViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GSensorCell" forIndexPath:indexPath];
        
        //X
        cell.xAxisRawLabel.text = [NSString stringWithFormat:@"X: %0.3f g", (long)item.xAxisRaw/1000.0];
        //Y
        cell.yAxisRawLabel.text = [NSString stringWithFormat:@"Y: %0.3f g", (long)item.yAxisRaw/1000.0];
        //Z
        cell.zAxisRawLabel.text = [NSString stringWithFormat:@"Z: %0.3f g", (long)item.zAxisRaw/1000.0];
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

//电量
- (NSString *)imageNameForQuantityOfElectricity:(const int)quantity {
    if (quantity < 5) {
        return @"百分比电量0";
    } else if (quantity >= 5 && quantity < 15) {
        return @"百分比电量10";
    } else if (quantity >= 15 && quantity < 25) {
        return @"百分比电量20";
    } else if (quantity >= 25 && quantity < 35) {
        return @"百分比电量30";
    } else if (quantity >= 35 && quantity < 45) {
        return @"百分比电量40";
    } else if (quantity >= 45 && quantity < 55) {
        return @"百分比电量50";
    } else if (quantity >= 55 && quantity < 65) {
        return @"百分比电量60";
    } else if (quantity >= 65 && quantity < 75) {
        return @"百分比电量70";
    } else if (quantity >= 75 && quantity < 85) {
        return @"百分比电量80";
    } else if (quantity >= 85 && quantity < 95) {
        return @"百分比电量90";
    } else if (quantity >= 95 && quantity <= 100) {
        return @"百分比电量100";
    } else {
        return @"百分比电量充电";
    }
}

- (void)bluetoothBrowserDidChangeState:(FBBluetoothBrowser *)bluetoothBrowser {
    const CBManagerState state = _bluetoothBrowser.state;
    
    if (CBManagerStateUnknown == state || CBManagerStatePoweredOn == state) {
        [self.tableView.mj_header beginRefreshing];
    }
}

- (BOOL)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser shouldAddPeripheralItem:(FBPeripheralItem *)peripheralItem {
    return (!self.tableView.isDragging && !self.tableView.isDecelerating && !self.tableView.isTracking);
}

- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didAddPeripheralItem:(FBPeripheralItem *)peripheralItem {
    const NSInteger index = [_bluetoothBrowser.peripheralItems indexOfObject:peripheralItem];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    //    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
}

- (void)bluetoothBrowserDidUpdatePeripheralItems:(FBBluetoothBrowser *)bluetoothBrowser {
    [self.tableView reloadData];
}

- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemAdvertisingName:(FBPeripheralItem *)peripheralItem {
    const NSInteger index = [_bluetoothBrowser.peripheralItems indexOfObject:peripheralItem];
    if (NSNotFound != index) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

// 设备的RSSI值发生变化
- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemRSSI:(FBPeripheralItem *)peripheralItem {
    const NSInteger section = [_bluetoothBrowser.peripheralItems indexOfObject:peripheralItem];
    if (section != NSNotFound) {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)sortButtonPressed {
    [_bluetoothBrowser sortByRSSI];
}

- (void)filterButtonPressed {
    FWFilterViewController *viewController = [[FWFilterViewController alloc] initWithFilter:_bluetoothBrowser.filter];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)decryptKeyItemAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Please input DecryptKey 128-AES") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.delegate = self;
        textField.placeholder = LS(@"Please input 128 bit AES key");
        textField.text = [(NSData *)[[NSUserDefaults standardUserDefaults] valueForKey:@"User-DecryptKey"] dataToHexString];
    }];
    
    __weak __typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields[0];
        [textField resignFirstResponder];
        NSData *key = [textField.text hexStringToData];
        if ([_bluetoothBrowser setupDecryptKey:key]) {
            [[NSUserDefaults standardUserDefaults] setValue:key forKey:@"User-DecryptKey"];
        }
    }];
    [alertController addAction:okAction];
    
    [self.tabBarController presentViewController:alertController animated:YES completion:NULL];
}

#pragma mark - UITextFieldDelegate
// 限制只能输入32字符
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return (newText.length <= 32);
}


@end

