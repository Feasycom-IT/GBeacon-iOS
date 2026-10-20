//
//  FWBatchHandleProgressVC.m
//  FeasyBeacon
//
//  Created by chenchanghua on 2022/3/26.
//  Copyright © 2022 Feasycom. All rights reserved.
//

#import "FWBatchHandleProgressVC.h"
#import "FBPeripheralCell.h"
#import "FBSDKPublicHeader.h"

@interface FWBatchHandleProgressVC () <UITableViewDelegate, UITableViewDataSource, FBBluetoothBrowserDelegate>

@property (nonatomic, strong) FBBluetoothBrowser *bluetoothBrowser;
@property (nonatomic, strong) NSDictionary *beaconConfiguratedDic;
@property (nonatomic, strong) FBPeripheralManager *beaconManager;

@property (nonatomic, copy) NSArray<FBPeripheralItem *> *selectedPeripheralItems;//选中的

@property (nonatomic, strong) NSMutableArray<FBPeripheralItem *> *selectedPeripheralItems_waitHandle;//未处理的
@property (nonatomic, strong) NSMutableArray<FBPeripheralItem *> *selectedPeripheralItems_hadHandled;//已处理的

@property (nonatomic, strong) NSMutableArray<FBPeripheralItem *> *selectedPeripheralItems_display;//用来展示的

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL isContinueBatchHandle;//是否继续批量处理

@property (nonatomic, strong) NSMutableArray *logArray;

@end

@implementation FWBatchHandleProgressVC

- (instancetype)initWithSelectedPeripheralItems:(NSMutableArray <FBPeripheralItem *> *)selectedPeripheralItems beaconConfigurated:beaconConfiguratedDic {
    if (self = [super init]) {
        self.bluetoothBrowser = [[FBBluetoothBrowser alloc] initWithType:FBBluetoothBrowserTypeSetting];
        [self.bluetoothBrowser setDelegate:self];
        self.selectedPeripheralItems = selectedPeripheralItems;
        self.selectedPeripheralItems_waitHandle = [NSMutableArray arrayWithArray:selectedPeripheralItems];
        self.selectedPeripheralItems_hadHandled = [NSMutableArray array];
        self.selectedPeripheralItems_display = [NSMutableArray arrayWithArray:selectedPeripheralItems];
        self.beaconConfiguratedDic = beaconConfiguratedDic;
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 点击「返回」按钮时也要将「已配置过的设备mac地址」传递过去
    NSMutableArray<NSString *> *macAddresses = [NSMutableArray array];
    for (FBPeripheralItem *item in self.selectedPeripheralItems_hadHandled) {
        [macAddresses addObject:item.macAddress];
    }
    self.continueBatchHandleBlock(macAddresses.copy);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavigationView];
    [self setupContentView];
    self.isContinueBatchHandle = YES;
    [self.bluetoothBrowser startScanning];// 开始扫描
    [self.tableView reloadData];
}

- (void)setupNavigationView {
    self.title = LS(@"Configuring devices in bulk");
    
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
    
    // 停止按钮
    UIBarButtonItem *stopBatchHandleItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"STOP") style:UIBarButtonItemStylePlain target:self action:@selector(stopBatchHandleItemAction)];
    
    self.navigationItem.rightBarButtonItems = @[stopBatchHandleItem];
}

- (void)updateNavigationViewForBatchOver {
    self.navigationItem.rightBarButtonItems = @[];
}

- (void)updateNavigationViewForStayOnAfterBatchOver {
    // 生成报告按钮
    UIBarButtonItem *reportBatchHandleItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Reporting") style:UIBarButtonItemStylePlain target:self action:@selector(reportBatchHandleItemAction)];
    
    self.navigationItem.rightBarButtonItems = @[reportBatchHandleItem];
}

