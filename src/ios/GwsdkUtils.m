//
//  gwsdkUtils.m
//  乐利水泵
//
//  Created by 陈东东 on 16/2/29.
//
//

#import <Foundation/Foundation.h>
#import "GwsdkUtils.h"

@implementation GwsdkUtils
/**
 *  GizWifiDevice 转换为dictionary
 *
 *  @param device <#device description#>
 *
 *  @return [did,macAddress,passcode,productkey]
 */
+ (NSDictionary *)gizDeviceToDictionary:(GizWifiDevice *)device {
    //设备的物理地址。如果是 VIRTUAL:SITE，则是虚拟设备
    NSString *mac = device.macAddress;
    //设备云端身份标识 DID
    NSString *did = device.did;
    //设备的小循环 IP 地址
    NSString *ipAddress = device.ipAddress;
    //设备的产品唯一标识符
    NSString *productKey = device.productKey;
    //设备名称
    NSString *productName = device.productName;
    //设备别名。在绑定的时候设置
    NSString *remark = device.remark;
    //当前设备是否是小循环设备
    NSNumber *isLAN = [NSNumber numberWithBool:device.isLAN];
    //云端判断设备是否注销
    NSNumber *isDisabled = [NSNumber numberWithBool:device.isDisabled];
    //设备是否跟用户绑定
    NSNumber *isBind = [NSNumber numberWithBool:[device isBind]];

    //当前设备是否已经建立连接
//    NSNumber *isConnected = [NSNumber numberWithBool:device.isConnected];
    //云端判断设备是否在线
//    NSNumber *isOnline = [NSNumber numberWithBool:device.isOnline];

    NSNumber *netStatus =[NSNumber numberWithLong:(long)(NSInteger *) device.netStatus]; //取消 isOnline//云端判断设备是否在线 isConnected//当前设备是否已经建立连接 接口
    NSString *alias = device.alias;
    NSNumber *isSubscribed = [NSNumber numberWithBool: device.isSubscribed];
    NSNumber *isProductDefined = [NSNumber numberWithBool: device.isProductDefined];

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            mac, @"macAddress",
            did, @"did",
            ipAddress, @"ipAddress",
            productKey, @"productKey",
            productName, @"productName",
            remark, @"remark",
            isDisabled, @"isDisabled",
//            isConnected, @"isConnected",
//            isOnline, @"isOnline",
            isLAN, @"isLAN",
            isBind, @"isBind",
            netStatus, @"netStatus",
            alias, @"alias",
            isSubscribed, @"isSubscribed",
            isProductDefined, @"isProductDefined",
                    nil];
    return d;
}

@end