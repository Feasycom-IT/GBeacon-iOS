//
//	MYFileRootClass.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "MYFileRootClass.h"

NSString *const kMYFileRootClassCreateTime = @"createTime";
NSString *const kMYFileRootClassFileName = @"fileName";
NSString *const kMYFileRootClassFileSize = @"fileSize";
NSString *const kMYFileRootClassGroupName = @"groupName";
NSString *const kMYFileRootClassModificationTime = @"modificationTime";
NSString *const kMYFileRootClassOwner = @"owner";
NSString *const kMYFileRootClassType = @"type";
NSString *const kMYFileRootClassUrl = @"url";

@interface MYFileRootClass ()
@end
@implementation MYFileRootClass




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kMYFileRootClassCreateTime] isKindOfClass:[NSNull class]]){
		self.createTime = [dictionary[kMYFileRootClassCreateTime] integerValue];
	}

	if(![dictionary[kMYFileRootClassFileName] isKindOfClass:[NSNull class]]){
		self.fileName = dictionary[kMYFileRootClassFileName];
	}	
	if(![dictionary[kMYFileRootClassFileSize] isKindOfClass:[NSNull class]]){
		self.fileSize = [dictionary[kMYFileRootClassFileSize] integerValue];
	}

	if(![dictionary[kMYFileRootClassGroupName] isKindOfClass:[NSNull class]]){
		self.groupName = dictionary[kMYFileRootClassGroupName];
	}	
	if(![dictionary[kMYFileRootClassModificationTime] isKindOfClass:[NSNull class]]){
		self.modificationTime = [dictionary[kMYFileRootClassModificationTime] integerValue];
	}

	if(![dictionary[kMYFileRootClassOwner] isKindOfClass:[NSNull class]]){
		self.owner = dictionary[kMYFileRootClassOwner];
	}	
	if(![dictionary[kMYFileRootClassType] isKindOfClass:[NSNull class]]){
		self.type = dictionary[kMYFileRootClassType];
	}	
	if(![dictionary[kMYFileRootClassUrl] isKindOfClass:[NSNull class]]){
		self.url = dictionary[kMYFileRootClassUrl];
	}	
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	dictionary[kMYFileRootClassCreateTime] = @(self.createTime);
	if(self.fileName != nil){
		dictionary[kMYFileRootClassFileName] = self.fileName;
	}
	dictionary[kMYFileRootClassFileSize] = @(self.fileSize);
	if(self.groupName != nil){
		dictionary[kMYFileRootClassGroupName] = self.groupName;
	}
	dictionary[kMYFileRootClassModificationTime] = @(self.modificationTime);
	if(self.owner != nil){
		dictionary[kMYFileRootClassOwner] = self.owner;
	}
	if(self.type != nil){
		dictionary[kMYFileRootClassType] = self.type;
	}
	if(self.url != nil){
		dictionary[kMYFileRootClassUrl] = self.url;
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
	[aCoder encodeObject:@(self.createTime) forKey:kMYFileRootClassCreateTime];	if(self.fileName != nil){
		[aCoder encodeObject:self.fileName forKey:kMYFileRootClassFileName];
	}
	[aCoder encodeObject:@(self.fileSize) forKey:kMYFileRootClassFileSize];	if(self.groupName != nil){
		[aCoder encodeObject:self.groupName forKey:kMYFileRootClassGroupName];
	}
	[aCoder encodeObject:@(self.modificationTime) forKey:kMYFileRootClassModificationTime];	if(self.owner != nil){
		[aCoder encodeObject:self.owner forKey:kMYFileRootClassOwner];
	}
	if(self.type != nil){
		[aCoder encodeObject:self.type forKey:kMYFileRootClassType];
	}
	if(self.url != nil){
		[aCoder encodeObject:self.url forKey:kMYFileRootClassUrl];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.createTime = [[aDecoder decodeObjectForKey:kMYFileRootClassCreateTime] integerValue];
	self.fileName = [aDecoder decodeObjectForKey:kMYFileRootClassFileName];
	self.fileSize = [[aDecoder decodeObjectForKey:kMYFileRootClassFileSize] integerValue];
	self.groupName = [aDecoder decodeObjectForKey:kMYFileRootClassGroupName];
	self.modificationTime = [[aDecoder decodeObjectForKey:kMYFileRootClassModificationTime] integerValue];
	self.owner = [aDecoder decodeObjectForKey:kMYFileRootClassOwner];
	self.type = [aDecoder decodeObjectForKey:kMYFileRootClassType];
	self.url = [aDecoder decodeObjectForKey:kMYFileRootClassUrl];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	MYFileRootClass *copy = [MYFileRootClass new];

	copy.createTime = self.createTime;
	copy.fileName = [self.fileName copy];
	copy.fileSize = self.fileSize;
	copy.groupName = [self.groupName copy];
	copy.modificationTime = self.modificationTime;
	copy.owner = [self.owner copy];
	copy.type = [self.type copy];
	copy.url = [self.url copy];

	return copy;
}
@end