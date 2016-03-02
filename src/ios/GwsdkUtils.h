//
//  gwsdk.h
//
//  Created by 陈东东 on 16/2/29.
//
//


#import <Cordova/CDV.h>
#import <XPGWifiSDK/XPGWifiSDK.h>


@interface gwsdk : CDVPlugin<XPGWifiDeviceDelegate,XPGWifiSDKDelegate> {
    // Member variables go here.
    //当前操作的值
    XPGWifiDevice *selectedDevices;
}
@property (nonatomic, strong) NSString *gizwAppId;
/**
 *  cordova 配对设备上网
 *
 *  @param command [appid,"",ssid,pwd,timeout]
 */
-(void)setDeviceWifi:(CDVInvokedUrlCommand *)command;
/**
 *  cordova 配对上网，并且绑定这个设备
 *
 *  @param command ["appid","","ssid","pwd",uid,token,timeout,mode,softApssidPrefix,wifiGAgentType]
 */
-(void)setDeviceWifiBindDevice:(CDVInvokedUrlCommand *)command;
/**
 *  cordova 获取设备列表
 *
 *  @param command [appid,[productkey],uid,token]
 */
-(void)getDeviceList:(CDVInvokedUrlCommand *)command;
/**
 *  cordova 绑定设备
 *
 *  @param command ["appid","prodctekey","uid","token","did","passcode","remark"]
 */
-(void)deviceBinding:(CDVInvokedUrlCommand *)command;
/**
 *  cordova 控制设备
 *
 *  @param command ["appid",["prodctkeys"],"uid","token","mac","value"]
 */
-(void)deviceControl:(CDVInvokedUrlCommand *)command;
/**
 * cordova 获取ssid列表
 *
 *  @param command []
 */
-(void)getWifiSSIDList:(CDVInvokedUrlCommand *)command;
/**
 *  cordova 开始device的监听
 *
 *  @param command []
 */
-(void)startDeviceListener:(CDVInvokedUrlCommand *)command;
/**
 *  cordova 停止device的监听
 *
 *  @param command []
 */
-(void)endDeviceListener:(CDVInvokedUrlCommand *)command;
/**
 * cordova 连接设备
 *
 *  @param command ["uid","token","did"]
 */
-(void)connect:(CDVInvokedUrlCommand *)command;
/**
 * cordova 断开连接
 *
 *  @param command ["did"]
 */
-(void)disconnect:(CDVInvokedUrlCommand *)command;
/**
 * cordova 发送控制命令
 *
 *  @param command ["did","value"]
 */
-(void)write:(CDVInvokedUrlCommand *)command;
/**
 *  cordova 释放内存
 *
 *  @param command []
 */
-(void)dealloc:(CDVInvokedUrlCommand *)command;


@property (strong,nonatomic) CDVInvokedUrlCommand * commandHolder;
@property (strong, nonatomic) NSArray * _deviceList;
//@property (strong,nonatomic) NSArray *_arraySsidList;

@end
