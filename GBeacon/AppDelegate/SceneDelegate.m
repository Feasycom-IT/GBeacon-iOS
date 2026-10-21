//
//  SceneDelegate.m
//  GBeacon
//

#import "SceneDelegate.h"
#import "FWAppDelegate.h"

@implementation SceneDelegate

- (FWAppDelegate *)appDelegate {
    return (FWAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) return;

    // FWAppDelegate 在 didFinishLaunching 中已创建 window 和根控制器，这里挂到场景上
    UIWindow *window = [self appDelegate].window;
    if (!window) {
        window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
        [self appDelegate].window = window;
    }
    window.windowScene = (UIWindowScene *)scene;
    window.frame = ((UIWindowScene *)scene).coordinateSpace.bounds;
    self.window = window;
    [window makeKeyAndVisible];

    // 冷启动时通过文件打开 App
    [self handleURLContexts:connectionOptions.URLContexts];
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    [self handleURLContexts:URLContexts];
}

- (void)handleURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    FWAppDelegate *delegate = [self appDelegate];
    if (![delegate respondsToSelector:@selector(application:openURL:options:)]) return;
    for (UIOpenURLContext *context in URLContexts) {
        [delegate application:[UIApplication sharedApplication] openURL:context.URL options:@{}];
    }
}

- (void)sceneWillResignActive:(UIScene *)scene {
    if ([[self appDelegate] respondsToSelector:@selector(applicationWillResignActive:)]) {
        [[self appDelegate] applicationWillResignActive:[UIApplication sharedApplication]];
    }
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    if ([[self appDelegate] respondsToSelector:@selector(applicationDidBecomeActive:)]) {
        [[self appDelegate] applicationDidBecomeActive:[UIApplication sharedApplication]];
    }
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    if ([[self appDelegate] respondsToSelector:@selector(applicationWillEnterForeground:)]) {
        [[self appDelegate] applicationWillEnterForeground:[UIApplication sharedApplication]];
    }
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    if ([[self appDelegate] respondsToSelector:@selector(applicationDidEnterBackground:)]) {
        [[self appDelegate] applicationDidEnterBackground:[UIApplication sharedApplication]];
    }
}

@end
