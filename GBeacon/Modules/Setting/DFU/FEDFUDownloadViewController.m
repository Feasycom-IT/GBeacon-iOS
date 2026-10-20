//
//  FEDFUDownloadViewController.m
//  BLEAssistant
//
//  Created by LiDong on 2020/6/11.
//  Copyright © 2020 feasycom. All rights reserved.
//

#import "FEDFUDownloadViewController.h"
#import "FWUpdateViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface FEDFUDownloadViewController ()

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) BOOL failed;

@end

@implementation FEDFUDownloadViewController

- (instancetype)init {
    if (self = [super init]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = self.view;
    
    [view setBackgroundColor:[UIColor whiteColor]];
    
    const CGRect bounds = [[UIScreen mainScreen] bounds];
    
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 100, 20)];
    [_statusLabel setFont:[UIFont systemFontOfSize:14]];
    [view addSubview:_statusLabel];
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.size.width - 130, 20, 100, 20)];
    [_progressLabel setTextAlignment:NSTextAlignmentRight];
    [_progressLabel setFont:[UIFont systemFontOfSize:14]];
    [_progressLabel setText:@"%0"];
    [view addSubview:_progressLabel];
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30, 70, bounds.size.width - 60, 32)];
    [view addSubview:_progressView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Please enter the download path of the firmware") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    __weak __typeof(self) weakSelf = self;
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = LS(@"Download file name");
        weakSelf.textField = textField;
    }];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (0 == weakSelf.textField.text.length) {
            [weakSelf createAlertController:LS(@"Wrong file name")];
            return;
        }
        [weakSelf startDownloading];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"CANCEL") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:OKAction];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
}

- (void)startDownloading {
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] <= AFNetworkReachabilityStatusNotReachable) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"NETWORK_NOT_REACHABLE") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:okAction];
        [self.navigationController presentViewController:alertController animated:YES completion:NULL];
        return;
    }
    
    [_statusLabel setText:LS(@"DOWNLOADING")];
    
    __weak __typeof(self) weakSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *URLString = [NSString stringWithFormat:@"https://dfu.feasycom.com/%@.dfu", self.textField.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        const double percentage = downloadProgress.fractionCompleted;
        const dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * (double)NSEC_PER_SEC));
        
        dispatch_after(time, dispatch_get_main_queue(), ^{
            if (!weakSelf.failed) {
                [weakSelf.progressView setProgress:percentage];
                [weakSelf.progressLabel setText:[NSString stringWithFormat:@"%.1f%%", percentage * 100.f]];
            }
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        weakSelf.filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:response.suggestedFilename];
        [[NSFileManager defaultManager] removeItemAtPath:weakSelf.filePath error:NULL];
        return [NSURL fileURLWithPath:weakSelf.filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil == error) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                if (filePath && [fileManager fileExistsAtPath:[filePath path]]) {
                    NSString *fileName = filePath.lastPathComponent;
                    NSString *folderName = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                    NSString *targetFilePath = [folderName stringByAppendingPathComponent:fileName];
                    
                    if ([fileManager fileExistsAtPath:targetFilePath]) {
                        [fileManager removeItemAtPath:targetFilePath error:NULL];
                    }
                    
                    [fileManager moveItemAtPath:[filePath path] toPath:targetFilePath error:NULL];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:FWUpdateFilePathNotification object:nil userInfo:@{ @"url" : targetFilePath }];
                    [weakSelf.statusLabel setText:LS(@"DOWNLOAD_SUCCEEDED")];
                    [weakSelf.statusLabel sizeToFit];
                }
            } else {
                NSLog(@"error: %@", error);
                [weakSelf.statusLabel setText:LS(@"DOWNLOAD_FAILED")];
                [weakSelf.statusLabel sizeToFit];
                weakSelf.failed = YES;
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                
                if (404 == httpResponse.statusCode) {
                    [weakSelf createAlertController:LS(@"Wrong file name")];
                }
            }
        });
    }];
    
    [downloadTask resume];
}

- (void)createAlertController:(NSString *)string {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:string message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:okAction];
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
}

@end
