//
//  gwsdk.h
//  乐利水泵
//
//  Created by 陈东东 on 16/2/29.
//
//


#import <Cordova/CDV.h>
#import <XPGWifiSDK/XPGWifiSDK.h>

@interface gwsdk : CDVPlugin<XPGWifiDeviceDelegate,XPGWifiSDKDelegate> {
    // Member variables go here.
}

-(void)setDeviceWifi:(CDVInvokedUrlCommand *)command;
-(void)getDeviceList:(CDVInvokedUrlCommand *)command;
-(void)setDeviceWifiBindDevice:(CDVInvokedUrlCommand *)command;
-(void)deviceControl:(CDVInvokedUrlCommand *)command;
-(void)dealloc:(CDVInvokedUrlCommand *)command;
-(void)deviceBinding:(CDVInvokedUrlCommand *)command;

@property (strong,nonatomic) CDVInvokedUrlCommand * commandHolder;
@property (strong, nonatomic) NSArray * _deviceList;
//@property (strong,nonatomic) NSArray *_arraySsidList;

@end
