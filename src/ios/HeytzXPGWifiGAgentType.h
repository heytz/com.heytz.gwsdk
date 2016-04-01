//
// Created by 陈东东 on 16/3/31.
//

#import <Foundation/Foundation.h>


@interface HeytzXPGWifiGAgentType : NSObject

typedef NS_ENUM(NSInteger ,Operation){
    SET_DEVICE_WIFI=0,
    SET_DEVICE_WIFI_AND_BIND=1,
};
+(NSString *)getOpervation:(Operation)o;
@end