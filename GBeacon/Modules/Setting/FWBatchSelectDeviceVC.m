//
//  FWBatchSelectDeviceVC.m
//  FeasyBeacon
//
//  Created by chenchanghua on 2022/3/25.
//  Copyright © 2022 Feasycom. All rights reserved.
//

#import "FWBatchSelectDeviceVC.h"
#import "FWFilterViewController.h"
#import "MJRefresh.h"
#import "FBPeripheralCell.h"
#import "FWBatchHandleProgressVC.h"
#import "FBSDKPublicHeader.h"

@interface FWBatchSelectDeviceVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FBBluetoothBrowserDelegate>

@property (nonatomic, strong) FBBluetoothBrowser *bluetoothBrowser;
@property (nonatomic, strong) NSDictionary *beaconConfiguratedDic;

@property (nonatomic, strong) NSTimer *refreshRSSITimer;//刷新信号值定时器

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) int filterModelTypeIndex;
@property (nonatomic, copy) NSString *filterVersionMin;
@property (nonatomic, copy) NSString *filterVersionMax;
@property (nonatomic, strong) NSMutableArray<NSString *> *macAddressFilted;

@end

@implementation FWBatchSelectDeviceVC

- (instancetype)initWithBeaconConfigurated:(NSDictionary *)beaconConfiguratedDic filterModelType:(int)filterModelTypeIndex filterVersionMin:(NSString *)filterVersionMin filterVersionMax:(NSString *)filterVersionMax {
    if (self = [super init]) {
        self.bluetoothBrowser = [[FBBluetoothBrowser alloc] initWithType:FBBluetoothBrowserTypeSetting];
        [self.bluetoothBrowser setDelegate:self];
        self.beaconConfiguratedDic = beaconConfiguratedDic;
        self.filterModelTypeIndex = filterModelTypeIndex;
        self.filterVersionMin = filterVersionMin;
        self.filterVersionMax = filterVersionMax;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.refreshRSSITimer) {
        self.refreshRSSITimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshRSSI) userInfo:nil repeats:YES];
    }
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.bluetoothBrowser stopScanning];// 停止扫描
    if (self.refreshRSSITimer) {
        [self.refreshRSSITimer invalidate];
        self.refreshRSSITimer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavigationContent_tableUnEnditing];
    [self setupViewContent];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 60;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.bluetoothBrowser startScanning];// 开始扫描
        [strongSelf.tableView.mj_header endRefreshing];
    }];
}

- (void)setupNavigationContent_tableEnditing {
    self.title = LS(@"Unconfigured devices");
    
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
    
    // tableview编辑状态-全选按钮
    UIBarButtonItem *selectAllItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Select All") style:UIBarButtonItemStylePlain target:self action:@selector(selectAllItemAction)];
    // tableview编辑状态-开始按钮
    UIBarButtonItem *beginBatchHandleItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"START") style:UIBarButtonItemStylePlain target:self action:@selector(beginBatchHandleItemAction)];
    
    self.navigationItem.leftBarButtonItems = @[selectAllItem, beginBatchHandleItem];
    
    // 退出tableview编辑状态按钮
    UIBarButtonItem *quitTableEnditingItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(quitTableEnditingItemAction)];
    
    self.navigationItem.rightBarButtonItems = @[quitTableEnditingItem];
}

- (void)setupNavigationContent_tableUnEnditing {
    self.title = LS(@"Unconfigured devices");
    
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
    
    // 排序按钮
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general_icon_sort"] style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonPressed)];
    // 过滤按钮
    UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general_icon_filter"] style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonPressed)];
    
    self.navigationItem.leftBarButtonItems = @[sortItem, filterItem];
    
    // 取消按钮
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    // 选择按钮
    UIBarButtonItem *toSelecteItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"select") style:UIBarButtonItemStylePlain target:self action:@selector(toSelectButtonPressed)];
    
    self.navigationItem.rightBarButtonItems = @[toSelecteItem, cancelItem];
}

- (void)setupViewContent {
    self.view.backgroundColor = [UIColor whiteColor];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
   return UIModalPresentationNone;
}

