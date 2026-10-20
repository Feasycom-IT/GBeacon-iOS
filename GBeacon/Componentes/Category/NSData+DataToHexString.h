//
//  NSData+DataToHexString.h
//  FeasyBeacon
//
//  Created by ericj on 2017/5/20.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DataToHexString)

-(NSString *)dataToHexString;

-(NSString *)dataToHexStringInRange:(NSRange) range;

-(NSUInteger)littleEndianWithRange:(NSRange) range;

-(NSUInteger)littleEndian16:(NSUInteger) position;

-(NSUInteger)bigEndianWithRange:(NSRange) range;

+ (NSData*)dataForHexString:(NSString*)hexString;

@end