- (void)setupContentView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *segmentedItems = @[LS(@"Incomplete List"), LS(@"Completed List")];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedItems];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(didClickSegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControl setTitle:[NSString stringWithFormat:LS(@"Incomplete List(%ld)"),self.selectedPeripheralItems_waitHandle.count] forSegmentAtIndex:0];
    [self.segmentedControl setTitle:[NSString stringWithFormat:LS(@"Completed List(%ld)"),self.selectedPeripheralItems_hadHandled.count] forSegmentAtIndex:1];
    [self.view addSubview:self.segmentedControl];
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(kNavBar_Height);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.height.mas_equalTo(50);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 60;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.segmentedControl.mas_bottom).offset(0);
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectedPeripheralItems_display.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBPeripheralItem *item = self.selectedPeripheralItems_display[indexPath.row];
    
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
}

// 停止批量处理Action
- (void)stopBatchHandleItemAction {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:LS(@"Important Reminder")
    message:LS(@"If configuration is stopped, it will end the batch configuration operation of all unfinished devices") preferredStyle:UIAlertControllerStyleAlert];
    __weak __typeof(self) weakSelf = self;
    UIAlertAction *stopAction = [UIAlertAction actionWithTitle:LS(@"Confirm Stop") style:UIAlertActionStyleDefault
    handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isContinueBatchHandle = NO;
    }];
    UIAlertAction *continueBatchHandleAction = [UIAlertAction actionWithTitle:LS(@"Continue configuration") style:UIAlertActionStyleDefault
    handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:stopAction];
    [alertVC addAction:continueBatchHandleAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

// 生成报告Action
- (void)reportBatchHandleItemAction {
    NSString *filePath = [self createXLSFile];
    NSLog(@"filePath:%@", filePath);
    if (filePath) {
        
        NSRange range_fileShotPath = [filePath rangeOfString:@"/Documents"];
        NSString *fileShotPath = [filePath substringFromIndex:range_fileShotPath.location];
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:LS(@"Report generated") message:[LS(@"The file path is:") stringByAppendingFormat:@"%@", fileShotPath] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 文件分享器
            UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:filePath]] applicationActivities:nil];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                viewController.popoverPresentationController.sourceView = self.view;
                viewController.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width/2.f, self.view.frame.size.height/2.f, 1.f, 1.f);
                viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
            }
            [self.navigationController presentViewController:viewController animated:YES completion:NULL];
        }];
        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:nil];
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

- (void)didClickSegmentedControlAction:(UISegmentedControl *)segmentedControl {
    NSInteger index = segmentedControl.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.selectedPeripheralItems_display = self.selectedPeripheralItems_waitHandle;
            [self.tableView reloadData];
            
            [self.segmentedControl setTitle:[NSString stringWithFormat:LS(@"Incomplete List(%ld)"),self.selectedPeripheralItems_waitHandle.count] forSegmentAtIndex:0];
            [self.segmentedControl setTitle:[NSString stringWithFormat:LS(@"Completed List(%ld)"),self.selectedPeripheralItems_hadHandled.count] forSegmentAtIndex:1];
            
            break;
            
        case 1:
            self.selectedPeripheralItems_display = self.selectedPeripheralItems_hadHandled;
            [self.tableView reloadData];
            
            [self.segmentedControl setTitle:[NSString stringWithFormat:LS(@"Incomplete List(%ld)"),self.selectedPeripheralItems_waitHandle.count] forSegmentAtIndex:0];
            [self.segmentedControl setTitle:[NSString stringWithFormat:LS(@"Completed List(%ld)"),self.selectedPeripheralItems_hadHandled.count] forSegmentAtIndex:1];
            break;
            
        default:
            break;
    }
}

