//
//  FWADView.m
//  FeasyWIFI
//
//  Created by ericj on 2020/7/14.
//  Copyright © 2020 Feasycom. All rights reserved.
//

#import "FWADView.h"
#import "FWADRootClass.h"
#import <SDWebImage.h>
#import "AFNetworking.h"

#define kRequestURL @"https://feasycomm.com/api/lanch/ad/ad"

@interface FWADView ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *secondBtn;
@property (nonatomic, strong) FWADData *adData;
@property (nonatomic, assign) NSInteger seconds;
@property (nonatomic) BOOL isCN;
@end

@implementation FWADView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self addButton];
    NSString *language = [[NSLocale preferredLanguages] firstObject];
    NSLog(@"当前首选语言: %@", language);
    if ([language isEqualToString:@"zh-Hans-CN"]){
        self.isCN = YES;
    }else {
        self.isCN = NO;
    }
}

// 添加3个触控按键
- (void)addButton{
    // 缩放比例
    CGFloat scale = self.bounds.size.height / (175+280*3+200);
    // 元素高度
    float height_midBtn = 280*scale;
    // 添加可点击区域（示例坐标，需根据实际设计调整）
    [self addTapArea:CGRectMake(0, 175*scale, self.bounds.size.width, height_midBtn) forTag:1]; // 左上区域
    [self addTapArea:CGRectMake(0, 175*scale+height_midBtn, self.bounds.size.width, height_midBtn) forTag:2]; // 右上区域
    [self addTapArea:CGRectMake(0, 175*scale+height_midBtn*2, self.bounds.size.width, height_midBtn) forTag:3]; // 底部区域
}

- (void)addTapArea:(CGRect)frame forTag:(NSInteger)tag {
    UIButton *invisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    invisibleButton.frame = frame;
    invisibleButton.tag = tag;
    /* 检测覆盖范围准度
     if (tag == 1) {
     invisibleButton.backgroundColor = [UIColor redColor];
     invisibleButton.alpha = 0.5;
     } else if (tag == 2) {
     invisibleButton.backgroundColor = [UIColor yellowColor];
     invisibleButton.alpha = 0.5;
     } else if (tag == 3) {
     invisibleButton.backgroundColor = [UIColor blueColor];
     invisibleButton.alpha = 0.5;
     }
     */

    [invisibleButton addTarget:self action:@selector(handleAdTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:invisibleButton];
}

- (void)handleAdTap:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:self.isCN ? self.adData.cnurl1 : self.adData.enurl1];
    switch (sender.tag) {
        case 2:
            url = [NSURL URLWithString:self.isCN ? self.adData.cnurl2 : self.adData.enurl2];
            break;
        case 3:
            url = [NSURL URLWithString:self.isCN ? self.adData.cnurl3 : self.adData.enurl3];
            break;
        default:
            break;
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            if (!success) {
                NSLog(@"Failed to open URL: %@", url);
            }
        }];
    }
    [self clickClose:nil];
}

+ (UIImage *)getLaunchImage {
    UIImage *launchImg = nil;
    NSString *orientation = @"";
    const CGSize screenSize = [UIScreen mainScreen].bounds.size;
    const UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (statusBarOrientation == UIInterfaceOrientationLandscapeLeft || statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        orientation = @"Landscape";
    } else {
        orientation = @"Portrait";
    }
    NSArray *imgsInfoArr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UILaunchImages"];
    NSLog(@"UILaunchImages:\n%@", imgsInfoArr);
    for (NSDictionary *info in imgsInfoArr) {
        const CGSize imgSize = CGSizeFromString(info[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imgSize, screenSize) && [orientation isEqualToString:info[@"UILaunchImageOrientation"]] ) {
            launchImg = [UIImage imageNamed:info[@"UILaunchImageName"]];
        }
    }
    return launchImg;
}

+ (void)showWithSeconds:(NSInteger)seconds{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    FWADView *targetView = [[[NSBundle mainBundle] loadNibNamed:@"FWADView" owner:nil options:0] firstObject];
    targetView.frame = window.bounds;
    [window addSubview:targetView];
    
    targetView.seconds = seconds;
    NSLog(@"进来了");
    [targetView.secondBtn setTitle:[NSString stringWithFormat:@"%lds", targetView.seconds] forState:UIControlStateNormal];
    targetView.secondBtn.enabled = NO;
    targetView.secondBtn.hidden = YES;
    __weak typeof(targetView) weakself = targetView;
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"adlanch"];
    targetView.adData = [[FWADData alloc] initWithDictionary:dic];
    UIImage *placeholder = [UIImage imageNamed:@"LaunchImage"];
    NSLog(@"默认图片：%@", placeholder);
    NSString *imageUrl = targetView.isCN ? targetView.adData.cnimg : targetView.adData.enimg;
    [targetView.imageView setImage:placeholder];
    // 从服务器获取最新广告页图片的URL地址
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] init];
    httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [httpSessionManager POST:kRequestURL parameters:@{@"platform" : @"iOS",@"appBoundId":[[NSBundle mainBundle] bundleIdentifier]} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        FWADRootClass *root = [[FWADRootClass alloc] initWithDictionary:responseObject];
        if (root.code != 0){
            [weakself clickClose:nil];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary new] forKey:@"adlanch"];
            return;
        }
        targetView.secondBtn.hidden = NO;
        weakself.adData = root.data;
        [weakself.imageView sd_setImageWithURL:[NSURL URLWithString:weakself.isCN ? weakself.adData.cnimg : weakself.adData.enimg] placeholderImage:placeholder];
        [[NSUserDefaults standardUserDefaults] setObject:[weakself.adData toDictionary] forKey:@"adlanch"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 如果没网，没缓存就不显示广告
        if (!imageUrl){
            [weakself clickClose:nil];
        } else {
            targetView.secondBtn.hidden = NO;
            [targetView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:placeholder];
        }
    }];
    // 有倒计时开启倒计时
    if (targetView.seconds > 0){
        [NSTimer scheduledTimerWithTimeInterval:1 target:targetView selector:@selector(secondTimerGo:) userInfo:nil repeats:YES];
    }
}

// 关闭开屏页
- (IBAction)clickClose:(id)sender {

    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakself.alpha = 0;
    } completion:^(BOOL finished) {
        [weakself removeFromSuperview];
    }];
}

// 倒计时
- (void)secondTimerGo:(NSTimer *)timer {
    self.seconds--;
    NSString *secondString = [NSString stringWithFormat:@"%lds", self.seconds];
    self.secondBtn.titleLabel.text = secondString;
    [self.secondBtn setTitle:secondString forState:UIControlStateNormal];
    if (self.seconds == 0){
        [self clickClose:nil];
        [timer invalidate];
    }
}

@end
