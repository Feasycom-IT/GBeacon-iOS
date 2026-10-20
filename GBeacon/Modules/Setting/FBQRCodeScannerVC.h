//
//  FBQRCodeScannerVC.h
//  QCC711Tag
//
//  Created by chenchanghua on 2024/8/2.
//  Copyright © 2024 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol QRCodeScannerViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface FBQRCodeScannerVC : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, weak) id<QRCodeScannerViewControllerDelegate> delegate;
@end

@protocol QRCodeScannerViewControllerDelegate <NSObject>
- (void)didScanQRCodeWithContent:(NSString *)content;
@end

NS_ASSUME_NONNULL_END
