//
//  FBQRCodeScannerVC.m
//  QCC711Tag
//
//  Created by chenchanghua on 2024/8/2.
//  Copyright © 2024 Feasycom. All rights reserved.
//

#import "FBQRCodeScannerVC.h"

@interface FBQRCodeScannerVC ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation FBQRCodeScannerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self startQRCodeScanning];
}

- (void)startQRCodeScanning {
    // 创建捕获会话
    self.session = [[AVCaptureSession alloc] init];
    
    // 获取设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 创建输入
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"Error creating input: %@", error.localizedDescription);
        return;
    }
    [self.session addInput:input];
    
    // 创建输出
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:output];
    
    // 设置输出元数据类型为二维码
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // 创建视频预览图层
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.videoPreviewLayer.frame = self.view.layer.bounds;
    [self.view.layer addSublayer:self.videoPreviewLayer];
    
    // 在后台线程启动捕获会话
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.session startRunning];
    });
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        [self.session stopRunning];
        
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects firstObject];
        if ([metadataObj.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *qrCodeContent = metadataObj.stringValue;
            NSLog(@"QR Code Content: %@", qrCodeContent);
            
            // 返回到调用的视图控制器
            __weak typeof(self) weakSelf = self;
            [self dismissViewControllerAnimated:YES completion:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                // 调用代理方法，将结果传递回去
                if ([strongSelf.delegate respondsToSelector:@selector(didScanQRCodeWithContent:)]) {
                    [strongSelf.delegate didScanQRCodeWithContent:qrCodeContent];
                }
            }];
        }
    }
}

@end
