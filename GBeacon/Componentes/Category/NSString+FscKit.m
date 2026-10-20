//
//  NSString+FscKit.m
//  BLEAssistant
//
//  Created by ericj on 2018/1/13.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "NSString+FscKit.h"

@implementation NSString (FscKit)

//十进制转十六进制
+ (NSString *)stringToHexString:(uint32_t)number {
    NSString *hexString;
    switch (number) {
        case 10:
            hexString = @"A";
            break;
        case 11:
            hexString = @"B";
            break;
        case 12:
            hexString = @"C";
            break;
        case 13:
            hexString = @"D";
            break;
        case 14:
            hexString = @"E";
            break;
        case 15:
            hexString = @"F";
            break;
        default:
            hexString = [NSString stringWithFormat:@"%d",number];
            break;
    }
    return hexString;
}

// 十六进制数据转字符串
+ (NSString *)fan_dataToHexString:(NSData *)data{
    Byte *bytehex =(Byte *) data.bytes;
    NSMutableString *hexString=[[NSMutableString alloc]init];
    for (int i=0; i<data.length; i++) {
        Byte b=bytehex[i];
        [hexString appendFormat:@"%02x",b];
    }
    return hexString;
}
// 转换地址头部
+ (NSString *)transformAddressHandString:(NSString *)string {
    if ([string hasPrefix:@"https://"]) {
        if ([string hasPrefix:@"https://www."]) {
            return @"01";
        }
        return @"03";
    } else if ([string hasPrefix:@"http://"]) {
        if ([string hasPrefix:@"http://www."]) {
            return @"00";
        }
        return @"02";
    }
    return nil;
}
// 地址解析
+ (NSString *)getAddress:(NSString *)string {
    NSString *handStr = [self getAddressHandString:string];
    NSString *bodyStr = [self getAddressFromHexString:string];
    NSString *tailStr = [self tailStringToHexString:string];
    if (!tailStr) {
        return [NSString stringWithFormat:@"%@%@",handStr,bodyStr];
    }
    return [NSString stringWithFormat:@"%@%@%@",handStr,bodyStr,tailStr];
}
// 反转地址头部
+ (NSString *)getAddressHandString:(NSString *)string {
    if ([string hasPrefix:@"03"]) {
        return @"https://";
    } else if ([string hasPrefix:@"02"]) {
        return @"http://";
    } else if ([string hasPrefix:@"01"]) {
        return @"https://www.";
    } else if ([string hasPrefix:@"00"]) {
        return @"http://www.";
    }
    return nil;
}
// 后缀->16进制
+ (NSString *)tailStringToHexString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return nil;
    }
    NSString *lastStr = [string substringWithRange:NSMakeRange(string.length-2, 2)];
    if ([lastStr isEqualToString:@"00"]) {
        return @".com/";
    } else if ([lastStr isEqualToString:@"01"]) {
        return @".org/";
    } else if ([lastStr isEqualToString:@"02"]) {
        return @".edu/";
    } else if ([lastStr isEqualToString:@"03"]) {
        return @".net/";
    } else if ([lastStr isEqualToString:@"04"]) {
        return @".info/";
    } else if ([lastStr isEqualToString:@"05"]) {
        return @".biz/";
    } else if ([lastStr isEqualToString:@"06"]) {
        return @".gov/";
    } else if ([lastStr isEqualToString:@"07"]) {
        return @".com";
    } else if ([lastStr isEqualToString:@"08"]) {
        return @".org";
    } else if ([lastStr isEqualToString:@"09"]) {
        return @".edu";
    } else if ([lastStr isEqualToString:@"0A"]) {
        return @".net";
    } else if ([lastStr isEqualToString:@"0B"]) {
        return @".info";
    } else if ([lastStr isEqualToString:@"0C"]) {
        return @".biz";
    } else if ([lastStr isEqualToString:@"0D"]) {
        return @".gov";
    } else {
        return nil;
    }
}
// 16进制字符串->网址
+ (NSString *)getAddressFromHexString:(NSString *)string {
    NSString *str = @"";
    NSString *newStr = @"";
    for (int i = 0; i < string.length/2; i++) {
        str = [string substringWithRange:NSMakeRange(i*2, 2)];
        str = [NSString stringWithFormat:@"%ld",strtoul([str UTF8String],0,16)];
        str = [NSString stringWithFormat:@"%c",[str intValue]];
        newStr = [newStr stringByAppendingString:str];
    }
    return newStr;
}
// 网址->16进制字符串
+ (NSString *)HexConvertToASCII:(NSString *)hexString{
    NSString *str = @"";
    NSString *numStr = @"";
    NSString *hexStr = @"";
    NSArray *array = [hexString componentsSeparatedByString:@"//"];
    if (array.count<2) {
        return nil;
    }
    if ([array[1] hasPrefix:@"www"]) {
        hexString = [array[1] substringFromIndex:4];
    } else {
        hexString = array[1];
    }
    NSArray *newArray = [hexString componentsSeparatedByString:@"."];
    if ([self getAddressTailString:[NSString stringWithFormat:@".%@",newArray.lastObject]]) {
        hexString = [hexString substringToIndex:hexString.length-([newArray.lastObject length]+1)];
    }
    for (int i = 0; i < hexString.length; i++) {
        str = [hexString substringWithRange:NSMakeRange(i, 1)];
        unichar theChar = [str characterAtIndex:0];
        numStr = [NSString stringWithFormat:@"%d",theChar];
        numStr = [self getHexByDecimal:(unsigned int)[numStr integerValue]];
        hexStr = [hexStr stringByAppendingString:numStr];
    }
    if (hexStr.length%2) {
        hexStr = [hexStr substringToIndex:hexStr.length-1];
        return hexStr;
    }
    return hexStr;
}
/**
 十进制转换十六进制
 */
