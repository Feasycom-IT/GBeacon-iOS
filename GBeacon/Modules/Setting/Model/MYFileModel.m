//
//  MYFileModel.m
//  rytztool
//
//  Created by MingYueYu on 2019/8/1.
//  Copyright © 2019 MingYueYu. All rights reserved.
//

#import "MYFileModel.h"
#import <UIKit/UIKit.h>

@interface MYFileModel ()
@end

@implementation MYFileModel

// 文件路径
- (NSString *)fieldPath{
    NSLog(@"文件路径：：：：：%@", [self.filePaths componentsJoinedByString:@"/"]);
    return [self.filePaths componentsJoinedByString:@"/"];
}

// 获取文件列表，需要路径参数，为空 获取根目录
- (void)showFileList:(NSString *)path success:(void(^)(void))success faile:(void(^)(void))faile{
    NSString *url_string = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    url_string = [url_string stringByAppendingPathComponent:path];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:url_string];
    NSString *fileName;
    BOOL isOK = YES;
    NSMutableArray *targetArray = [[NSMutableArray alloc] init];
    while (fileName = [dirEnum nextObject]) {
        NSLog(@"读取中------%@", fileName);
        if ([fileName containsString:@"/"]) continue;
        MYFileRootClass *fileDetail = [[MYFileRootClass alloc] init];
        fileDetail.fileName = fileName;
        fileDetail.url = [url_string stringByAppendingPathComponent:fileName];
        NSError *error = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileDetail.url error:&error];
        if (!error) {
            NSLog(@"读到了%@", fileName);
            NSDate *date = [fileAttributes objectForKey:NSFileCreationDate];
            fileDetail.createTime = [date timeIntervalSince1970];
            date = [fileAttributes objectForKey:NSFileModificationDate];
            fileDetail.modificationTime = [date timeIntervalSince1970];
            fileDetail.fileSize = [[fileAttributes objectForKey:NSFileSize] integerValue];
            fileDetail.groupName = [fileAttributes objectForKey:NSFileGroupOwnerAccountName];
            fileDetail.owner = [fileAttributes objectForKey:NSFileOwnerAccountName] ?: @"0";
            fileDetail.type = [fileAttributes objectForKey:NSFileType];
            [targetArray addObject:fileDetail];
        }else{
            isOK = NO;
            break;
        }
    }
    if (isOK && success) {
        self.list = targetArray;
        [self sort];
        NSLog(@"读取文件成功");
        success();
    }
    if (!isOK && faile) {
        faile();
    }
}

// 字典转JSON字符串
- (NSString *)toJsonString:(NSDictionary *)dic{
    if (!self) return nil;
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *targetString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    targetString = [targetString stringByReplacingOccurrencesOfString:@": null" withString:@": \"\""];
    return targetString;
}

// 删除文件
- (void)delectData:(MYFileRootClass *)data Success:(void(^)(void))success faile:(void(^)(void))faile{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:data.url error:&error];
    if (!error) {
        [self.list removeObject:data];
        if (success) success();
    }else{
        NSLog(@"---- %@", error);
        if (faile) faile();
    }
}

// 重命名文件
- (void)renameData:(MYFileRootClass *)data toName:(NSString *)name success:(void(^)(void))success faile:(void(^)(void))faile{
    NSError *error = nil;
    NSString *url = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:name];
    NSLog(@"重命名\n%@\n%@\n", data.url, url);
    [[NSFileManager defaultManager] moveItemAtPath:data.url toPath:url error:&error];
    if (!error) {
        data.url = url;
        if (success) success();
    }else{
        NSLog(@"---- %@", error);
        if (faile) faile();
    }
}

// 文件大小
+ (NSString *)stringFromeResourceSize:(NSInteger)resourceSize{
    return [NSByteCountFormatter stringFromByteCount:resourceSize countStyle:NSByteCountFormatterCountStyleFile];
}

// 文件对应的自定义图标
+ (UIImage *)fileImageWithData:(MYFileRootClass *)data{
    if ([data.type isEqualToString:NSFileTypeDirectory]) {
        return [UIImage imageNamed:@"folder"];
    }else if ([data.type isEqualToString:NSFileTypeRegular]){
        NSString *extension = [data.fileName pathExtension];
        if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"PNG"]) {
            return [UIImage imageNamed:@"picture"];
        }else if ([extension isEqualToString:@"plist"] || [extension isEqualToString:@"PLIST"]) {
            return [UIImage imageNamed:@"text_file"];
        }else if ([extension isEqualToString:@"ipa"] || [extension isEqualToString:@"IPA"]) {
            return [UIImage imageNamed:@"app_file"];
        }else{
            return [UIImage imageNamed:@"known_file"];
        }
    }else{
        return [UIImage imageNamed:@"known_file"];
    }
}

// 时间
+ (NSString *)stringFromeTimeInterval:(NSTimeInterval)interval{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
}

#pragma mark - 私有
- (void)sort{
    if (self.list.count > 0) {
        // 排序key, 某个对象的属性名称，是否升序, YES-升序, NO-降序
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES];
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES];
        // 排序结果
        self.list = [[self.list sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]] mutableCopy];
    }
}

#pragma mark - lazy

- (NSMutableArray<MYFileRootClass *> *)list{
    if (!_list) {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

- (NSMutableArray<NSString *> *)filePaths{
    if (!_filePaths) {
        _filePaths = [[NSMutableArray alloc] init];
    }
    return _filePaths;
}

@end
