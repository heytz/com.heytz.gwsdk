//
// Created by 陈东东 on 16/3/31.
//

#import <Cordova/CDVPluginResult.h>
#import "HeytzXPGWifiSDKDelegate.h"
#import "GwsdkUtils.h"
#import "HeytzXPGWifiGAgentType.h"
#import "HeytzApp.h"


@implementation HeytzXPGWifiSDKDelegate {

}
HeytzApp *heytzApp;
BOOL _debug;

/**
 *  回调  设备配对状态的返回
 *
 *  @param wifiSDK
 *  @param device  <#device description#>
 *  @param result  <#result description#>
 */
- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didSetDeviceWifi:(XPGWifiDevice *)device result:(int)result {
    if (result == XPGWifiError_NONE) {

        [GwsdkUtils logDevice:@"didSetDeviceWifi" device:device];
        if ([HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI]) {
            //判断mac是否存在
            if ([device macAddress].length > 0 || device.macAddress.length > 0) {
                //判断did是否存在
                if ([heytzApp getCurrentDeviceMac] == nil && device.did.length > 0) {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils deviceToDictionary:device uid:nil]];
                    [heytzApp sendAddRemoveCallback:pluginResult callbackId:[heytzApp getCallbackId:[HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI]]];
                } else {
                    [heytzApp setCurrentDeviceMac:device.macAddress];
                }
            }
        }
        if ([HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI_AND_BIND]) {
            //判断mac是否存在
            if ([device macAddress].length > 0 || device.macAddress.length > 0) {
                //判断did是否存在
                if ([heytzApp getCurrentDeviceMac] == nil && device.did.length > 0) {
                    //[NSThread sleepForTimeInterval:10.00f];
                    [[XPGWifiSDK sharedInstance] bindDeviceWithUid:[heytzApp getUid] token:[heytzApp getToken] did:device.did passCode:nil remark:nil];

                } else {
                    [heytzApp setCurrentDeviceMac:device.macAddress];
                }
            }
        }
    } else if (result == XPGWifiError_CONFIGURE_TIMEOUT) {
        if (_debug)
            NSLog(@"======timeout=====");

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"timeout"];
        if ([HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI]) {
            [heytzApp sendAddRemoveCallback:pluginResult callbackId:[heytzApp getCallbackId:[HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI]]];
        }
        if ([HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI_AND_BIND]) {
            [heytzApp sendAddRemoveCallback:pluginResult callbackId:[heytzApp getCallbackId:[HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI_AND_BIND]]];
        }
    } else {
        if (_debug) {
            NSLog(@"======error code:===%d", result);
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
        if ([HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI]) {
            [heytzApp sendAddRemoveCallback:pluginResult callbackId:[heytzApp getCallbackId:[HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI]]];
        }
        if ([HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI_AND_BIND]) {
            [heytzApp sendAddRemoveCallback:pluginResult callbackId:[heytzApp getCallbackId:[HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI_AND_BIND]]];
        }
    }
}

/**
 *  回调 设备列表的返回
 *  配对成功以后会触发，获取设备列表会触发
 *  @param wifiSDK    <#wifiSDK description#>
 *  @param deviceList <#deviceList description#>
 *  @param result     <#result description#>
 */
//- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK
//     didDiscovered:
//             (NSArray *)deviceList
//            result:
//                    (int)result {
//    if (result == 0) {
//        for (XPGWifiDevice *device in deviceList) {
//            [GwsdkUtils logDevice:@"didDiscovered" device:device];
//        }
//    } else {
//        //error
//    }
//}
/**
 *  回调 设备列表的返回
 *  配对成功以后会触发，获取设备列表会触发
 *  @param wifiSDK    <#wifiSDK description#>
 *  @param deviceList <#deviceList description#>
 *  @param result     <#result description#>
 */
- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didDiscovered:(NSArray *)deviceList result:(int)result {
    if (result == 0) {
        if ([HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI]) {
            if (deviceList.count > 0) {
                for (XPGWifiDevice *device in deviceList) {
                    [GwsdkUtils logDevice:@"didDiscovered" device:device];
                    if ([[heytzApp getCurrentDeviceMac] isEqualToString:device.macAddress] && (device.did.length > 0)) {
                        [heytzApp setCurrentDeviceMac:nil];
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils deviceToDictionary:device uid:nil]];
                        [heytzApp sendAddRemoveCallback:pluginResult callbackId:[heytzApp getCallbackId:[HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI]]];
                    }
                }
            }

        }
        if ([HeytzXPGWifiGAgentType getOpervation:SET_DEVICE_WIFI_AND_BIND]) {
            if (deviceList.count > 0 && [heytzApp getCurrentDeviceMac] != nil) {
                for (XPGWifiDevice *device in deviceList) {
                    [GwsdkUtils logDevice:@"didDiscovered" device:device];
                    if ([[heytzApp getCurrentDeviceMac] isEqualToString:device.macAddress] && (device.did.length > 0)) {
                        [heytzApp setCurrentXPGWifiDevice:device];
                        if ([heytzApp getIsDiscoverLock] == true) {
                            [heytzApp setIsDiscoverLock:false];
                            [[XPGWifiSDK sharedInstance] bindDeviceWithUid:[heytzApp getUid] token:[heytzApp getToken] did:device.did passCode:nil remark:nil];
                        }
                    }
                }
            }

        }
