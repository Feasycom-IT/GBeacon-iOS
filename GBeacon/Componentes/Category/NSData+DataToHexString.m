//
//  NSData+DataToHexString.m
//  FeasyBeacon
//
//  Created by ericj on 2017/5/20.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import "NSData+DataToHexString.h"

@implementation NSData (DataToHexString)
-(NSString *)dataToHexString{
    NSUInteger len = [self length];
    char *chars = (char *)[self bytes];
    NSMutableString *hexString = [[NSMutableString alloc]init];
    for (NSUInteger i=0; i<len; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx",chars[i]]];
    }
    return hexString;
}

-(NSString *)dataToHexStringInRange:(NSRange) range {
    
    if(range.location+range.length > [self length])
        return nil;
    return [[self subdataWithRange:range] dataToHexString];
}

-(NSUInteger)littleEndianWithRange:(NSRange) range {
    
    char *p = NULL;
    NSUInteger result = 0;
    int i;
    
    p = (char *)[self bytes];
    p += range.location;
    
    for(i=(int)(range.length-1); i >= 0; i--)
    {
        result = (result << 8) | (p[i] & 0xFF);
    }
    
    return result;
}

-(NSUInteger)littleEndian16:(NSUInteger) position {
    
    return [self littleEndianWithRange:NSMakeRange(position, 2)];
}

-(NSUInteger)bigEndianWithRange:(NSRange) range {
    
    char *p = NULL;
    NSUInteger result = 0;
    int i;
    
    p = (char *)[self bytes];
    p += range.location;
    
    for(i=0; i < range.length; i++)
    {
        result = (result << 8) | (p[i] & 0xFF);
    }
    
    return result;
}


+ (NSData*)dataForHexString:(NSString*)hexString
{
    if (hexString == nil) {
        return nil;
    }
    
    const char* ch = [[hexString lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* data = [NSMutableData data];
    while (*ch) {
        if (*ch == ' ') {
            continue;
        }
        char byte = 0;
        if ('0' <= *ch && *ch <= '9') {
            byte = *ch - '0';
        }
        else if ('a' <= *ch && *ch <= 'f') {
            byte = *ch - 'a' + 10;
        }
        else if ('A' <= *ch && *ch <= 'F') {
            byte = *ch - 'A' + 10;
        }
        ch++;
        byte = byte << 4;
        if (*ch) {
            if ('0' <= *ch && *ch <= '9') {
                byte += *ch - '0';
            } else if ('a' <= *ch && *ch <= 'f') {
                byte += *ch - 'a' + 10;
            }
            else if('A' <= *ch && *ch <= 'F')
            {
                byte += *ch - 'A' + 10;
            }
            ch++;
        }
        [data appendBytes:&byte length:1];
    }
    return data;
}



@end
