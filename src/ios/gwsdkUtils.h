//
//  gwsdkUtils.h
//
//  Created by 陈东东 on 16/2/29.
//
//


#import <XPGWifiSDK/XPGWifiSDK.h>

@interface gwsdkUtils

/**
 *  方法 string 转换为Data
 *
 *  @param str <#str description#>
 *
 *  @return <#return value description#>
 */
+(NSData *)stringToHex: (NSString *) str;
/**
 *  XPGWifiDevice 转换为dictionary
 *
 *  @param device <#device description#>
 *
 *  @return [did,macAddress,passcode,productkey]
 */
-(NSDictionary *) deviceToDictionary:(XPGWifiDevice *)device;
/**
 *  方法 打印device的log
 *
 *  @param map    tag
 *  @param device 设备device对象
 */
-(void) logDevice:(NSString *)map device:(XPGWifiDevice *)device;
@end