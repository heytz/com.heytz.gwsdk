//
// Created by 陈东东 on 16/3/31.
//

#import <Foundation/Foundation.h>
#import <XPGWifiSDK/XPGWifiSDK.h>
#import "HeytzApp.h"


@interface HeytzXPGWifiSDKDelegate : NSObject<XPGWifiSDKDelegate>{

}
-(void)setHeytzApp:(HeytzApp *)app;
@end