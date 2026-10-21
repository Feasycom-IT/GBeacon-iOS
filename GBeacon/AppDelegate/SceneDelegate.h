//
//  SceneDelegate.h
//  GBeacon
//
//  iOS 新 SDK 要求必须采用 UIScene 生命周期。
//  这里复用 FWAppDelegate 已创建的 window，并把场景回调转发给 FWAppDelegate。
//

#import <UIKit/UIKit.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (nonatomic, strong) UIWindow *window;

@end
