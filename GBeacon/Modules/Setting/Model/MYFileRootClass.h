#import <UIKit/UIKit.h>

@interface MYFileRootClass : NSObject

@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, strong) NSString * fileName;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, strong) NSString * groupName;
@property (nonatomic, assign) NSInteger modificationTime;
@property (nonatomic, strong) NSString * owner;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * url;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end