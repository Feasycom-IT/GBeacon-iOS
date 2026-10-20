//
//  FBVersionCheck.m
//  QCC711Tag
//
//  Created by chenchanghua on 2024/8/3.
//  Copyright © 2024 Feasycom. All rights reserved.
//

#import "FBVersionCheck.h"

@implementation FBVersionCheck

// App Store ID
static NSString * const appID = @"1277151788";

- (void)checkForUpdate {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *bundleIdentifier = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?bundleId=%@", bundleIdentifier];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *results = json[@"results"];
            if (results.count > 0) {
                NSDictionary *appStoreInfo = results.firstObject;
                NSString *appStoreVersion = appStoreInfo[@"version"];
                
                if ([self isUpdateAvailableWithCurrentVersion:currentVersion appStoreVersion:appStoreVersion]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showUpdateAlertWithAppStoreVersion:appStoreVersion];
                    });
                }
            }
        }
    }];
    
    [task resume];
}

- (BOOL)isUpdateAvailableWithCurrentVersion:(NSString *)currentVersion appStoreVersion:(NSString *)appStoreVersion {
    return ([currentVersion compare:appStoreVersion options:NSNumericSearch] == NSOrderedAscending);
}

- (void)showUpdateAlertWithAppStoreVersion:(NSString *)appStoreVersion {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *topController = keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Update Available")
                                                                             message:[NSString stringWithFormat:@"%@ (%@) is %@", LS(@"Update Available"), appStoreVersion, LS(@"is available on the App Store.")]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:LS(@"Update") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appID];
        NSURL *url = [NSURL URLWithString:urlString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:updateAction];
    [alertController addAction:cancelAction];
    
    [topController presentViewController:alertController animated:YES completion:nil];
}


@end
