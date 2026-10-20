//
//  FBBeaconUUIDConfigVC.m
//  FeasyBeacon
//
//  Created by chenchanghua on 2024/7/1.
//  Copyright © 2024 Feasycom. All rights reserved.
//

#import "FBBeaconUUIDConfigVC.h"

@interface FBBeaconUUIDConfigVC () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, copy) NSArray *UUIDs;
@end

@implementation FBBeaconUUIDConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadData];
    [self setupNavigationContent];
    [self setupViewContent];
}

- (void)loadData {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"iBeacon-D0koRdBqTmiT7J43ueX_SQ"];
    NSArray *UUIDs = [userDefaults arrayForKey:@"IBeaconUUIDs"];
    self.UUIDs = UUIDs;
}

- (void)updataData:(NSArray *)newUUIDs {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"iBeacon-D0koRdBqTmiT7J43ueX_SQ"];
    [userDefaults setValue:newUUIDs forKey:@"IBeaconUUIDs"];
}

- (void)setupNavigationContent {
    self.title = @"iBeacon-UUID";
    
    UINavigationItem *navigationItem = [self navigationItem];
    UIBarButtonItem *addUUIDItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Add UUID") style:UIBarButtonItemStylePlain target:self action:@selector(addUUIDItemAction)];
    [navigationItem setRightBarButtonItems:@[addUUIDItem]];
}

- (void)setupViewContent {
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.UUIDs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *UUID = self.UUIDs[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FBBeaconUUIDConfigVC-CELL"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FBBeaconUUIDConfigVC-CELL"];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = UUID;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 40;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除数据源中的数据
        NSMutableArray *UUIDs_mut = self.UUIDs.mutableCopy;
        [UUIDs_mut removeObjectAtIndex:indexPath.row];
        [self updataData:UUIDs_mut];
        [self loadData];
        
        // 从表视图中删除单元格
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // 确保表视图的行数和数据源的行数一致
        [tableView reloadData];
    }
}

- (void)addUUIDItemAction {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:LS(@"Add iBeacon UUID") message:[NSString stringWithFormat:@"%@\nA~F,8-4-4-4-12", LS(@"The length and format must be")] preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加文本框
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        // 设置键盘输入为数字键盘
        textField.placeholder = @"A~F,8-4-4-4-12";
        textField.delegate = self;
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    }];
    
    // 添加取消按钮
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:LS(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 取消
    }];
    [alertVC addAction: cancelBtn];
    
    // 添加确定按钮
    UIAlertAction *confirmBtn = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 文本框结束编辑，收起键盘
        [self.view endEditing:YES];
        // 获取文本框填写的内容
        NSString *UUID = [alertVC.textFields firstObject].text;
        // 添加数据源中的数据
        NSMutableArray *UUIDs_mut = self.UUIDs.mutableCopy;
        if (!UUIDs_mut) {
            UUIDs_mut = [NSMutableArray array];
        }
        if (![UUIDs_mut containsObject:UUID]) {
            [UUIDs_mut addObject:UUID];
        }
        [self updataData:UUIDs_mut];
        [self loadData];
        
        // 确保表视图的行数和数据源的行数一致
        [self.tableView reloadData];
    }];
    [alertVC addAction: confirmBtn];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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
    
    textField.text = newString;
    return NO;
}

@end
