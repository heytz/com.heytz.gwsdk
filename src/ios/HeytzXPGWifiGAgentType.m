//
// Created by 陈东东 on 16/3/31.
//

#import "HeytzXPGWifiGAgentType.h"



NSString const *OpervationStrings[] = {
        @"setDeviceWifi",
        @"setDeviceWifiBindDevice"
};
@implementation HeytzXPGWifiGAgentType {

}
+(NSString *)getOpervation:(Operation)o {
    return (NSString *) OpervationStrings[o];
}
@end