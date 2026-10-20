//
//  MYFileModel.h
//  rytztool
//
//  Created by MingYueYu on 2019/8/1.
//  Copyright © 2019 MingYueYu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYFileRootClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface MYFileModel : NSObject
@property (nonatomic, strong) NSMutableArray<MYFileRootClass *> *list;
@property (nonatomic, strong) NSMutableArray<NSString *> *filePaths; // 必须按顺序

// 当前文件路径
- (NSString *)fieldPath;
// 获取文件列表，需要路径参数，为空 获取根目录
- (void)showFileList:(NSString *)path success:(void(^)(void))success faile:(void(^)(void))faile;
// 删除文件
- (void)delectData:(MYFileRootClass *)data Success:(void(^)(void))success faile:(void(^)(void))faile;
// 重命名文件
- (void)renameData:(MYFileRootClass *)data toName:(NSString *)name success:(void(^)(void))success faile:(void(^)(void))faile;
// 文件大小
+ (NSString *)stringFromeResourceSize:(NSInteger)resourceSize;
// 文件对应的自定义图标
+ (UIImage *)fileImageWithData:(MYFileRootClass *)data;
// 时间
+ (NSString *)stringFromeTimeInterval:(NSTimeInterval)interval;

@end

NS_ASSUME_NONNULL_END
