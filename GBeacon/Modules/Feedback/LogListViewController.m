//
//  LogListViewController.m
//  BLEAssistant
//
//  Created by chenchanghua on 2024/10/23.
//  Copyright © 2024 feasycom. All rights reserved.
//

#import "LogListViewController.h"
#import <QuickLook/QuickLook.h>
#import "FSCLogExportManager.h"

@interface LogListViewController () <UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDataSource>
@property (nonatomic, strong) NSMutableArray<NSString *> *logFiles; // 保存日志文件路径（改为可变数组，方便增删）
@property (nonatomic, strong) NSString *selectedFilePath; // 当前选中的日志文件路径
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation LogListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LS(@"Log List");
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建表视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    // 获取日志文件列表
    [self loadLogFiles];
    
    // 添加右上角“删除全部”按钮
    UIBarButtonItem *deleteAllButton = [[UIBarButtonItem alloc] initWithTitle:LS(@"Delete All")
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(deleteAllLogs)];
    self.navigationItem.rightBarButtonItem = deleteAllButton;
}

// 一次性删除所有日志
- (void)deleteAllLogs {
    if (self.logFiles.count == 0) {
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Confirm Deletion")
                                                                             message:LS(@"Do you want to delete all log files?")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LS(@"DELETE") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        for (NSString *filePath in self.logFiles) {
            [fileManager removeItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"删除文件失败: %@", error.localizedDescription);
            }
        }
        [self.logFiles removeAllObjects];
        [self.tableView reloadData];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)loadLogFiles {
    NSString *logFolderPath = [FSCLogExportManager shared].logFolderPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:logFolderPath error:&error];
    
    if (error) {
        NSLog(@"读取日志文件失败: %@", error.localizedDescription);
        self.logFiles = [NSMutableArray array];
    } else {
        NSMutableArray *logPaths = [NSMutableArray array];
        for (NSString *fileName in files) {
            NSString *filePath = [logFolderPath stringByAppendingPathComponent:fileName];
            [logPaths addObject:filePath];
        }
        
        // 按文件名进行排序
        NSArray *sortedLogPaths = [logPaths sortedArrayUsingComparator:^NSComparisonResult(NSString *filePath1, NSString *filePath2) {
            NSString *fileName1 = [filePath1 lastPathComponent];
            NSString *fileName2 = [filePath2 lastPathComponent];
            return [fileName1 compare:fileName2 options:NSCaseInsensitiveSearch];
        }];
        
        self.logFiles = [NSMutableArray arrayWithArray:sortedLogPaths];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LogFileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *filePath = self.logFiles[indexPath.row];
    cell.textLabel.text = [filePath lastPathComponent]; // 显示文件名
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFilePath = self.logFiles[indexPath.row];
    [self previewLogFile];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1; // 只预览一个文件
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:self.selectedFilePath];
}

- (void)previewLogFile {
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    [self presentViewController:previewController animated:YES completion:nil];
}

#pragma mark - UITableView Editing (删除日志文件)

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 获取要删除的文件路径
        NSString *filePath = self.logFiles[indexPath.row];
        
        // 删除文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (success) {
            // 文件删除成功，从数组中移除对应项
            [self.logFiles removeObjectAtIndex:indexPath.row];
            
            // 从表视图中删除对应行
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            NSLog(@"删除文件失败: %@", error.localizedDescription);
            
            // 可以考虑弹出提示，告诉用户删除失败
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除失败" message:@"无法删除该日志文件" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

@end
