//
//  NSString+Hexadecimal.m
//  FeasycomLE
//
//  Created by LIDONG on 6/13/15.
//  Copyright (c) 2015 LIDONG. All rights reserved.
//

#import "NSString+Hexadecimal.h"

@implementation NSString (Hexadecimal)

- (int)hexadecimalIntValue {
    const UInt8 *bytes = (const UInt8 *)[self UTF8String];
    const int len = (int)strlen((const char *)bytes);
    
    if (len > sizeof(int) * 2) {
        return INT_MAX;
    }
    int weight = 1;
    int value = 0;
    
    for (int i = len - 1; i >= 0; -- i) {
        unsigned int v = bytes[i];
        
        if (0x30 <= v && v <= 0x39) {
            v &= 0x0F;
        } else if ((0x41 <= v && v <= 0x46) || (0x61 <= v && v <= 0x61)) {
            v = (v & 0x0F) + 9;
        } else {
            v = 0;
        }
        
        value += (int)v * weight;
        weight *= 16;
    }
    return value;
}

static UInt8 hex(UInt8 v) {
    if (0x30 <= v && v <= 0x39) {
        v &= 0x0F;
    } else if ((0x41 <= v && v <= 0x46) || (0x61 <= v && v <= 0x61)) {
        v = (v & 0x0F) + 9;
    } else {
        v = 0;
    }
    return v;
}

- (NSData *)hexadecimalData {
    const UInt8 *bytes = (const UInt8 *)[self UTF8String];
    int len = (int)strlen((const char *)bytes);
    UInt8 *cachedBytes;
    int start = 0;
    
    if (len & 1) {
        len ++;
        start ++;
        cachedBytes = malloc(len);
        memcpy(cachedBytes + 1, bytes, len - 1);
        cachedBytes[0] = 0;
    } else {
        cachedBytes = malloc(len);
        memcpy(cachedBytes, bytes, len);
    }
    const NSUInteger dataLen = (len >> 1);
    
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:dataLen];
    
    for (int i = 0; i < len; i += 2) {
        UInt8 high = hex(cachedBytes[i]);
        UInt8 low = hex(cachedBytes[i + 1]);
        const UInt8 v = high * 16 + low;
        
        [data appendBytes:&v length:1];
    }
    
    return data;
}

@end