+ (NSString *)getHexByDecimal:(unsigned int)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", (long)number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}
//将uint32_t转换成十六进制的字符串
+ (NSString *)stringWithHexNumber:(uint32_t)hexNumber {
    char hexChar[20];
    sprintf(hexChar, "%x", (int)hexNumber);
    NSString *hexString = [NSString stringWithCString:hexChar encoding:NSUTF8StringEncoding];
    return hexString;
}

// 转换地址尾部
+ (NSString *)getAddressTailString:(NSString *)string {
    if ([string hasSuffix:@".com/"]) {
        return @"00";
    } else if ([string hasSuffix:@".org/"]) {
        return @"01";
    } else if ([string hasSuffix:@".edu/"]) {
        return @"02";
    } else if ([string hasSuffix:@".net/"]) {
        return @"03";
    } else if ([string hasSuffix:@".info/"]) {
        return @"04";
    } else if ([string hasSuffix:@".biz/"]) {
        return @"05";
    } else if ([string hasSuffix:@".gov/"]) {
        return @"06";
    } else if ([string hasSuffix:@".com"]) {
        return @"07";
    } else if ([string hasSuffix:@".org"]) {
        return @"08";
    } else if ([string hasSuffix:@".edu"]) {
        return @"09";
    } else if ([string hasSuffix:@".net"]) {
        return @"0A";
    } else if ([string hasSuffix:@".info"]) {
        return @"0B";
    } else if ([string hasSuffix:@".biz"]) {
        return @"0C";
    } else if ([string hasSuffix:@".gov"]) {
        return @"0D";
    }
    return @"";
}
// 模块型号
+ (NSString *)modelForFirmwareValue:(int)value {
    NSString *modules[] = {
        @"",
        @"BT401",   // 1
        @"BT405",   // 2
        @"BT426N",  // 3
        @"BT501",   // 4
        @"BT502",   // 5
        @"BT522",   // 6
        @"BT616",   // 7
        @"BT625",   // 8
        @"BT626",   // 9
        @"BT803",   // 10
        @"BT813D",  // 11
        @"BT816S",  // 12
        @"BT821",   // 13
        @"BT822",   // 14
        @"BT826",   // 15
        @"BT826N",  // 16
        @"BT836",   // 17
        @"BT836N",  // 18
        @"BT906",   // 19
        @"BT909",   // 20
        @"BP102",   // 21
        @"BT816S3", // 22
        @"BT926",   // 23
        @"BT901",   // 24
        @"BP109",   // 25
        @"BP103",   // 26
        @"BP104",   // 27
        @"BP201",   // 28
        @"BP106",   // 29
        @"BP101",   // 30
        @"BP671",   // 31
        @"BT826H",  // 32
        @"BT826NH", // 33
        @"BT826E",  // 34
        @"BT826EH", // 35
        @"BT836B",  // 36
        @"BT826B",  // 37
        @"BT736",   // 38
        @"BT926B",  // 39
        @"BT966"    // 40
    };
    
    if (0 > value || (sizeof(modules) / sizeof(id)) <= value) {
        return @"";
    }
    
    return modules[value];
}

