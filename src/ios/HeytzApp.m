//
// Created by 陈东东 on 16/3/31.
//

#import <Cordova/CDVCommandDelegate.h>
#import <XPGWifiSDK/XPGWifiSDK.h>
#import "HeytzApp.h"


@implementation HeytzApp {

}
NSMutableDictionary *dictionary;
CDVInvokedUrlCommand *cdvInvokedUrlCommand;
NSString *_uid;
NSString *_token;
NSString *_currentDeviceMac;
XPGWifiDevice *_xpgWifiDevice;
BOOL  *_isDiscoverLock;
/**
 * 插入callback id
 */
- (void)setCallbackId:(NSString *)id callbackId:(NSString *)callbackId {
    if(!dictionary){
        dictionary= [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    }
    dictionary[callbackId] = id;
}

- (void)setCommandDelegate:(id <CDVCommandDelegate>)cd {
    self.commandDelegate = cd;
}

- (void)sendAddRemoveCallback:(CDVPluginResult *)pluginResult callbackId:(NSString *)callbackId {
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

/**
 * 获取callbcakId
 */
- (NSString *)getCallbackId:(NSString *)id {
    return dictionary[id];
}

/**
 * 设置uid
 */
- (void)setUid:(NSString *)uid {
    _uid = uid;
}

/**
 * 获取uid
 */
- (NSString *)getUid {
    return _uid;
}

/**
 * 设置Token
 */
- (void)setToken:(NSString *)token {
    _token = token;
}

/**
 * 获取Token
 */
- (NSString *)getToken {
    return _token;
}

/**
 * 设置CurrentDeviceMac
 */
- (void)setCurrentDeviceMac:(NSString *)currentDeviceMac {
    _currentDeviceMac = currentDeviceMac;
}

/**
 * 获取CurrentDeviceMac
 */
- (NSString *)getCurrentDeviceMac {
    return _currentDeviceMac;
}
/**
 * 设置xpgWifiDevice
 */
- (void)setCurrentXPGWifiDevice:(XPGWifiDevice *)xpgWifiDevice {
    _xpgWifiDevice = xpgWifiDevice;
}

/**
 * 获取xpgWifiDevice
 */
- (XPGWifiDevice *)getXPGWifiDevice {
    return _xpgWifiDevice;
}
/**
 * 设置_isDiscoverLock
 */
- (void)setIsDiscoverLock:(BOOL *)isDiscoverLock {
    _isDiscoverLock = isDiscoverLock;
}

/**
 * 获取_isDiscoverLock
 */
- (BOOL *)getIsDiscoverLock {
    return _isDiscoverLock;
}


@end