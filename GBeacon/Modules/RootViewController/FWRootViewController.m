//
//  FWRootViewController.m
//  FeasyBeacon
//
//  Created by LIDONG on 14-2-28.
//  Copyright (c) 2014年 LIDONG. All rights reserved.
//

#import "FWRootViewController.h"

@interface FWRootViewController ()
@property (nonatomic, strong) NSMutableArray *viewControllerArr;
@end

@implementation FWRootViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.viewControllerArr = [NSMutableArray array];
        
        // Beacon列表
        [self addViewController:@"FWBeaconsViewController" activeImageName:@"tab_icon_beacon_active" normalImageName:@"tab_icon_beacon_nor" title:LS(@"Beacon") tag:0];
        
        // 传感器列表
        [self addViewController:@"FWSensorViewController" activeImageName:@"tab_icon_sensor_active" normalImageName:@"tab_icon_sensor_nor" title:LS(@"Sensor") tag:1];
        
        // 设备列表
        [self addViewController:@"FWSettingsViewController" activeImageName:@"tab_icon_set_active" normalImageName:@"tab_icon_set_nor" title:LS(@"Setting") tag:2];
        
        // 商城
//        [self addViewController:@"FWStoreViewController" activeImageName:@"on" normalImageName:@"off" title:LS(@"Store") tag:3];
        
        // 关于
        [self addViewController:@"FWAboutVC" activeImageName:@"tab_icon_about_active" normalImageName:@"tab_icon_about_nor" title:LS(@"Company Introduction") tag:4];
        
        [self setViewControllers:self.viewControllerArr];
    }
    return self;
}

- (void)addViewController:(NSString *)className activeImageName:(NSString *)activeImgName normalImageName:(NSString *)normalImgName title:(NSString *)title tag:(NSInteger)tag {
    
    UIViewController *viewController = [[NSClassFromString(className) alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] init];
    tabBarItem.title = title;
    tabBarItem.tag = tag;
    
    UITabBarItem *tBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@""] tag:1];
    [navigationController setTabBarItem:tBarItem];
    
    
    // 设置未选中的图标
    UIImage *normalImage = [[UIImage imageNamed:normalImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem.image = normalImage;
    
    // 设置选中时的图标
    UIImage *selectedImage = [[UIImage imageNamed:activeImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem.selectedImage = selectedImage;
    
    UIColor *selectedColor = [UIColor colorWithRed:0xFF/255.f green:0x55/255.f blue:0.f alpha:1.f];
    UIColor *unselectedColor = [UIColor lightGrayColor];
    
    // 设置未选中状态的文字颜色
    [tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : unselectedColor} forState:UIControlStateNormal];
    
    // 设置选中状态的文字颜色
    [tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : selectedColor} forState:UIControlStateSelected];
    
    self.tabBar.tintColor = [UIColor clearColor];
    self.tabBar.unselectedItemTintColor = [UIColor clearColor];
    
    [navigationController setTabBarItem:tabBarItem];
    
    [self.viewControllerArr addObject:navigationController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UIInterfaceOrientationPortrait == toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