#pragma mark - FBBluetoothBrowserDelegate
// CBCentralManagerState状态改变
- (void)bluetoothBrowserDidChangeState:(FBBluetoothBrowser *)bluetoothBrowser {
    const CBManagerState state = self.bluetoothBrowser.state;
    if (state == CBManagerStateUnknown || state == CBManagerStatePoweredOn) {
        if (self.isContinueBatchHandle) {
            // 继续扫描
            [self.bluetoothBrowser startScanning];
        } else {
            // 生成报告
            [self updateNavigationViewForStayOnAfterBatchOver];
        }
    }
}
// 是否添加设备
- (BOOL)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser shouldAddPeripheralItem:(FBPeripheralItem *)peripheralItem {
    /* fix bug：beacon设备刚上电时有可能出现mac地址显示为0的情况 */
    if ([peripheralItem.macAddress isEqualToString:@"00:00:00:00:00:00"]) {
        return NO;
    }
    NSString *scanedItemMacAddress = peripheralItem.macAddress;
    NSLog(@"scanedItemMacAddress:%@", scanedItemMacAddress);
    
    if (self.selectedPeripheralItems_waitHandle.count > 0) {
        FBPeripheralItem *selectedItem_runloop = self.selectedPeripheralItems_waitHandle.firstObject;
        if ([selectedItem_runloop.macAddress isEqualToString:scanedItemMacAddress]) {
            [self.bluetoothBrowser stopScanning];
            self.beaconManager = [[FBPeripheralManager alloc] initWithPeripheralItem:selectedItem_runloop PINCode:@"000000"];
            __weak __typeof(self) weakSelf = self;
            [self.beaconManager loadConfigurationWithCompletionHandler:^(FBConfiguration * _Nullable configuration) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                __weak __typeof(strongSelf) weakSelf = strongSelf;
                [strongSelf.beaconManager loadParametersWithCompletionHandler:^(NSError * _Nullable error) {
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    
                    NSString *errMsg;
                    switch(error.code){
                        case FBErrorNone:
                            break;
                        case FBErrorAuthorizationFailed:
                            errMsg = [NSString stringWithFormat:LS(@"%@ verification failed"),selectedItem_runloop.name];
                            break;
                        case FBErrorLoadingParametersFailed:
                            errMsg = [NSString stringWithFormat:LS(@"%@ loading parameters failed"),selectedItem_runloop.name];
                            break;
                        default:
                            errMsg = [NSString stringWithFormat:LS(@"%@ configuration failed"),selectedItem_runloop.name];
                            break;
                    }
                    if(error != nil && error.code != FBErrorNone){
                        [strongSelf showAlertControllerWithTitle:LS(@"Batch configuration") message:errMsg];
                        if([strongSelf.selectedPeripheralItems containsObject:selectedItem_runloop]){
                            [strongSelf.selectedPeripheralItems_waitHandle removeObject:selectedItem_runloop];
                        }
                        if (strongSelf.isContinueBatchHandle&&strongSelf.selectedPeripheralItems_waitHandle.count>0) {
                            // 继续扫描
                            [strongSelf.bluetoothBrowser startScanning];
                        } else {
                            // 生成报告
                            [strongSelf updateNavigationViewForStayOnAfterBatchOver];
                        }
                        return;
                    }
                    for (int i = 0; i < strongSelf.beaconConfiguratedDic.allKeys.count; i++) {
                        [strongSelf.beaconManager setValue:strongSelf.beaconConfiguratedDic.allValues[i] forName:strongSelf.beaconConfiguratedDic.allKeys[i]];
                    }
                    NSLog(@"%@", strongSelf.beaconManager);
                    NSLog(@"%@", strongSelf.beaconConfiguratedDic);
                    
                    // 当前时间
                    NSDate *dateNow = [[NSDate alloc] init];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"MM/dd HH:mm:ss"];
                    NSString *dateNow_string = [dateFormatter stringFromDate:dateNow];
                    [strongSelf.logArray addObject:dateNow_string];
                    // 设备名
                    NSString *nameString = peripheralItem.name;
                    [strongSelf.logArray addObject:nameString];
                    // 设备mac地址
                    NSString *macString = scanedItemMacAddress;
                    [strongSelf.logArray addObject:macString];
                    
                    __weak __typeof(strongSelf) weakSelf = strongSelf;
                    [strongSelf.beaconManager saveParametersWithCompletionHandler:^(NSError * _Nullable error) {
                        __strong __typeof(weakSelf) strongSelf = weakSelf;
                        if (error == nil) {
                            [strongSelf.selectedPeripheralItems_waitHandle removeObject:selectedItem_runloop];
                            [strongSelf.selectedPeripheralItems_hadHandled addObject:selectedItem_runloop];
                            [strongSelf didClickSegmentedControlAction:strongSelf.segmentedControl];
                            
                            NSArray *saveLogs = [strongSelf.beaconManager queryParametersHandledResultLog];
                            NSArray *handledLogs = [self handleLogs:saveLogs];
                            [strongSelf.logArray addObjectsFromArray:handledLogs];
                            if (strongSelf.isContinueBatchHandle && strongSelf.selectedPeripheralItems_waitHandle.count > 0) {
                                // 继续扫描
                                [strongSelf.bluetoothBrowser startScanning];
                            } else {
                                // 生成报告
                                [strongSelf updateNavigationViewForStayOnAfterBatchOver];
                            }
                        } else {
                            NSString *errMsg;
                            switch(error.code){
                                case FBErrorNone:
                                    break;
                                case FBErrorAuthorizationFailed:
                                    errMsg = [NSString stringWithFormat:LS(@"%@ verification failed"),selectedItem_runloop.name];
                                    break;
                                case FBErrorSavingParametersFailed:
                                    errMsg = [NSString stringWithFormat:LS(@"%@ saving parameters failed"),selectedItem_runloop.name];
                                    break;
                                default:
                                    errMsg = [NSString stringWithFormat:LS(@"%@ configuration failed"),selectedItem_runloop.name];
                                    break;
                            }
                            if(error != nil && error.code != FBErrorNone){
                                [strongSelf showAlertControllerWithTitle:LS(@"Batch configuration") message:errMsg];
                                if([strongSelf.selectedPeripheralItems containsObject:selectedItem_runloop]){
                                    [strongSelf.selectedPeripheralItems_waitHandle removeObject:selectedItem_runloop];
                                }
                                if (strongSelf.isContinueBatchHandle && strongSelf.selectedPeripheralItems_waitHandle.count > 0) {
                                    // 继续扫描
                                    [strongSelf.bluetoothBrowser startScanning];
                                } else {
                                    // 生成报告
                                    [strongSelf updateNavigationViewForStayOnAfterBatchOver];
                                }
                            }
                        }
                    }];
                }];
            }];
        }
    } else {
        // 已经全部修改完成
        NSLog(@"已经全部修改完成");
        [self.bluetoothBrowser stopScanning];
        [self updateNavigationViewForBatchOver];
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:LS(@"This batch configuration of devices has ended") message:@"" preferredStyle:UIAlertControllerStyleAlert];
        __weak __typeof(self) weakSelf = self;
        UIAlertAction *continueBatchAction = [UIAlertAction actionWithTitle:LS(@"Continue bulk configuration") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            NSMutableArray<NSString *> *macAddresses = [NSMutableArray array];
            for (FBPeripheralItem *item in strongSelf.selectedPeripheralItems_hadHandled) {
                [macAddresses addObject:item.macAddress];
            }
            strongSelf.continueBatchHandleBlock(macAddresses.copy);
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *stayOnAction = [UIAlertAction actionWithTitle:LS(@"Stay on this page") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf updateNavigationViewForStayOnAfterBatchOver];
        }];
        [alertVC addAction:continueBatchAction];
        [alertVC addAction:stayOnAction];
        [self presentViewController:alertVC animated:YES completion:nil];
        
    }
    return NO;
}