+ (NSString *)modelForBroadcastValue:(int)value {
    NSString *modules[] = {
        @"",
        @"BT401",   // 1
        @"BT405",   // 2
        @"BT426N",  // 3
        @"BT501",   // 4
        @"BT502",   // 5
        @"BT522",   // 6
        @"BT616",   // 7
        @"BT625",   // 8
        @"BT626",   // 9
        @"BT803",   // 10
        @"BT813D",  // 11
        @"BT816S",  // 12
        @"BT821",   // 13
        @"BT822",   // 14
        @"BT826",   // 15
        @"BT826N",  // 16
        @"BT836",   // 17
        @"BT836N",  // 18
        @"BT906",   // 19
        @"BT909",   // 20
        @"BP102",   // 21
        @"BT816S3", // 22
        @"BT926",   // 23
        @"BT901",   // 24
        @"BP109",   // 25
        @"BP103",   // 26
        @"BP104",   // 27
        @"BP201",   // 28
        @"BP106",   // 29
        @"BP101",   // 30
        @"BP671",   // 31
        @"BT826H",  // 32
        @"BT826NH", // 33
        @"BP105",   // 34
        @"BP107",   // 35
        @"BP120",   // 36
        @"BT681",   // 37
        @"BT686",   // 38
        @"BP108",   // 39
        @"BP108N",  // 40
        @"BP103B",  // 41
        @"BT671B",  // 42
        @"BP104B",  // 43
        @"BP110",   // 44
        @"BP102B",  // 45
        @"BP104D"   // 46
    };
    
    if (0 > value || (sizeof(modules) / sizeof(id)) <= value) {
        return @"";
    }
    
    return modules[value];
}

//获取bundle版本
+ (NSString *)getLocalAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
//时间戳
+ (NSString *)getNowTimeTimestamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"HH:mm:ss.SSS"]; // ---------hh与HH的区别:分别表示12小时制,24小时制
    //设置时区
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *datenow = [NSDate date];//现在时间
    NSString *timeSp = [formatter stringFromDate:datenow];
    return timeSp;
}

- (NSInteger)integerFromReverseString {
    if (4 != self.length) {
        return 0;
    }
    NSRange range = { 2, 2 };
    NSString *highString = [self substringWithRange:range];
    
    range.location = 0;
    
    NSString *lowString = [self substringWithRange:range];
    NSString *number = [highString stringByAppendingString:lowString];
    
    return strtoul([number UTF8String], NULL, 16);
}

- (NSString *)decryptVersion {
    if (4 != self.length) {
        return nil;
    }
    NSInteger value = (NSInteger)strtoul([self UTF8String], NULL, 16);
    
    NSLog(@"value = %d", (int)value);
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    while (value > 0) {
        int tmp = value % 10;
        NSString *v = [[NSString alloc] initWithFormat:@"%d", tmp];
        
        NSLog(@"v = %@", v);
        
        [result insertString:v atIndex:0];
        
        value /= 10;
        
        if (value > 0) {
            [result insertString:@"." atIndex:0];
        }
    }
    
    return result;
}

- (NSString *)moduleFromHexString {
    const NSInteger value = [self integerFromReverseString];
    
    return [NSString modelForFirmwareValue:(int)value];
}

- (BOOL)isDigits {
    const NSInteger length = self.length;
    NSInteger startIndex = 0;
    
    if ([self hasPrefix:@"-"]) {
        startIndex = 1;
    }
    
    for (NSInteger i = startIndex; i < length; ++ i) {
        const unichar c = [self characterAtIndex:i];
        
        if (!isdigit(c)) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)isUnsignedDigits {
    const NSInteger length = self.length;
    for (NSInteger i = 0; i < length; i++) {
        const unichar c = [self characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isHexDigits {
    const NSInteger length = self.length;
    
    for (NSInteger i = 0; i < length; ++ i) {
        const unichar c = [self characterAtIndex:i];
        
        if (!isxdigit(c)) {
            return NO;
        }
    }
    
    return YES;
}

@end


