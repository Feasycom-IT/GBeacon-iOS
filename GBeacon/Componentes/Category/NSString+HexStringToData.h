//
//  NSString+HexStringToData.h
//  FeasyBeacon
//
//  Created by ericj on 2017/5/20.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HexStringToData)

+ (NSString *)convertHexStrToString:(NSString *)str;

-(NSData *)hexStringToData;

//负数转为16进制
+ (NSString *)turnStringToSignedHex:(int)number;

+ (NSString *)getURLScheme:(char)hexChar;

+ (NSString *)getHexByDecimal:(unsigned int)decimal;

+ (NSString *)getBinaryByHex:(NSString *)hex;

- (NSData *)convertHexStrToData:(NSString *)str;

+ (NSString *)addZero:(NSString *)byteString length:(NSInteger)length;

@end
