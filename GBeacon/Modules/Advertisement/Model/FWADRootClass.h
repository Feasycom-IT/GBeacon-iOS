#import <UIKit/UIKit.h>
#import "FWADData.h"

@interface FWADRootClass : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) FWADData * data;
@property (nonatomic, strong) NSString * msg;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end