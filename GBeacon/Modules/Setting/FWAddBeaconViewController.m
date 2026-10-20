//
//  FWAddBeaconViewController.m
//  FeasyBeacon
//
//  Created by ericj on 2017/10/19.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import "FWAddBeaconViewController.h"
#import "FWConfigureSwitchCell.h"
#import "FWConfigureValueSetCell.h"
#import "NSString+FscKit.h"
#import "FWConfigurePhyCell.h"
#import "FWPopoverViewController.h"
#import "FWConfigurePowerCell.h"

@interface FWAddBeaconViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate> {
    UITableView *_tableView;
    UITextField *_textFields[10];
    UILabel *_beaconTypeLabel;
    UISwitch *_switchControl;
    UIViewController *_popupViewController;
    NSMutableArray *_titles;
    FBBeaconType _beaconType;
    NSInteger _modelIndex;
    NSArray *_configTxPowers;
    int _iPhy;
    NSString *_txPower;
}
@end

@implementation FWAddBeaconViewController

- (instancetype)init {
    if (self = [super init]) {
        UIBarButtonItem *finishItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Finish") style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPressed:)];
        
        self.navigationItem.rightBarButtonItem = finishItem;
        
        _titles = [[NSMutableArray alloc] initWithCapacity:5];
        _titles[0] = @[];
        _titles[1] = @[@"UUID:",@"Major:",@"Minor:",@"RSSI at 1m:",@"Enabled:"];
        _titles[2] = @[@"URL:",@"RSSI at 0m:",@"Enabled:"];
        _titles[3] = @[@"Namespace:",@"Instance:",@"Reserved:",@"RSSI at 0m:",@"Enabled:"];
        _titles[4] = @[@"ID1:",@"ID2:",@"ID3:",@"RSSI at 1m:",@"Manufacturer ID:",@"Manufacturer Reserved:",@"Enabled:"];
    }
    return self;
}