- (NSString *)createXLSFile {
    NSLog(@"self.beaconConfiguratedDic:%@", self.beaconConfiguratedDic);
    
    NSLog(@"ATLogs:%@", self.logArray);
    
    //  创建存放 XLS 文件数据的数组
    NSMutableArray  *xlsDataMuArr = [[NSMutableArray alloc] init];
    
    //  批量处理记录表头
    [xlsDataMuArr addObject:@"TIME"];
    [xlsDataMuArr addObject:@"NAME"];
    [xlsDataMuArr addObject:@"ADDRESS"];
    [xlsDataMuArr addObject:@"CONNECT"];
    
    for (int i = 0; i < self.beaconConfiguratedDic.allKeys.count; i++) {
        NSString *key = self.beaconConfiguratedDic.allKeys[i];
        if ([key isEqualToString:@"Model"]) {
            [xlsDataMuArr addObject:@"Model"];
        }
        if ([key isEqualToString:@"Version"]) {
            [xlsDataMuArr addObject:@"Version"];
        }
        if ([key isEqualToString:@"Name"]) {
            [xlsDataMuArr addObject:@"Name"];
        }
        if ([key isEqualToString:@"Interval"]) {
            [xlsDataMuArr addObject:@"Interval"];
        }
        if ([key isEqualToString:@"Pin"]) {
            [xlsDataMuArr addObject:@"Pin"];
        }
        if ([key isEqualToString:@"TxPower"]) {
            [xlsDataMuArr addObject:@"TxPower"];
        }
        if ([key isEqualToString:@"Gsensor"]) {
            [xlsDataMuArr addObject:@"Gsensor"];
        }
        if ([key isEqualToString:@"Key"]) {
            [xlsDataMuArr addObject:@"Key"];
        }
        if ([key isEqualToString:@"TLM"]) {
            [xlsDataMuArr addObject:@"TLM"];
        }
        if ([key isEqualToString:@"LongRange"]) {
            [xlsDataMuArr addObject:@"LongRange"];
        }
    }
    
    NSInteger titleCount = xlsDataMuArr.count;
    
    // 表数据
    [xlsDataMuArr addObjectsFromArray:self.logArray];
    
    // 把数组拼接成字符串，连接符是 \t （功能同键盘上的 tab 键）
    NSString *fileContent = [xlsDataMuArr componentsJoinedByString:@"\t"];
    
    // 字符串转换为可变字符串，方便改变某些字符
    NSMutableString *muStr = [fileContent mutableCopy];
    
    // 新建一个可变数组，存储每行最后一个 \t 的下标（以便改为 \n ）
    NSMutableArray *subMuArr = [NSMutableArray array];
    for (int i = 0; i < muStr.length; i++) {
        NSRange range = [muStr rangeOfString:@"\t" options:NSBackwardsSearch range:NSMakeRange(i, 1)];
        if (range.length == 1) {
            [subMuArr addObject:@(range.location)];
        }
    }
    //  替换末尾 \t
    for (NSUInteger i = 0; i < subMuArr.count; i ++) {
        if (i > 0 && (i % titleCount == 0)) {
            [muStr replaceCharactersInRange:NSMakeRange([[subMuArr objectAtIndex:i-1] intValue], 1) withString:@"\n"];
        }
    }
    
    //
    NSMutableString *totalString = [NSMutableString string];
    [totalString appendString:[self handleConfigurateParams]];
    [totalString appendString:@"\n\n"];
    [totalString appendString:muStr];
    
    // 使用 UTF16 才能显示汉字；如果显示为 ####### 是因为格子宽度不够，拉开即可
    NSData *fileData = [totalString dataUsingEncoding:NSUTF16StringEncoding];
    
    // 以当前时间为名称的xls文件地址
    NSDate *dateNow = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [[dateFormatter stringFromDate:dateNow] stringByAppendingString:@".xls"];
    
    // 文件路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"BatchModificationRecord"];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSLog(@" 文件路径：\n%@",filePath);
    
    // 文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL is_dir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        BOOL is_file = [fileManager createFileAtPath:filePath contents:fileData attributes:nil];
        NSLog(@"文件创建成功与否：%d,%d", is_dir, is_file);
        if (is_file) {
            return filePath;
        }
    }
    return nil;
}

