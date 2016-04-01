//
// Created by 陈东东 on 16/3/31.
//

#import <Foundation/Foundation.h>

@protocol CDVCommandDelegate;


@interface HeytzApp : NSObject
@property(nonatomic, weak) id <CDVCommandDelegate> commandDelegate;

- (void)setCallbackId:(NSString *)id callbackId:(NSString *)callbackId;

- (NSString *)getCallbackId:(NSString *)id;

- (void)setUid:(NSString *)uid;

- (NSString *)getUid;

- (void)setToken:(NSString *)token;

- (NSString *)getToken;

//- (void)setCommandDelegate:(CDVInvokedUrlCommand *)cd;

- (void)sendAddRemoveCallback:(CDVPluginResult *)pluginResult callbackId:(NSString *)callbackId;

- (void)setCurrentDeviceMac:(NSString *)currentDeviceMac;

- (NSString *)getCurrentDeviceMac;

- (void)setCurrentXPGWifiDevice:(XPGWifiDevice *)xpgWifiDevice;

- (XPGWifiDevice *)getXPGWifiDevice;

- (void)setIsDiscoverLock:(BOOL *)isDiscoverLock;

- (BOOL *)getIsDiscoverLock;
@end