- (instancetype)initWithModelIndex:(NSInteger) modelIndex configTxPowers:(NSArray *)txPowers{
    if (self = [super init]) {
        UIBarButtonItem *finishItem = [[UIBarButtonItem alloc]initWithTitle:LS(@"Finish") style:UIBarButtonItemStylePlain target:self action:@selector((saveButtonPressed:))];
        self.navigationItem.rightBarButtonItem = finishItem;
        _titles = [[NSMutableArray alloc]initWithCapacity:5];
        _modelIndex = modelIndex;
        _configTxPowers = txPowers;
        _txPower = txPowers[0];
        if (78 == modelIndex || 91 == modelIndex || 98 == modelIndex) {
            _titles[0] = @[];
            _titles[1] = @[@"UUID:",@"Major:",@"Minor:",@"RSSI at 1m:",LS(@"Interval(ms):"),@"TxPower(db):",LS(@"Phy:"),@"Enabled:"];
            _titles[2] = @[@"URL:",@"RSSI at 0m:",LS(@"Interval(ms):"),@"TxPower(db):",LS(@"Phy:"),@"Enabled:"];
            _titles[3] = @[@"Namespace:",@"Instance:",@"Reserved:",@"RSSI at 0m:",LS(@"Interval(ms):"),@"TxPower(db):",LS(@"Phy:"),@"Enabled:"];
            _titles[4] = @[@"ID1:",@"ID2:",@"ID3:",@"RSSI at 1m:",@"Manufacturer ID:",@"Manufacturer Reserved:",LS(@"Interval(ms):"),@"TxPower(db):",LS(@"Phy:"),@"Enabled:"];
        } else {
            _titles[0] = @[];
            _titles[1] = @[@"UUID:",@"Major:",@"Minor:",@"RSSI at 1m:",@"Enabled:"];
            _titles[2] = @[@"URL:",@"RSSI at 0m:",@"Enabled:"];
            _titles[3] = @[@"Namespace:",@"Instance:",@"Reserved:",@"RSSI at 0m:",@"Enabled:"];
            _titles[4] = @[@"ID1:",@"ID2:",@"ID3:",@"RSSI at 1m:",@"Manufacturer ID:",@"Manufacturer Reserved:",@"Enabled:"];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 广播类型的选择
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(kNavBar_Height);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 44)];
    titleLabel.text = LS(@"Broadcast Type");
    [headerView addSubview:titleLabel];
    
    _beaconTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreen_Width - 124), 0, 80, 44)];
    [headerView addSubview:_beaconTypeLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-44, 0, 44, 44)];
    [button setImage:[UIImage imageNamed:@"bottom-1"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showPopupViewController:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.allowsSelection = NO;
    _tableView.rowHeight = 44;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headerView.mas_bottom).offset(0);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)saveButtonPressed:(UIBarButtonItem *)sender {
    if (_completionHandler) {
        FBMutableBeacon *beacon = [[FBMutableBeacon alloc] init];
        int iCurrentTextField = 0;
        
        beacon.type = _beaconType;
        beacon.enabled = _switchControl.isOn;
        
        if (FBBeaconTypeIBeacon == _beaconType) {
            beacon.proximityUUID = [_textFields[iCurrentTextField++] text];
            if (beacon.proximityUUID.length != 32) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.major = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.major < 0 || beacon.major > 65535) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.minor = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.minor < 0 || beacon.minor > 65535) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.calibratedTxPowerAt1m_iBeacon = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.calibratedTxPowerAt1m_iBeacon < -128 || beacon.calibratedTxPowerAt1m_iBeacon > 127) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
        } else if (FBBeaconTypeURL == _beaconType) {
            beacon.URLString = [_textFields[iCurrentTextField++] text];
            if (![self isValidURL:beacon.URLString]) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.calibratedTxPowerAt0m_url = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.calibratedTxPowerAt0m_url < -128 || beacon.calibratedTxPowerAt0m_url > 127) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
        } else if (FBBeaconTypeUID == _beaconType) {
            beacon.namespaceString = [_textFields[iCurrentTextField++] text];
            if (beacon.namespaceString.length != 20) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.instanceString = [_textFields[iCurrentTextField++] text];
            if (beacon.instanceString.length != 12) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.reservedString = [_textFields[iCurrentTextField++] text];
            if (beacon.reservedString.length != 4) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.calibratedTxPowerAt0m_uid = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.calibratedTxPowerAt0m_uid < -128 || beacon.calibratedTxPowerAt0m_uid > 127) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
        } else if (FBBeaconTypeAltBeacon == _beaconType) {
            beacon.IDString1 = [_textFields[iCurrentTextField++] text];
            if (beacon.IDString1.length != 32) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.IDString2 = [_textFields[iCurrentTextField++] text];
            if (beacon.IDString2.length != 4) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.IDString3 = [_textFields[iCurrentTextField++] text];
            if (beacon.IDString3.length != 4) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.calibratedTxPowerAt1m_alt = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.calibratedTxPowerAt1m_alt < -128 || beacon.calibratedTxPowerAt1m_alt > 127) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.manufacturerID = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.manufacturerID < 0 || beacon.manufacturerID > 65535) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.manufacturerReservedString = [_textFields[iCurrentTextField++] text];
            if (beacon.manufacturerReservedString.length != 2) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
        } else {
            return;
        }
        if(78 == _modelIndex || 91 == _modelIndex || 98 == _modelIndex) {
            beacon.iInterval = [[_textFields[iCurrentTextField++] text] intValue];
            beacon.txPower = _txPower;
            beacon.iPhy = _iPhy;
            beacon.numberOfParameters += 3;
        }
        _completionHandler(beacon);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showPopupViewController:(UIButton *)sender {
    if (nil == _popupViewController) {
        _popupViewController = [UIViewController new];
        
        const CGSize size = { 120, 200 };
        
        _popupViewController.modalPresentationStyle = UIModalPresentationPopover;
        _popupViewController.preferredContentSize = size;
        
        UIView *view = _popupViewController.view;
        const CGFloat buttonHeight = size.height / 4.0;
        
        NSString *types[4] = { @"iBeacon", @"URL", @"UID", @"AltBeacon" };
        
        for (NSInteger i = 0; i < 4; i ++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 13 + buttonHeight * i, size.width, buttonHeight)];
            
            [button setTag:(i + 1)];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:types[i] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
        }
    }
    
    UIPopoverPresentationController *presentationController = _popupViewController.popoverPresentationController;
    
    presentationController.sourceView = sender;
    presentationController.sourceRect = sender.bounds;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.delegate = self;
    
    [self presentViewController:_popupViewController animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone; //不适配
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;   //点击蒙版popover消失， 默认YES
}


