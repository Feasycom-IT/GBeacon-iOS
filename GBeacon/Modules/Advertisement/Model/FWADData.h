#import <UIKit/UIKit.h>

@interface FWADData : NSObject

@property (nonatomic, assign) NSInteger iDField;
@property (nonatomic, strong) NSString * appkey;
@property (nonatomic, strong) NSString * cnimg;
@property (nonatomic, strong) NSString * cnurl1;
@property (nonatomic, strong) NSString * cnurl2;
@property (nonatomic, strong) NSString * cnurl3;
@property (nonatomic, strong) NSString * createTime;
@property (nonatomic, strong) NSString * enimg;
@property (nonatomic, strong) NSString * enurl1;
@property (nonatomic, strong) NSString * enurl2;
@property (nonatomic, strong) NSString * enurl3;
@property (nonatomic, strong) NSString * title;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end