//        if (startDeviceListCommandHolder != nil) {
//            if (deviceList.count > 0) {
//                _deviceList = deviceList;
//                NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
//                for (XPGWifiDevice *device in deviceList) {
//
//                    [jsonArray addObject:[GwsdkUtils deviceToDictionary:device uid:_uid]];
//                }
//                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:jsonArray];
//                [pluginResult setKeepCallbackAsBool:true];
//                [self.commandDelegate sendPluginResult:pluginResult callbackId:startDeviceListCommandHolder.callbackId];
//            } else {
//                //deviceList is zero;
//            }
//        }
//        switch (currentState) {
//            case GetDevcieListCode:
//                //                if ([self hasDone:deviceList]) {
//                if (deviceList.count > 0) {
//                    _deviceList = deviceList;
//                    NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
//                    for (XPGWifiDevice *device in deviceList) {
//                        //设备的物理地址。如果是 VIRTUAL:SITE，则是虚拟设备
//                        NSString *mac = device.macAddress;
//                        //设备云端身份标识 DID
//                        NSString *did = device.did;
//                        //用于控制设备的密钥
//                        NSString *passcode = device.passcode;
//                        //设备的小循环 IP 地址
//                        NSString *ipAddress = device.ipAddress;
//                        //设备的产品唯一标识符
//                        NSString *productKey = device.productKey;
//                        //设备名称
//                        NSString *productName = device.productName;
//                        //设备别名。在绑定的时候设置
//                        NSString *remark = device.remark;
//                        //当前设备是否已经建立连接
//                        NSNumber *isConnected = [NSNumber numberWithBool:device.isConnected];
//                        //当前设备是否是小循环设备
//                        NSNumber *isLAN = [NSNumber numberWithBool:device.isLAN];
//                        //云端判断设备是否在线
//                        NSNumber *isOnline = [NSNumber numberWithBool:device.isOnline];
//                        //云端判断设备是否注销
//                        NSNumber *isDisabled = [NSNumber numberWithBool:device.isDisabled];
//                        //设备是否跟用户绑定
//                        NSNumber *isBind = [NSNumber numberWithBool:[device isBind:_uid]];
//
//                        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                mac, @"macAddress",
//                                did, @"did",
//                                passcode, @"passcode",
//                                ipAddress, @"ipAddress",
//                                productKey, @"productKey",
//                                productName, @"productName",
//                                remark, @"remark",
//                                //device.ui, @"ui",
//                                isConnected, @"isConnected",
//                                isDisabled, @"isDisabled",
//                                isLAN, @"isLAN",
//                                isOnline, @"isOnline",
//                                isBind, @"isBind",
//                                        nil];
//                        [jsonArray addObject:d];
//                    }
//                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:jsonArray];
//                    [pluginResult setKeepCallbackAsBool:true];
//                    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
//                } else {
//                    //deviceList is zero;
//                }
//                break;
//            case ControlCode:
//                if (isDiscoverLock) {//如果锁定状态为true 那么就是控制命令已经发送成功
//                    if (deviceList.count > 0 && result == 0) {
//                        for (int i = 0; i < [deviceList count]; i++) {
//                            NSLog(@"=======%@", [deviceList[i] macAddress]);
//                            XPGWifiDevice *device = deviceList[i];
//                            //[[deviceList[i] macAddress]]
//
//
//                            if ([device.macAddress isEqualToString:[_mac uppercaseString]]) {
//                                isDiscoverLock = false;//设置锁定状态
//                                if (device.isConnected) {
//                                    [self cWrite:device objecValue:_controlObject];
//                                } else {
//                                    device.delegate = self;
//                                    [device login:_uid token:_token];
//
//                                }
//                            }
//                        }
//
//                        //        [self deviceLogin:deviceList];
//                    }
//                }
//                break;
//            default:
//                break;
//        }
    } else {
        //error
    }
}
/**
 *  回调 获取设备绑定的状态
 *
 *  @param wifiSDK      <#wifiSDK description#>
 *  @param did          <#did description#>
 *  @param error        <#error description#>
 *  @param errorMessage <#errorMessage description#>
 */
- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didBindDevice:(NSString *)did error:(NSNumber *)error errorMessage:(NSString *)errorMessage {

    if ([error intValue] == XPGWifiError_NONE) {
        CDVPluginResult *pluginResult;
        //绑定成功
        NSLog(@"\n =========binding success========\n %@", did);
//        if (selectedDevices) {
//            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils deviceToDictionary:selectedDevices uid:_uid]];
//        } else {
//            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:did];
//        }
//        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
        //清空缓存
//        selectedDevices = nil;
//        _currentPairDeviceMacAddress = nil;
    } else {
        //绑定失败
        NSLog(@"\n =========binding error========\n error:%@ \n errorMessage:%@ \n", error, errorMessage);
//        if (attempts > 0) {
//            isDiscoverLock = true;
//            --attempts;
//        } else {
//            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
//            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
//            //清空缓存
//            selectedDevices = nil;
//            _currentPairDeviceMacAddress = nil;
//        }
    }


}

- (void)setHeytzApp:(HeytzApp *)app {
    heytzApp = app;
}
@end