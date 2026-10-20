//
//  FWAboutVC.m
//  FeasyWIFI
//
//  Created by chenchanghua on 2021/12/6.
//  Copyright © 2021 Feasycom. All rights reserved.
//

#import "FWAboutVC.h"
#import "Masonry.h"
#import "FEFunctionButton.h"
#import "FEFeedbackViewController.h"
#import "FBSDKPublicHeader.h"
#import "FEDevelopDebugVC.h"

typedef NS_ENUM(NSInteger, FunctionType) {
    FunctionTypeOfficialWebsite,
    FunctionTypePhoneConsult,
    FunctionTypeEmailConsult,
    FunctionTypeFeedback
};


@interface FWAboutVC ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) NSMutableArray<FEFunctionButton *> *functionButtons;

@end

@implementation FWAboutVC

- (id)init {
    self = [super init];
    if (self) {
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:LS(@"Company Introduction") image:[UIImage imageNamed:@"关于"] tag:4];
        [self setTabBarItem:tabBarItem];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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
    self.title = LS(@"Company Introduction");
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupInfo];
    
    self.functionButtons = [NSMutableArray array];
    [self setupControl];
    [self createFunctionGrid];
    [self setupVersion];
    
}

- (void)setupInfo {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    
    [self.view addSubview:self.scrollView];
    
    // 顶部背景图
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*0.4)];
    headerView.backgroundColor = [UIColor colorWithRed:0.20 green:0.40 blue:0.80 alpha:1.0];
    [headerView setImage:[UIImage imageNamed:@"about_banner_company.png"]];
    // 增加一个「点击5次手势」进入「开发者调试界面」
    headerView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processgestureReconizer)];
    singleTap.numberOfTapsRequired = 5;
    [headerView addGestureRecognizer:singleTap];
    
    [self.scrollView addSubview:headerView];
    
    // 信息View
    UIView *infoview = [[UIView alloc] initWithFrame:CGRectMake(20, (self.view.frame.size.width-40)*0.41, self.view.frame.size.width-40, 300)];
    infoview.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.00];
    // Shadow Code
    infoview.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.04].CGColor;
    infoview.layer.shadowOffset = CGSizeMake(0,0);
    infoview.layer.shadowRadius = 12;
    infoview.layer.shadowOpacity = 1;
    // Radius Code
    infoview.layer.cornerRadius = 8;
    
    UILabel *titlelabel = [[UILabel alloc] init];
    titlelabel.alpha = 1;
    titlelabel.adjustsFontSizeToFitWidth = true;
    titlelabel.text = LS(@"Feasycom");
    titlelabel.textAlignment = NSTextAlignmentLeft;
    titlelabel.textColor = [UIColor colorWithRed:0/255.0 green:117/255.0 blue:201/255.0 alpha:1.00];
    titlelabel.font = [UIFont boldSystemFontOfSize:16.0];
    [infoview addSubview:titlelabel];
    [titlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(18);        // 左上角
        make.right.offset(-18);   // 右
    }];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.frame = CGRectMake(20, 50, infoview.frame.size.width-40, 232);
    infoLabel.alpha = 1;
    infoLabel.numberOfLines = 0;
    NSMutableAttributedString *string = [
        [NSMutableAttributedString alloc] initWithString:LS(@"Feasycom detail")
        attributes: @{
        NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13],
        NSForegroundColorAttributeName: [UIColor colorWithRed:24/255.0 green:24/255.0 blue:24/255.0 alpha:1.00],
    }];
    infoLabel.attributedText = string;
    infoLabel.textAlignment = NSTextAlignmentLeft;
    [infoview addSubview:infoLabel];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titlelabel.mas_bottom).offset(18);
        make.left.offset(18);        // 左上角
        make.bottom.right.offset(-18);   // 右
        make.bottom.equalTo(infoview).offset(-20);
    }];
    self.infoView = infoview;
    
    [self.scrollView addSubview:infoview];
    __weak typeof(self) weakSelf = self;
    [infoview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf.scrollView).offset(-40);
        make.top.offset(weakSelf.view.frame.size.width * 0.29);
        make.left.offset(20);        // 左上角
        make.right.offset(-20);   // 右
    }];
    
}

- (void)setupControl{
    // 内容视图
    self.controlView = [[UIView alloc] init];
    [self.scrollView addSubview:self.controlView];
    
    // 设置约束
    [self setupConstraints];
}


- (void)setupConstraints {
    __weak typeof(self) weakSelf = self;
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.width.equalTo(weakSelf.scrollView).offset(-40);
        make.top.equalTo(weakSelf.infoView.mas_bottom).offset(20);
        make.height.greaterThanOrEqualTo(@0);
    }];
    self.controlView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.controlView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.04].CGColor;
    self.controlView.layer.shadowOffset = CGSizeMake(0,0);
    self.controlView.layer.shadowRadius = 12;
    self.controlView.layer.shadowOpacity = 1;
    // Radius Code
    self.controlView.layer.cornerRadius = 8;
}