- (NSString *)handleConfigurateParams {
    NSLog(@"self.beaconConfiguratedDic:%@", self.beaconConfiguratedDic);
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < self.beaconConfiguratedDic.allKeys.count; i++) {
        NSString *key = self.beaconConfiguratedDic.allKeys[i];
        if ([key isEqualToString:@"Model"]) {
            [array addObject:@"Model"];
        }
        if ([key isEqualToString:@"Version"]) {
            [array addObject:@"Version"];
        }
        if ([key isEqualToString:@"Name"]) {
            [array addObject:@"Name"];
        }
        if ([key isEqualToString:@"Interval"]) {
            [array addObject:@"Interval"];
        }
        if ([key isEqualToString:@"Pin"]) {
            [array addObject:@"Pin"];
        }
        if ([key isEqualToString:@"TxPower"]) {
            [array addObject:@"TxPower"];
        }
        if ([key isEqualToString:@"Gsensor"]) {
            [array addObject:@"Gsensor"];
        }
        if ([key isEqualToString:@"Key"]) {
            [array addObject:@"Key"];
        }
        if ([key isEqualToString:@"TLM"]) {
            [array addObject:@"TLM"];
        }
        if ([key isEqualToString:@"LongRange"]) {
            [array addObject:@"LongRange"];
        }
    }
    
    for (int i = 0; i < self.beaconConfiguratedDic.allKeys.count; i++) {
        NSString *key = self.beaconConfiguratedDic.allKeys[i];
        NSString *value = self.beaconConfiguratedDic.allValues[i];
        if ([key isEqualToString:@"Model"]) {
            [array addObject:value];
        }
        if ([key isEqualToString:@"Version"]) {
            [array addObject:value];
        }
        if ([key isEqualToString:@"Name"]) {
            [array addObject:value];
        }
        if ([key isEqualToString:@"Interval"]) {
            [array addObject:value];
        }
        if ([key isEqualToString:@"Pin"]) {
            [array addObject:value];
        }
        if ([key isEqualToString:@"TxPower"]) {
            [array addObject:value];
        }
        if ([key isEqualToString:@"Gsensor"]) {
            [array addObject:value];
        }
        if ([key isEqualToString:@"Key"]) {
            NSArray *arry = value;
            value=[NSString stringWithFormat:@"(%@,%@)",arry[0],arry[1]];
            [array addObject:value];
        }
        if ([key isEqualToString:@"TLM"]) {
            [array addObject:value];
        }
        if ([key isEqualToString:@"LongRange"]) {
            [array addObject:value];
        }
    }
    
    NSInteger titleCount = array.count / 2;

    // 把数组拼接成字符串，连接符是 \t （功能同键盘上的 tab 键）
    NSString *fileContent = [array componentsJoinedByString:@"\t"];
    
    // 字符串转换为可变字符串，方便改变某些字符
    NSMutableString *muStr = [fileContent mutableCopy];
    
    // 新建一个可变数组，存储每行最后一个 \t 的下标（以便改为 \n ）
    NSMutableArray *subMuArr = [NSMutableArray array];
    for (int i = 0; i < muStr.length; i++) {
        NSRange range = [muStr rangeOfString:@"\t" options:NSBackwardsSearch range:NSMakeRange(i, 1)];
        if (range.length == 1) {
            [subMuArr addObject:@(range.location)];
        }
    }
    //  替换末尾 \t
    for (NSUInteger i = 0; i < subMuArr.count; i++) {
        if (i > 0 && (i % titleCount == 0)) {
            [muStr replaceCharactersInRange:NSMakeRange([[subMuArr objectAtIndex:i-1] intValue], 1) withString:@"\n"];
        }
        if (i == 0 && titleCount == 1) {
            [muStr replaceCharactersInRange:NSMakeRange([[subMuArr objectAtIndex:i] intValue], 1) withString:@"\n"];
        }
    }
    
    return muStr;
}

