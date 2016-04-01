//
// Created by 陈东东 on 16/3/31.
//

#import <Foundation/Foundation.h>


@interface HeytzUtil : NSObject
+ (NSData *)stringToHex:(NSString *)str;

+ (NSDictionary *)deviceToDictionary:(XPGWifiDevice *)device uid:(NSString *)uid;

+ (void)logDevice:(NSString *)map device:(XPGWifiDevice *)device;
@end