- (void)createFunctionGrid {
    // 功能数据
    NSArray *functionData = @[
        @{@"icon": @"about/icon_website", @"title": LS(@"Website"), @"type": @(FunctionTypeOfficialWebsite)},
        @{@"icon": @"about/icon_email", @"title": LS(@"Email"), @"type": @(FunctionTypeEmailConsult)},
        @{@"icon": @"about/icon_feedback", @"title": LS(@"Feed Back"), @"type": @(FunctionTypeFeedback)}
    ];
    
    // 创建功能按钮
    for (NSDictionary *data in functionData) {
        FEFunctionButton *button = [[FEFunctionButton alloc] initWithIconName:data[@"icon"] title:data[@"title"]];
        button.tag = [data[@"type"] integerValue];
        [button addTarget:self action:@selector(functionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.controlView addSubview:button];
        [self.functionButtons addObject:button];
    }
    
    
    
    // 设置网格布局约束
    [self setupGridLayout];
}

- (void)processgestureReconizer {
    FEDevelopDebugVC *developDebugVC = [[FEDevelopDebugVC alloc] init];
    developDebugVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:developDebugVC animated:YES];
}

- (void)setupVersion{
    // 获取版本号（Version）
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    UILabel *verLabel = [[UILabel alloc] init];
    verLabel.frame = CGRectMake(94, 685, 187, 16);
    verLabel.alpha = 1;
    [self.view addSubview:verLabel];
    NSMutableAttributedString *string = [
      [NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@  %@%@", LS(@"App Version"), appVersion, LS(@"SDK Version"), [FBBluetoothBrowser sdkVersion]]
      attributes: @{
        NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 12],
        NSForegroundColorAttributeName: [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1.00],
    }];
    verLabel.attributedText = string;
    verLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:verLabel];
    __weak typeof(self) weakSelf = self;
    [verLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.controlView.mas_bottom).offset(20);
        make.bottom.offset(-20);
        make.size.mas_equalTo(CGSizeMake(self.scrollView.frame.size.width, 30));
    }];
}

- (void)setupGridLayout {
    if (self.functionButtons.count != 3) return;
    
    // 布局参数
    CGFloat spacing = 0; // 按钮间距

    // 第一行按钮
    FEFunctionButton *button1 = self.functionButtons[0];
    FEFunctionButton *button2 = self.functionButtons[1];
    FEFunctionButton *button3 = self.functionButtons[2];
    
    __weak typeof(self) weakSelf = self;
    // 设置按钮大小和位置约束
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.infoView.mas_bottom).offset(20);
        make.leading.equalTo(weakSelf.infoView).offset(0);
        make.width.equalTo(button2);
        make.height.equalTo(button1.mas_width); // 保持正方形
    }];
    
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button1);
        make.leading.equalTo(button1.mas_trailing).offset(spacing);
        make.width.equalTo(button3);
        make.height.equalTo(button1);
    }];
    
    [button3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button1);
        make.leading.equalTo(button2.mas_trailing).offset(spacing);
        make.trailing.equalTo(weakSelf.controlView).offset(-spacing);
        make.width.equalTo(button1);
        make.height.equalTo(button3.mas_width); // 保持正方形
        make.bottom.equalTo(weakSelf.controlView).offset(0);
    }];
}

#pragma mark - 按钮点击事件
- (void)functionButtonTapped:(FEFunctionButton *)sender {
    // 添加点击动画效果
    [UIView animateWithDuration:0.1 animations:^{
        sender.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            sender.transform = CGAffineTransformIdentity;
        }];
    }];
    
    switch (sender.tag) {
        case FunctionTypeOfficialWebsite:
            [self openOfficialWebsite];
            break;
        case FunctionTypeEmailConsult:
            [self sendEmail];
            break;
        case FunctionTypeFeedback:
            [self showFeedback];
            break;
    }
}

#pragma mark - 功能方法实现
- (void)openOfficialWebsite {
    NSURL *url = [NSURL URLWithString:@"https://www.glowbird.com"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)sendEmail {
    NSString *email = @"sales@glowbird.com";
    NSString *emailURLString = [NSString stringWithFormat:@"mailto:%@", email];
    NSURL *emailURL = [NSURL URLWithString:emailURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:emailURL]) {
        [[UIApplication sharedApplication] openURL:emailURL options:@{} completionHandler:nil];
    }
}

- (void)showFeedback {
    [self.navigationController pushViewController:[[FEFeedbackViewController alloc] init] animated:YES];
}


@end
