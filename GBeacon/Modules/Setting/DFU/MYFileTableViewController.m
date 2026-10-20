//
//  MYFileTableViewController.m
//  rytztool
//
//  Created by MingYueYu on 2019/7/31.
//  Copyright © 2019 MingYueYu. All rights reserved.
//

#import "MYFileTableViewController.h"
#import "FEDFUFileTableViewController.h"
#import "FWUpdateViewController.h"
#import "MYFileModel.h"

@interface MYFileTableViewController ()
@property (nonatomic, strong) MYFileModel *model;
@end

@implementation MYFileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0: return 0;
        default: return self.model.filePaths.count > 0 ? 30 : 30;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1: return [NSString stringWithFormat:@"/%@", [self.model.filePaths componentsJoinedByString:@"/"]];
        default: return @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return self.model.filePaths.count > 0 ? 1 : 0;
        case 1: return self.model.list.count;
        case 2: return 0;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"...";
            cell.detailTextLabel.text = LS(@"Return to the previous directory");
            cell.imageView.image = [UIImage imageNamed:@"before_folder"];
            return cell;
        }
            break;
            
        case 1: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
            }
            MYFileRootClass *data = self.model.list[indexPath.row];
            if ([data.type isEqualToString:NSFileTypeDirectory]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else{
                cell.accessoryType = UITableViewCellAccessoryDetailButton;
            }
            cell.textLabel.text = data.fileName;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@", [MYFileModel stringFromeResourceSize:data.fileSize], [MYFileModel stringFromeTimeInterval:data.modificationTime]];
            cell.imageView.image = [MYFileModel fileImageWithData:data];
            return cell;
        }
            break;
            
        case 2: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"importCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"importCell"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = LS(@"Import firmware");
            }
            
            return cell;
        }
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0: {
            [self.model.filePaths removeLastObject];
            [self reloadData];
        }
            break;
            
        case 1: {
            MYFileRootClass *data = self.model.list[indexPath.row];
            if ([data.type isEqualToString:NSFileTypeDirectory]) {
                [self.model.filePaths addObject:data.fileName];
                [self reloadData];
            }else{
                NSString *extension = [[data.fileName pathExtension] lowercaseString];
                if ([extension isEqualToString:@"dfu"] || [extension isEqualToString:@"bin"]) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:FWUpdateFilePathNotification object:nil userInfo:@{ @"url" : data.url }];
                    [self.navigationController popViewControllerAnimated:YES];
                    
//                    UIViewController *vc;
//                    if ([data.fileName isEqualToString:@"version.plist"]) {
//                        vc = [[MYVersionPlistTextVC alloc] initWithData:data];
//                    }else if ([data.fileName isEqualToString:@"download.plist"]){
//                        vc = [[MYPlistTextVC alloc] initWithData:data];
//                    }else{
//                        vc = [[MYEditTextVC alloc] initWithData:data];
//                    }
//                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
            break;
            
        case 2: {
            FEDFUFileTableViewController *viewController = [[FEDFUFileTableViewController alloc] init];
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            break;
            
        default: {
            MYFileRootClass *data = self.model.list[indexPath.row];
            NSString *detail = [NSString stringWithFormat:@"%@%ld\n%@%@\n%@%@\n%@%@", LS(@"Size: "), /*[MYFTPModel stringFromeResourceSize:data.fileSize]*/data.fileSize, LS(@"Update Time: "), [MYFileModel stringFromeTimeInterval:data.modificationTime], LS(@"Group: "), data.groupName, LS(@"Owner: "), data.owner];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:data.fileName message:detail preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(self) weakSelf = self;
//            UIAlertAction *uploadAction = [UIAlertAction actionWithTitle:LS(@"Upload") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                UIAlertController *alert_progress = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@%@", LS(@"Uploading"), data.fileName] message:[NSString stringWithFormat:@"%@0%%", LS(@"Upload Progress: ")] preferredStyle:UIAlertControllerStyleAlert];
//                [weakSelf presentViewController:alert_progress animated:YES completion:nil];
//                [weakSelf.homeModel.ftpModel uploadFile:data progress:^(NSInteger totalSize, NSInteger finishedSize) {
//                    dispatch_async(dispatch_get_main_queue(),^{
//                        CGFloat progress = finishedSize * 1.0 / totalSize * 100;
//                        alert_progress.message  = [NSString stringWithFormat:@"上传进度：%.2f%%", progress];
//                    });
//                } success:^(NSString * _Nullable msg) {
//                    dispatch_async(dispatch_get_main_queue(),^{
//                        alert_progress.title= @"已上传完毕";
//                        alert_progress.message  = @"上传进度：100%";
//                        [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
//                            [alert_progress dismissViewControllerAnimated:YES completion:nil];
//                        }];
//                    });
//                } fail:^(NSString * _Nullable msg) {
//
//                }];
//            }];
            UIAlertAction *renameAction = [UIAlertAction actionWithTitle:LS(@"Rename") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf renameWithData:data];
            }];
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:LS(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击了NO按钮");
            }];
//            [alert addAction:uploadAction];
            [alert addAction:renameAction];
            [alert addAction:noAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
    }
}
                                           

- (void)renameWithData:(MYFileRootClass *)data{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LS(@"title") message:LS(@"message") preferredStyle:UIAlertControllerStyleAlert];
    // 2.创建框中的按钮
    __weak typeof(self) weakSelf = self;
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:LS(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 获取在文本框中的输入
        if (alert.textFields[0].text.length > 0) {
            [weakSelf.model renameData:data toName:alert.textFields[0].text success:^{
                [weakSelf reloadData];
            } faile:^{
                
            }];
        }
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:LS(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = data.fileName;
    }];
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];

}

//设置可编辑，删除必须
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//滑动删除begin预处理
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath*)indexPath{}
//滑动删除结束处理
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath*)indexPath{}
//修改左滑的按钮的字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
//左滑点击事件
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    MYFileRootClass *data = self.model.list[indexPath.row];
    __weak typeof(self) weakSelf = self;
    [self.model delectData:data Success:^{
        [weakSelf.tableView reloadData];
    } faile:^{
        
    }];
    
}

- (void)reloadData{
    __weak typeof(self) weakSelf = self;
    [self.model showFileList:self.model.fieldPath success:^{
        [weakSelf.tableView reloadData];
    } faile:^{
        
    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - lazy

- (MYFileModel *)model{
    if (!_model) {
        _model = [[MYFileModel alloc] init];
    }
    return _model;
}

@end
