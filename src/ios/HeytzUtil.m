//
// Created by 陈东东 on 16/3/31.
//

#import <XPGWifiSDK/XPGWifiSDK.h>
#import "HeytzUtil.h"


@implementation HeytzUtil {

}
/**
 *  方法 string 转换为Data
 *
 *  @param str <#str description#>
 *
 *  @return <#return value description#>
 */
+(NSData *)stringToHex: (NSString *) str{
    //-------------------

    // NSString --> hex
    const char *buf = [str UTF8String];
    NSMutableData *data = [NSMutableData data];
    if (buf)
    {
        uint32_t len = strlen(buf);

        char singleNumberString[3] = {'\0', '\0', '\0'};
        uint32_t singleNumber = 0;
        for(uint32_t i = 0 ; i < len; i+=2)
        {
            if ( ((i+1) < len) && isxdigit(buf[i]) && (isxdigit(buf[i+1])) )
            {
                singleNumberString[0] = buf[i];
                singleNumberString[1] = buf[i + 1];
                sscanf(singleNumberString, "%x", &singleNumber);
                uint8_t tmp = (uint8_t)(singleNumber & 0x000000FF);
                [data appendBytes:(void *)(&tmp)length:1];
            }
            else
            {
                break;
            }
        }
    }
    //-------------------
    return data;
}
/**
 *  XPGWifiDevice 转换为dictionary
 *
 *  @param device <#device description#>
 *
 *  @return [did,macAddress,passcode,productkey]
 */
+ (NSDictionary *)deviceToDictionary:(XPGWifiDevice *)device uid:(NSString *)uid{
    //设备的物理地址。如果是 VIRTUAL:SITE，则是虚拟设备
    NSString * mac = device.macAddress;
    //设备云端身份标识 DID
    NSString *did=device.did;
    //用于控制设备的密钥
    NSString *passcode=device.passcode;
    //设备的小循环 IP 地址
    NSString *ipAddress=device.ipAddress;
    //设备的产品唯一标识符
    NSString *productKey=device.productKey;
    //设备名称
    NSString *productName=device.productName;
    //设备别名。在绑定的时候设置
    NSString *remark=device.remark;
    //当前设备是否已经建立连接
    NSNumber *isConnected=[NSNumber numberWithBool:device.isConnected];
    //当前设备是否是小循环设备
    NSNumber *isLAN = [NSNumber numberWithBool:device.isLAN];
    //云端判断设备是否在线
    NSNumber *isOnline = [NSNumber numberWithBool:device.isOnline];
    //云端判断设备是否注销
    NSNumber *isDisabled=[NSNumber numberWithBool:device.isDisabled];
    //设备是否跟用户绑定
    NSNumber *isBind=[NSNumber numberWithBool:[device isBind: uid]];

    NSMutableDictionary * d = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            mac, @"macAddress",
            did, @"did",
            passcode, @"passcode",
            ipAddress, @"ipAddress",
            productKey, @"productKey",
            productName, @"productName",
            remark, @"remark",
            //device.ui, @"ui",
            isConnected, @"isConnected",
            isDisabled, @"isDisabled",
            isLAN, @"isLAN",
            isOnline, @"isOnline",
            isBind, @"isBind",
                    nil];
    return d;
}
/**
 *  方法 打印device的log
 *
 *  @param map    tag
 *  @param device 设备device对象
 */
+ (void)logDevice:(NSString *)map device:(XPGWifiDevice *)device{
    //设备的物理地址。如果是 VIRTUAL:SITE，则是虚拟设备
    NSString * mac = device.macAddress;
    //设备云端身份标识 DID
    NSString *did=device.did;
    //用于控制设备的密钥
    NSString *passcode=device.passcode;
    //设备的小循环 IP 地址
    NSString *ipAddress=device.ipAddress;
    //设备的产品唯一标识符
    NSString *productKey=device.productKey;
    //设备名称
    NSString *productName=device.productName;
    //设备别名。在绑定的时候设置
    NSString *remark=device.remark;
    //当前设备是否已经建立连接
    NSNumber *isConnected=[NSNumber numberWithBool:device.isConnected];
    //当前设备是否是小循环设备
    NSNumber *isLAN = [NSNumber numberWithBool:device.isLAN];
    //云端判断设备是否在线
    NSNumber *isOnline = [NSNumber numberWithBool:device.isOnline];
    //云端判断设备是否注销
    NSNumber *isDisabled=[NSNumber numberWithBool:device.isDisabled];
    //设备是否跟用户绑定
//    NSNumber *isBind=[NSNumber numberWithBool:[device isBind: _uid]];
    NSLog(@"\n======%@=====\n currentMac:%@ \n \ndid:%@ \npasscode:%@\nipAddress:%@\nproductKey:%@\nproductName:%@\nremark:%@\nisConnected:%@\nisLAN:%@\nisOnline:%@\nisDisabled:%@\n",
            map,
            mac,
            did,
            passcode,
            ipAddress,
            productKey,
            productName,
            remark,
            isConnected,
            isLAN,
            isOnline,
            isDisabled
    );

}

@end