// 选择类型
- (void)selectType:(UIButton *)sender {
    _beaconType = (FBBeaconType)sender.tag;
    _beaconTypeLabel.text = sender.titleLabel.text;
    
    [_popupViewController dismissViewControllerAnimated:YES completion:nil];
    _popupViewController = nil;
    for (int i=0; i<10; i++) {
        _textFields[i].text = nil;
    }
    [_tableView reloadData];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

//输入检测
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    FWConfigureValueSetCell *cell = (FWConfigureValueSetCell *)[[textField superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    const NSInteger row = indexPath.row;
    
    if (FBBeaconTypeIBeacon == _beaconType) {
        if (0 == row) {
            if (![newText isHexDigits]) {
                return NO;
            }
            
            const NSInteger newLength = newText.length;
            
            if (newLength < 32) {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            } else {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            }
            return newLength <= 32;
        } else if (1 == row) { // major -> 0 ~ 65535
            if (![newText isUnsignedDigits]) {
                return NO;
            }
            
            const int newValue = [newText intValue];
            
            if (0 <= newValue && newValue <= 65535) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
                return YES;
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            if (newText.length > 6) {
                return NO;
            }
            return YES;
            
        } else if (2 == row) { // minor -> 0 ~ 65535
            if (![newText isUnsignedDigits]) {
                return NO;
            }
            
            const int newValue = [newText intValue];
            
            if (0 <= newValue && newValue <= 65535) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
                return YES;
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            if (newText.length > 6) {
                return NO;
            }
            return YES;
            
        } else if (3 == row) {
            if (![newText isDigits]) {
                return NO;
            }
            
            const int newValue = [newText intValue];
            
            if (-128 <= newValue && newValue <= 127) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
                return YES;
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            if (newText.length > 5) {
                return NO;
            }
            return YES;
        } else if (4 == row && (_modelIndex == 78 || _modelIndex == 91 || _modelIndex == 98)) {
            if (![newText isUnsignedDigits]) {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
                return  NO;
            }
            const int newValue = [newText intValue];
            if (100 <= newValue && newValue <= 10000) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            return newValue <= 100000;
        }
    } else if (FBBeaconTypeURL == _beaconType) {
        if (0 == row) {
            if([self isValidURL:newText]){
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            }else{
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[\\u4e00-\\u9fa5]+$"];
            
            if ([predicate evaluateWithObject:string]) {
                return NO;
            }
            return YES;
        } else if (1 == row) {
            if (![newText isDigits]) {
                return NO;
            }
            
            const int newValue = [newText intValue];
            
            if (-128 <= newValue && newValue <= 127) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
                return YES;
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            if (newText.length > 5) {
                return NO;
            }
            return YES;
        } else if (2 == row && (_modelIndex == 78 || _modelIndex == 91 || _modelIndex == 98)) {
            if (![newText isUnsignedDigits]) {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
                return  NO;
            }
            const int newValue = [newText intValue];
            if (100 <= newValue && newValue <= 10000) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            return newValue <= 100000;
        }
    } else if (FBBeaconTypeUID == _beaconType) {
        if (0 == row) {
            if (![newText isHexDigits]) {
                return NO;
            }
            
            const NSInteger newLength = newText.length;
            
            if (newLength < 20) {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            } else {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            }
            return newLength <= 20;
        } else if (1 == row) {
            if (![newText isHexDigits]) {
                return NO;
            }
            
            const NSInteger newLength = newText.length;
            
            if (newLength < 12) {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            } else {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            }
            return newLength <= 12;
        } else if (2 == row) {
            if (![newText isHexDigits]) {
                return NO;
            }
            
            const NSInteger newLength = newText.length;
            
            if (newLength < 4) {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            } else {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            }
            return newLength <= 4;
        } else if (3 == row) {
            if (![newText isDigits]) {
                return NO;
            }
            
            const int newValue = [newText intValue];
            
            if (-128 <= newValue && newValue <= 127) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor blackColor];
                return YES;
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            if (newText.length > 5) {
                return NO;
            }
            return YES;
        } else if (4 == row && (_modelIndex == 78 || _modelIndex == 91 || _modelIndex == 98)) {
            if (![newText isUnsignedDigits]) {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
                return  NO;
            }
            const int newValue = [newText intValue];
            if (100 <= newValue && newValue <= 10000) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            return newValue <= 100000;
        }
    } else if (FBBeaconTypeAltBeacon == _beaconType) {
        if (0 == row) {
            if (![newText isHexDigits]) {
                return NO;
            }
            
            const NSInteger newLength = newText.length;
            
            if (newLength < 32) {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            } else {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            }
            return newLength <= 32;
        } else if (1 == row) {
            if (![newText isHexDigits]) {
                return NO;
            }
            
            const NSInteger newLength = newText.length;
            if (newLength >= 4) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor blackColor];
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            
            return newLength <= 4;
        } else if (2 == row) {
            if (![newText isHexDigits]) {
                return NO;
            }
            
            const NSInteger newLength = newText.length;
            if (newLength >= 4) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor blackColor];
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            
            return newLength <= 4;
        } else if (3 == row) {
            if (![newText isDigits]) {
                return NO;
            }
            
            const int newValue = [newText intValue];
            
            if (-128 <= newValue && newValue <= 127) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor blackColor];
                return YES;
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            if (newText.length > 5) {
                return NO;
            }
            return YES;
        } else if (4 == row) {
            if (![newText isDigits]) {
                return NO;
            }
            
            const int newValue = [newText intValue];
            
            if (0 <= newValue && newValue <= 65535) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor blackColor];
                return YES;
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            if (newText.length > 6) {
                return NO;
            }
            return YES;
        } else if (5 == row) {
            if (![newText isHexDigits]) {
                return NO;
            }
            if (range.length + range.location > textField.text.length) {
                return NO;
            }
            
            const NSInteger newLength = newText.length;
            
            if (newLength < 2) {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            } else {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            }
            return newLength <= 2;
        } else if (6 == row && (_modelIndex == 78 || _modelIndex == 91 || _modelIndex == 98)) {
            if (![newText isUnsignedDigits]) {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
                return  NO;
            }
            const int newValue = [newText intValue];
            if (100 <= newValue && newValue <= 10000) {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            } else {
                cell.titleLabel.textColor = [UIColor redColor];
                cell.inputTextField.textColor = [UIColor redColor];
            }
            return newValue <= 100000;
        }
    }
    return YES;
}

