//
//  FEDFUFileTableViewController.m
//  BLEAssistant
//
//  Created by ericj on 2018/4/10.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#define cellID       @"cellID"

#import "FEDFUFileTableViewController.h"
#import "FEDFUDownloadViewController.h"
#import "FWUpdateViewController.h"

@interface FEDFUFileTableViewController () <UIDocumentPickerDelegate>

@property (nonatomic, strong) NSArray *typeArray;

@end

@implementation FEDFUFileTableViewController

- (instancetype)init {
    if (self = [super init]) {
        [self setHidesBottomBarWhenPushed:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filePathDidUpdate) name:FWUpdateFilePathNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.typeArray = [NSArray arrayWithObjects:LS(@"Get from QQ"),LS(@"Get from WeChat"), LS(@"Download from web"), LS(@"Get from Documents folder"), nil];//@"从本地获取文件",
    
    [self.tableView setRowHeight:60.f];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
    UITableViewHeaderFooterView *footView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footView;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.typeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.textLabel.text = self.typeArray[indexPath.row];
    // 箭头样式
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mqq://"] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mqq://"]];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else if (indexPath.row == 1) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else if (indexPath.row == 2) {
        UINavigationController *navigationController = [self navigationController];
        NSMutableArray *viewControllers = [[navigationController viewControllers] mutableCopy];
        FEDFUDownloadViewController *viewController = [[FEDFUDownloadViewController alloc] init];
        
        [viewControllers replaceObjectAtIndex:viewControllers.count - 1 withObject:viewController];
        
        [navigationController setViewControllers:viewControllers animated:YES];
    } else if (indexPath.row == 3) {
        [self onSelectFile];
    }
}

- (void)filePathDidUpdate {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)onSelectFile {
    UIDocumentPickerViewController* picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:picker animated:true completion:nil];
    });
}

- (void) documentPicker:(UIDocumentPickerViewController*)controller didPickDocumentAtURL:(NSURL*)url {
    
    // 获取选中的文件名
    NSString *fileName = [url lastPathComponent];
    
    // 构建目标路径
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    // 拷贝文件
    NSError *error;
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    [[NSFileManager defaultManager] copyItemAtURL:url toURL:destinationURL error:&error];
    
    if (error) {
        NSLog(@"Error copying file: %@", [error localizedDescription]);
    } else {
        NSLog(@"File copied successfully to %@", destinationPath);
    }
}

- (void) documentPicker:(UIDocumentPickerViewController*)controller didPickDocumentsAtURLs:(NSArray<NSURL*>*)urls {
    [self documentPicker:controller didPickDocumentAtURL:urls[0]];
}

@end
