//
//	FWADRootClass.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "FWADRootClass.h"

NSString *const kFWADRootClassCode = @"code";
NSString *const kFWADRootClassData = @"data";
NSString *const kFWADRootClassMsg = @"msg";

@interface FWADRootClass ()
@end
@implementation FWADRootClass




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kFWADRootClassCode] isKindOfClass:[NSNull class]]){
		self.code = [dictionary[kFWADRootClassCode] integerValue];
	}

	if(![dictionary[kFWADRootClassData] isKindOfClass:[NSNull class]]){
		self.data = [[FWADData alloc] initWithDictionary:dictionary[kFWADRootClassData]];
	}

	if(![dictionary[kFWADRootClassMsg] isKindOfClass:[NSNull class]]){
		self.msg = dictionary[kFWADRootClassMsg];
	}	
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	dictionary[kFWADRootClassCode] = @(self.code);
	if(self.data != nil){
		dictionary[kFWADRootClassData] = [self.data toDictionary];
	}
	if(self.msg != nil){
		dictionary[kFWADRootClassMsg] = self.msg;
	}
	return dictionary;

}

/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:@(self.code) forKey:kFWADRootClassCode];	if(self.data != nil){
		[aCoder encodeObject:self.data forKey:kFWADRootClassData];
	}
	if(self.msg != nil){
		[aCoder encodeObject:self.msg forKey:kFWADRootClassMsg];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.code = [[aDecoder decodeObjectForKey:kFWADRootClassCode] integerValue];
	self.data = [aDecoder decodeObjectForKey:kFWADRootClassData];
	self.msg = [aDecoder decodeObjectForKey:kFWADRootClassMsg];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	FWADRootClass *copy = [FWADRootClass new];

	copy.code = self.code;
	copy.data = [self.data copy];
	copy.msg = [self.msg copy];

	return copy;
}
@end