#pragma mark - UITableViewDataSoure
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_titles[_beaconType] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger lastRow = [_titles[_beaconType] count] - 1;
    const NSInteger row = indexPath.row;
    
    if (78 == _modelIndex || 91 == _modelIndex || 98 == _modelIndex) {
        if (row == lastRow-2) {
            FWConfigurePowerCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePowerCell" owner:self options:nil] firstObject];
            UIView *backgroundView = [[UIView alloc] init];
            cell.backgroundView = backgroundView;
            cell.powerLabel.text = @"TxPower(db):";
            cell.txPowerLabel.text = _txPower;
            [cell.powerButton addTarget:self action:@selector(addBeaconTxPowerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        } else if (row == lastRow-1) {
            FWConfigurePhyCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePhyCell" owner:self options:nil] firstObject];
            UIView *backgroundView = [[UIView alloc] init];
            cell.backgroundView = backgroundView;
            cell.phyLabel.font = [UIFont systemFontOfSize:17];
            cell.phyLabel.text = @"Phy:";
            cell.phyValueLabel.text = [NSString stringWithFormat:@"%@",@"phy_1m"];
            if(_iPhy == 0){
                cell.phyValueLabel.text = [NSString stringWithFormat:@"%@",@"phy_1m"];
            }else if(_iPhy == 1){
                cell.phyValueLabel.text = [NSString stringWithFormat:@"%@",@"phy_2m"];
            }else{
                cell.phyValueLabel.text = [NSString stringWithFormat:@"%@",@"phy_coded"];
            }
            [cell.phyButton addTarget:self action:@selector(addBeaconPhyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            if (98 == _modelIndex) {
                cell.phyButton.hidden = YES;
            }
            return cell;
        }
    }
    if (row == lastRow) {
        FWConfigureSwitchCell *twoCell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureSwitchCell" owner:self options:nil] firstObject];
        
        twoCell.textLabel.text = _titles[_beaconType][row];
        _switchControl = twoCell.switchBtn;
        
        return twoCell;
    }
    FWConfigureValueSetCell *fourCell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureValueSetCell" owner:self options:nil] firstObject];
    fourCell.inputTextField.delegate = self;
    fourCell.titleLabel.text = _titles[_beaconType][row];
    [fourCell.titleLabel sizeToFit];
    
    fourCell.inputTextField.text = _textFields[row].text;
    fourCell.inputTextField.delegate = self;
    
    _textFields[row] = fourCell.inputTextField;
    
    return fourCell;
    
}
- (void)addBeaconPhyButtonPressed:(UIButton *)sender {
    NSArray *phys = @[@"phy_1m", @"phy_2m", @"phy_coded"];
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:phys sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *phy){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf){
            if([phy isEqualToString:@"phy_1m"]){
                _iPhy = 0;
            }else if([phy isEqualToString:@"phy_2m"]){
                _iPhy = 1;
            }else{
                _iPhy = 2;
            }
            [_tableView reloadData];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (void)addBeaconTxPowerButtonPressed:(UIButton *)sender {
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:_configTxPowers sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *powerString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf){
            _txPower = powerString;
            [_tableView reloadData];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (BOOL)isValidURL:(NSString *)url {
    if (([url hasPrefix:@"http://www."] || [url hasPrefix:@"https://www."] || [url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) && ([url hasSuffix:@".com/"] || [url hasSuffix:@".org/"] || [url hasSuffix:@".edu/"] || [url hasSuffix:@".net/"] || [url hasSuffix:@".info/"] || [url hasSuffix:@".biz/"] || [url hasSuffix:@".gov/"] || [url hasSuffix:@".com"] || [url hasSuffix:@".org"] || [url hasSuffix:@".edu"] || [url hasSuffix:@".net"] || [url hasSuffix:@".info"] || [url hasSuffix:@".biz"] || [url hasSuffix:@".gov"])) {
        
        NSInteger length_url = [url length];
        
        if ([url hasPrefix:@"http://www."]) {
            length_url = length_url - @"http://www.".length + 1;
        } else if ([url hasPrefix:@"https://www."]) {
            length_url = length_url - @"https://www.".length + 1;
        } else if ([url hasPrefix:@"http://"]) {
            length_url = length_url - @"http://".length + 1;
        } else if ([url hasPrefix:@"https://"]) {
            length_url = length_url - @"https://".length + 1;
        }
        
        if ([url hasSuffix:@".com/"]) {
            length_url = length_url - @".com/".length + 1;
        } else if ([url hasSuffix:@".org/"]) {
            length_url = length_url - @".org/".length + 1;
        } else if ([url hasSuffix:@".edu/"]) {
            length_url = length_url - @".edu/".length + 1;
        } else if ([url hasSuffix:@".net/"]) {
            length_url = length_url - @".net/".length + 1;
        } else if ([url hasSuffix:@".info/"]) {
            length_url = length_url - @".info/".length + 1;
        } else if ([url hasSuffix:@".biz/"]) {
            length_url = length_url - @".biz/".length + 1;
        } else if ([url hasSuffix:@".gov/"]) {
            length_url = length_url - @".gov/".length + 1;
        } else if ([url hasSuffix:@".com"]) {
            length_url = length_url - @".com".length + 1;
        } else if ([url hasSuffix:@".org"]) {
            length_url = length_url - @".org".length + 1;
        } else if ([url hasSuffix:@".edu"]) {
            length_url = length_url - @".edu".length + 1;
        } else if ([url hasSuffix:@".net"]) {
            length_url = length_url - @".net".length + 1;
        } else if ([url hasSuffix:@".info"]) {
            length_url = length_url - @".info".length + 1;
        } else if ([url hasSuffix:@".biz"]) {
            length_url = length_url - @".biz".length + 1;
        } else if ([url hasSuffix:@".gov"]) {
            length_url = length_url - @".gov".length + 1;
        }
        
        if (length_url < 19) {
            return true;
        }
        
    }
    
    return false;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
