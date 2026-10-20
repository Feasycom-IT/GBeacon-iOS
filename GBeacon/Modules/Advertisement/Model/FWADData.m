//
//	FWADData.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "FWADData.h"

NSString *const kFWADDataIDField = @"ID";
NSString *const kFWADDataAppkey = @"appkey";
NSString *const kFWADDataCnimg = @"cnimg";
NSString *const kFWADDataCnurl1 = @"cnurl1";
NSString *const kFWADDataCnurl2 = @"cnurl2";
NSString *const kFWADDataCnurl3 = @"cnurl3";
NSString *const kFWADDataCreateTime = @"createTime";
NSString *const kFWADDataEnimg = @"enimg";
NSString *const kFWADDataEnurl1 = @"enurl1";
NSString *const kFWADDataEnurl2 = @"enurl2";
NSString *const kFWADDataEnurl3 = @"enurl3";
NSString *const kFWADDataTitle = @"title";

@interface FWADData ()
@end
@implementation FWADData




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kFWADDataIDField] isKindOfClass:[NSNull class]]){
		self.iDField = [dictionary[kFWADDataIDField] integerValue];
	}

	if(![dictionary[kFWADDataAppkey] isKindOfClass:[NSNull class]]){
		self.appkey = dictionary[kFWADDataAppkey];
	}	
	if(![dictionary[kFWADDataCnimg] isKindOfClass:[NSNull class]]){
		self.cnimg = dictionary[kFWADDataCnimg];
	}	
	if(![dictionary[kFWADDataCnurl1] isKindOfClass:[NSNull class]]){
		self.cnurl1 = dictionary[kFWADDataCnurl1];
	}	
	if(![dictionary[kFWADDataCnurl2] isKindOfClass:[NSNull class]]){
		self.cnurl2 = dictionary[kFWADDataCnurl2];
	}	
	if(![dictionary[kFWADDataCnurl3] isKindOfClass:[NSNull class]]){
		self.cnurl3 = dictionary[kFWADDataCnurl3];
	}	
	if(![dictionary[kFWADDataCreateTime] isKindOfClass:[NSNull class]]){
		self.createTime = dictionary[kFWADDataCreateTime];
	}	
	if(![dictionary[kFWADDataEnimg] isKindOfClass:[NSNull class]]){
		self.enimg = dictionary[kFWADDataEnimg];
	}	
	if(![dictionary[kFWADDataEnurl1] isKindOfClass:[NSNull class]]){
		self.enurl1 = dictionary[kFWADDataEnurl1];
	}	
	if(![dictionary[kFWADDataEnurl2] isKindOfClass:[NSNull class]]){
		self.enurl2 = dictionary[kFWADDataEnurl2];
	}	
	if(![dictionary[kFWADDataEnurl3] isKindOfClass:[NSNull class]]){
		self.enurl3 = dictionary[kFWADDataEnurl3];
	}	
	if(![dictionary[kFWADDataTitle] isKindOfClass:[NSNull class]]){
		self.title = dictionary[kFWADDataTitle];
	}	
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	dictionary[kFWADDataIDField] = @(self.iDField);
	if(self.appkey != nil){
		dictionary[kFWADDataAppkey] = self.appkey;
	}
	if(self.cnimg != nil){
		dictionary[kFWADDataCnimg] = self.cnimg;
	}
	if(self.cnurl1 != nil){
		dictionary[kFWADDataCnurl1] = self.cnurl1;
	}
	if(self.cnurl2 != nil){
		dictionary[kFWADDataCnurl2] = self.cnurl2;
	}
	if(self.cnurl3 != nil){
		dictionary[kFWADDataCnurl3] = self.cnurl3;
	}
	if(self.createTime != nil){
		dictionary[kFWADDataCreateTime] = self.createTime;
	}
	if(self.enimg != nil){
		dictionary[kFWADDataEnimg] = self.enimg;
	}
	if(self.enurl1 != nil){
		dictionary[kFWADDataEnurl1] = self.enurl1;
	}
	if(self.enurl2 != nil){
		dictionary[kFWADDataEnurl2] = self.enurl2;
	}
	if(self.enurl3 != nil){
		dictionary[kFWADDataEnurl3] = self.enurl3;
	}
	if(self.title != nil){
		dictionary[kFWADDataTitle] = self.title;
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
	[aCoder encodeObject:@(self.iDField) forKey:kFWADDataIDField];	if(self.appkey != nil){
		[aCoder encodeObject:self.appkey forKey:kFWADDataAppkey];
	}
	if(self.cnimg != nil){
		[aCoder encodeObject:self.cnimg forKey:kFWADDataCnimg];
	}
	if(self.cnurl1 != nil){
		[aCoder encodeObject:self.cnurl1 forKey:kFWADDataCnurl1];
	}
	if(self.cnurl2 != nil){
		[aCoder encodeObject:self.cnurl2 forKey:kFWADDataCnurl2];
	}
	if(self.cnurl3 != nil){
		[aCoder encodeObject:self.cnurl3 forKey:kFWADDataCnurl3];
	}
	if(self.createTime != nil){
		[aCoder encodeObject:self.createTime forKey:kFWADDataCreateTime];
	}
	if(self.enimg != nil){
		[aCoder encodeObject:self.enimg forKey:kFWADDataEnimg];
	}
	if(self.enurl1 != nil){
		[aCoder encodeObject:self.enurl1 forKey:kFWADDataEnurl1];
	}
	if(self.enurl2 != nil){
		[aCoder encodeObject:self.enurl2 forKey:kFWADDataEnurl2];
	}
	if(self.enurl3 != nil){
		[aCoder encodeObject:self.enurl3 forKey:kFWADDataEnurl3];
	}
	if(self.title != nil){
		[aCoder encodeObject:self.title forKey:kFWADDataTitle];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.iDField = [[aDecoder decodeObjectForKey:kFWADDataIDField] integerValue];
	self.appkey = [aDecoder decodeObjectForKey:kFWADDataAppkey];
	self.cnimg = [aDecoder decodeObjectForKey:kFWADDataCnimg];
	self.cnurl1 = [aDecoder decodeObjectForKey:kFWADDataCnurl1];
	self.cnurl2 = [aDecoder decodeObjectForKey:kFWADDataCnurl2];
	self.cnurl3 = [aDecoder decodeObjectForKey:kFWADDataCnurl3];
	self.createTime = [aDecoder decodeObjectForKey:kFWADDataCreateTime];
	self.enimg = [aDecoder decodeObjectForKey:kFWADDataEnimg];
	self.enurl1 = [aDecoder decodeObjectForKey:kFWADDataEnurl1];
	self.enurl2 = [aDecoder decodeObjectForKey:kFWADDataEnurl2];
	self.enurl3 = [aDecoder decodeObjectForKey:kFWADDataEnurl3];
	self.title = [aDecoder decodeObjectForKey:kFWADDataTitle];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	FWADData *copy = [FWADData new];

	copy.iDField = self.iDField;
	copy.appkey = [self.appkey copy];
	copy.cnimg = [self.cnimg copy];
	copy.cnurl1 = [self.cnurl1 copy];
	copy.cnurl2 = [self.cnurl2 copy];
	copy.cnurl3 = [self.cnurl3 copy];
	copy.createTime = [self.createTime copy];
	copy.enimg = [self.enimg copy];
	copy.enurl1 = [self.enurl1 copy];
	copy.enurl2 = [self.enurl2 copy];
	copy.enurl3 = [self.enurl3 copy];
	copy.title = [self.title copy];

	return copy;
}
@end