// 刷新信号值UI
- (void)refreshRSSI {
    NSArray<FBPeripheralItem *> *periphralItems = self.bluetoothBrowser.peripheralItems;
    const NSInteger count = periphralItems.count;
    
    for (NSInteger i = 0; i < count; i++) {
        FBPeripheralCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell refreshRSSI:[periphralItems[i] RSSI]];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bluetoothBrowser.peripheralItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBPeripheralItem *item = self.bluetoothBrowser.peripheralItems[indexPath.row];
    
    FBPeripheralCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FBPeripheralCell" owner:self options:0] firstObject];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@-%@",item.displayedName,item.nameSuffix];
    cell.macAddressLabel.text = item.macAddress;
    [cell.ElectricityImageView setImage:[UIImage imageNamed:[self getElectricityInfo:(NSInteger)item.quantityOfElectricity]]];
    cell.electricityLabel.text = [NSString stringWithFormat:@"%d%%", item.quantityOfElectricity];
    [cell refreshRSSI:(NSInteger)item.RSSI];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark - FBBluetoothBrowserDelegate
// CBCentralManagerState状态改变
- (void)bluetoothBrowserDidChangeState:(FBBluetoothBrowser *)bluetoothBrowser {
    const CBManagerState state = self.bluetoothBrowser.state;
    if (state == CBManagerStateUnknown || state == CBManagerStatePoweredOn) {
//        [self.tableView.mj_header beginRefreshing];
    }
}
// 是否添加设备
- (BOOL)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser shouldAddPeripheralItem:(FBPeripheralItem *)peripheralItem {
    /* fix bug：beacon设备刚上电时有可能出现mac地址显示为0的情况 */
    if ([peripheralItem.macAddress isEqualToString:@"00:00:00:00:00:00"]) {
        return NO;
    }
    // 搜索到设备的模块型号
    int modelIndex_scaned = peripheralItem.modelIndex;
    NSLog(@"搜索到设备的模块型号:%d", modelIndex_scaned);
    
    // 搜索到设备的模块固件版本号
    NSString *firmwareVersion_scaned = peripheralItem.firmwareVersion;
    NSInteger scanVersion = [self versionNumByVersionFormatText:firmwareVersion_scaned];
    NSLog(@"搜索到设备的模块固件版本号:%@, %ld", firmwareVersion_scaned, scanVersion);
    
    // 批量处理设备的模块型号
    int modelIndex_batchHandle = self.filterModelTypeIndex;
    NSLog(@"批量处理设备的模块型号:%d", modelIndex_batchHandle);

    // 批量处理设备的模块固件版本号范围
    NSString *firmwareVersionMin_batchHandle = self.filterVersionMin;
    NSString *firmwareVersionMax_batchHandle = self.filterVersionMax;
    NSLog(@"批量处理设备的模块固件版本号范围:%@～%@", firmwareVersionMin_batchHandle, firmwareVersionMax_batchHandle);
    
    NSInteger minVersion = [self versionNumByVersionFormatText:firmwareVersionMin_batchHandle];
    NSInteger maxVersion = [self versionNumByVersionFormatText:firmwareVersionMax_batchHandle];
    NSLog(@"批量处理设备的模块固件版本号范围:%ld～%ld", minVersion, maxVersion);
    
    // 搜索到设备的mac地址
    NSString *scanMac = peripheralItem.macAddress;
    
    // 默认过滤：模块型号一致
    if (modelIndex_scaned != modelIndex_batchHandle) {
        return NO;
    }
    // 默认过滤：固件版本号在指定范围内
    if (scanVersion < minVersion || scanVersion > maxVersion) {
        return NO;
    }
    // 附加过滤：mac地址
    if (self.macAddressFilted.count > 0) {
        if ([self.macAddressFilted containsObject:scanMac]) {
            return NO;
        }
    }
    return (!self.tableView.isDragging && !self.tableView.isDecelerating && !self.tableView.isTracking);
}
// 添加了新设备
- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didAddPeripheralItem:(FBPeripheralItem *)peripheralItem {
    const NSInteger index = [self.bluetoothBrowser.peripheralItems indexOfObject:peripheralItem];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
// 设备数组已更新
- (void)bluetoothBrowserDidUpdatePeripheralItems:(FBBluetoothBrowser *)bluetoothBrowser {
    [self.tableView reloadData];
}
// 广播包里的名字已改变
- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemAdvertisingName:(FBPeripheralItem *)peripheralItem {
    const NSInteger index = [self.bluetoothBrowser.peripheralItems indexOfObject:peripheralItem];
    if (index != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

// 电量
- (NSString *)getElectricityInfo:(NSInteger)number {
    if (number == 0) {
        return @"百分比电量0";
    } else if (number > 0 && number <= 10) {
        return @"百分比电量10";
    } else if (number > 10 && number <= 20) {
        return @"百分比电量20";
    } else if (number > 20 && number <= 30) {
        return @"百分比电量30";
    } else if (number > 30 && number <= 40) {
        return @"百分比电量40";
    } else if (number > 40 && number <= 50) {
        return @"百分比电量50";
    } else if (number > 50 && number <= 60) {
        return @"百分比电量60";
    } else if (number > 60 && number <= 70) {
        return @"百分比电量70";
    } else if (number > 70 && number <= 80) {
        return @"百分比电量80";
    } else if (number > 80 && number <= 90) {
        return @"百分比电量90";
    } else if (number > 90 && number <= 100) {
        return @"百分比电量100";
    } else {
        return @"百分比电量充电";
    }
}
// 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 排序Action
- (void)sortButtonPressed {
    [self.bluetoothBrowser sortByRSSI];
}

// 过滤Action
- (void)filterButtonPressed {
    FWFilterViewController *viewController = [[FWFilterViewController alloc] initWithFilter:self.bluetoothBrowser.filter];
    [self.navigationController pushViewController:viewController animated:YES];
}

// 取消Action
- (void)cancelButtonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 进入 tableview-编辑模式
- (void)toSelectButtonPressed {
    [self.tableView setEditing:YES animated:YES];
    [self setupNavigationContent_tableEnditing];
}

// 退出 tableview-编辑模式
- (void)quitTableEnditingItemAction {
    [self.tableView setEditing:NO animated:YES];
    [self setupNavigationContent_tableUnEnditing];
}

// tableview-编辑模式 全选
- (void)selectAllItemAction {
    NSInteger dataCount = self.bluetoothBrowser.peripheralItems.count;
    for (int i = 0; i < dataCount; i++) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

// tableview-编辑模式 开始进入批量修改模式
- (void)beginBatchHandleItemAction {
    
    // 若未选择设备，则不能「开始」
    NSArray<NSIndexPath *> *selectedCellIndexArray = [self.tableView indexPathsForSelectedRows];
    NSLog(@"%@", selectedCellIndexArray);
    NSLog(@"%ld", selectedCellIndexArray.count);
    
    if (selectedCellIndexArray.count == 0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:LS(@"Please select the device that needs to be configured")
        message:@"" preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * _Nonnull action) {
        }];

        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:nil];
        
        return;
    }
    
    [self.bluetoothBrowser stopScanning];
    
    NSMutableArray<FBPeripheralItem *> *items_selected = [NSMutableArray array];
    for (int i = 0; i < selectedCellIndexArray.count; i++) {
        NSIndexPath *indexPath = selectedCellIndexArray[i];
        FBPeripheralItem *item = self.bluetoothBrowser.peripheralItems[indexPath.row];
        [items_selected addObject:item];
    }
    
    [self quitTableEnditingItemAction];
    
    FWBatchHandleProgressVC *batchHandleProgressVC = [[FWBatchHandleProgressVC alloc] initWithSelectedPeripheralItems:items_selected beaconConfigurated:self.beaconConfiguratedDic];
    __weak __typeof(self) weakSelf = self;
    batchHandleProgressVC.continueBatchHandleBlock = ^(NSArray<NSString *> * _Nullable macAddressHandled) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.macAddressFilted addObjectsFromArray:macAddressHandled];
    };
    [self.navigationController pushViewController:batchHandleProgressVC animated:YES];
}

- (NSInteger)versionNumByVersionFormatText:(NSString *)versionFormatText {
    NSArray<NSString *> *versionNums = [versionFormatText componentsSeparatedByString:@"."];
    NSInteger versionIndex = 0;
    NSInteger rate = 0;
    for (int i = 0; i < versionNums.count; i++) {
        rate = pow(10, i);
        versionIndex = versionIndex + versionNums[versionNums.count - i - 1].integerValue * rate;
    }
    return versionIndex;
}

- (NSMutableArray<NSString *> *)macAddressFilted {
    if (!_macAddressFilted) {
        _macAddressFilted = [NSMutableArray array];
    }
    return _macAddressFilted;
}

@end