- (NSMutableArray *)logArray {
    if (!_logArray) {
        _logArray = [NSMutableArray array];
    }
    return _logArray;
}

- (NSArray *)handleLogs:(NSArray *)originalLogs {
    NSLog(@"originalLogs:%@", originalLogs);
    NSLog(@"self.beaconConfiguratedDic:%@", self.beaconConfiguratedDic);
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < self.beaconConfiguratedDic.allKeys.count; i++) {
        NSString *key = self.beaconConfiguratedDic.allKeys[i];
        if ([key isEqualToString:@"Model"]) {
            
        }
        if ([key isEqualToString:@"Version"]) {
            
        }
        if ([key isEqualToString:@"Name"]) {
            for (int j = 0; j < originalLogs.count; j++) {
                NSDictionary *dic = originalLogs[j];
                NSString *keyString = (NSString *)dic.allKeys.firstObject;
                NSString *valueString = (NSString *)dic.allValues.firstObject;
                if ([keyString containsString:@"NAME"]) {
                    [array addObject:valueString];
                    break;
                }
            }
        }
        if ([key isEqualToString:@"Interval"]) {
            for (int j = 0; j < originalLogs.count; j++) {
                NSDictionary *dic = originalLogs[j];
                NSString *keyString = (NSString *)dic.allKeys.firstObject;
                NSString *valueString = (NSString *)dic.allValues.firstObject;
                if ([keyString containsString:@"ADVIN"]) {
                    [array addObject:valueString];
                    break;
                }
            }
        }
        if ([key isEqualToString:@"Pin"]) {
            for (int j = 0; j < originalLogs.count; j++) {
                NSDictionary *dic = originalLogs[j];
                NSString *keyString = (NSString *)dic.allKeys.firstObject;
                NSString *valueString = (NSString *)dic.allValues.firstObject;
                if ([keyString containsString:@"PIN"]) {
                    [array addObject:valueString];
                    break;
                }
            }
        }
        if ([key isEqualToString:@"TxPower"]) {
            for (int j = 0; j < originalLogs.count; j++) {
                NSDictionary *dic = originalLogs[j];
                NSString *keyString = (NSString *)dic.allKeys.firstObject;
                NSString *valueString = (NSString *)dic.allValues.firstObject;
                if ([keyString containsString:@"POWER"]) {
                    [array addObject:valueString];
                    break;
                }
            }
        }
        if ([key isEqualToString:@"Gsensor"]) {
            for (int j = 0; j < originalLogs.count; j++) {
                NSDictionary *dic = originalLogs[j];
                NSString *keyString = (NSString *)dic.allKeys.firstObject;
                NSString *valueString = (NSString *)dic.allValues.firstObject;
                if ([keyString containsString:@"TXPOWER"]) {
                    [array addObject:valueString];
                    break;
                }
            }
        }
        if ([key isEqualToString:@"Key"]) {
            for (int j = 0; j < originalLogs.count; j++) {
                NSDictionary *dic = originalLogs[j];
                NSString *keyString = (NSString *)dic.allKeys.firstObject;
                NSString *valueString = (NSString *)dic.allValues.firstObject;
                if ([keyString containsString:@"KEYCFG"]) {
                    [array addObject:valueString];
                    break;
                }
            }
        }
        if ([key isEqualToString:@"TLM"]) {
            for (int j = 0; j < originalLogs.count; j++) {
                NSDictionary *dic = originalLogs[j];
                NSString *keyString = (NSString *)dic.allKeys.firstObject;
                NSString *valueString = (NSString *)dic.allValues.firstObject;
                if ([keyString containsString:@"TLM"]) {
                    [array addObject:valueString];
                    break;
                }
            }
        }
        if ([key isEqualToString:@"LongRange"]) {
            for (int j = 0; j < originalLogs.count; j++) {
                NSDictionary *dic = originalLogs[j];
                NSString *keyString = (NSString *)dic.allKeys.firstObject;
                NSString *valueString = (NSString *)dic.allValues.firstObject;
                if ([keyString containsString:@"ADVEXT"]) {
                    [array addObject:valueString];
                    break;
                }
            }
        }
    }
    
    for (int j = 0; j < originalLogs.count; j++) {
        NSDictionary *dic = originalLogs[j];
        NSString *keyString = (NSString *)dic.allKeys.firstObject;
        NSString *valueString = (NSString *)dic.allValues.firstObject;
        if ([keyString containsString:@"Connect"]) {
            [array insertObject:valueString atIndex:0];
        }
    }
    
    return array;
}

/*
 {
     Interval = 200;
     Name = "Major10065$$";
 }
 
 {
 "AT+NAME=Major10065$$
\n" = Success;
},
 {
 "AT+LENAME=Major10065$$
\n" = Success;
},
 {
 "AT+ADVIN=200
\n" = Success;
},
 
 */

@end
