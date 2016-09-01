//
//  gwsdkUtils.h
//  乐利水泵
//
//  Created by 陈东东 on 16/2/29.
//
//


#import <GizWifiSDK/GizWifiSDK.h>


@interface GwsdkUtils
+ (NSDictionary *)gizDeviceToDictionary:(GizWifiDevice *)device;
@end