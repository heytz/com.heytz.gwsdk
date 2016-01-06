/********* gwsdkwrapper.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <XPGWifiSDK/XPGWifiSDK.h>

@interface gwsdk : CDVPlugin<XPGWifiDeviceDelegate,XPGWifiSDKDelegate> {
    
    // Member variables go here.
    NSString * _appId;
    XPGWifiSDK * _shareInstance;
}

- (void)setDeviceWifi:(CDVInvokedUrlCommand *)command;
-(void)dealloc:(CDVInvokedUrlCommand *)command;

@property (strong,nonatomic) CDVInvokedUrlCommand * commandHolder;

@end

@implementation gwsdk

@synthesize commandHolder;
NSString * productKey;
NSString    *_currentPairDeviceMacAddress;

-(void)pluginInitialize{
    
}
-(void)initSdkWithAppId:(CDVInvokedUrlCommand *) command{
    if(_shareInstance == nil){
        _appId = command.arguments[2];
        [XPGWifiSDK startWithAppID:_appId];
        _shareInstance = [XPGWifiSDK sharedInstance];
        _shareInstance.delegate = self;
        
    }
}
/*
 *
 */
-(void)setDeviceWifi:(CDVInvokedUrlCommand *)command
{
    
    [self initSdkWithAppId:command];
    self.commandHolder = command;
    
    
    /**
     配置设备连接路由的方法
     @param ssid 需要配置到路由的SSID名
     @param key 需要配置到路由的密码
     @param mode 配置方式
     @see XPGConfigureMode
     @param softAPSSIDPrefix SoftAPMode模式下SoftAP的SSID前缀或全名（XPGWifiSDK以此判断手机当前是否连上了SoftAP，AirLink配置时该参数无意义，传nil即可）
     @param timeout 配置的超时时间 SDK默认执行的最小超时时间为30秒
     @param types 配置的wifi模组类型列表，存放NSNumber对象，SDK默认同时发送庆科和汉枫模组配置包；SoftAPMode模式下该参数无意义。types为nil，SDK按照默认处理。如果只想配置庆科模组，types中请加入@XPGWifiGAgentTypeMXCHIP类；如果只想配置汉枫模组，types中请加入@XPGWifiGAgentTypeHF；如果希望多种模组配置包同时传，可以把对应类型都加入到types中。XPGWifiGAgentType枚举类型定义SDK支持的所有模组类型。
     @see 对应的回调接口：[XPGWifiSDKDelegate XPGWifiSDK:didSetDeviceWifi:result:]
     */
    // 旧接口  抛弃
    //    [[XPGWifiSDK sharedInstance] setDeviceWifi:command.arguments[0]
    //                                           key:command.arguments[1]
    //                                          mode:XPGWifiSDKAirLinkMode
    //                              softAPSSIDPrefix:nil
    //                                       timeout:180];
    //新接口 11.24
    _currentPairDeviceMacAddress=nil;
    [[XPGWifiSDK  sharedInstance] setDeviceWifi:command.arguments[0] key:command.arguments[1] mode:XPGWifiSDKAirLinkMode softAPSSIDPrefix:nil timeout:180 wifiGAgentType:nil];
}


- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didSetDeviceWifi:(XPGWifiDevice *)device result:(int)result{
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                       device.did, @"did",
                       device.ipAddress, @"ipAddress",
                       device.macAddress, @"macAddress",
                       device.passcode, @"passcode",
                       device.productKey, @"productKey",
                       device.productName, @"productName",
                       device.remark, @"remark",
                       device.isConnected, @"isConnected",
                       device.isDisabled, @"isDisabled",
                       device.isLAN, @"isLAN",
                       device.isOnline, @"isOnline",
                       @"",@"error",
                       nil];
    for (NSString *key in d) {
        NSLog(@"=======didSetDeviceWifi key: %@ value: %@", key, d[key]);
    }

    
    if(result == 0  && [device macAddress].length > 0) {
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                           device.did, @"did",
                           device.ipAddress, @"ipAddress",
                           [device macAddress], @"macAddress",
                           device.passcode, @"passcode",
                           device.productKey, @"productKey",
                           device.productName, @"productName",
                           device.remark, @"remark",
                           device.isConnected, @"isConnected",
                           device.isDisabled, @"isDisabled",
                           device.isLAN, @"isLAN",
                           device.isOnline, @"isOnline",
                           @"",@"error",
                           nil];
        for (NSString *key in d) {
            NSLog(@"=======success [device macAddress] key: %@ value: %@", key, d[key]);
        }
        _currentPairDeviceMacAddress=device.macAddress;
        
    }else if(result == 0  && device.macAddress.length > 0) {
            NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                               device.did, @"did",
                               device.ipAddress, @"ipAddress",
                               device.macAddress, @"macAddress",
                               device.passcode, @"passcode",
                               device.productKey, @"productKey",
                               device.productName, @"productName",
                               device.remark, @"remark",
                               device.isConnected, @"isConnected",
                               device.isDisabled, @"isDisabled",
                               device.isLAN, @"isLAN",
                               device.isOnline, @"isOnline",
                               @"",@"error",
                               nil];
            for (NSString *key in d) {
                NSLog(@"=======success device.macAddress key: %@ value: %@", key, d[key]);
            }
            _currentPairDeviceMacAddress=device.macAddress;
            
        }else if(result == XPGWifiError_CONFIGURE_TIMEOUT){
        NSLog(@"======timeout=====");
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:self.commandHolder.callbackId];
    }else {
        NSLog(@"======error code:===%d", result);
        NSLog(@"======did===%@", device.did);
    }
}

-(void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didDiscovered:(NSArray *)deviceList result:(int)result{
    if (result == 0 && deviceList.count > 0) {
        for (XPGWifiDevice *device in deviceList){
            NSLog(@"======_currentPairDeviceMacAddress:%@ macAddress:%@ did:%@ (device.did.length>0):%d",
                  _currentPairDeviceMacAddress,
                  device.macAddress,
                  device.did,
                  (device.did.length>0));
            
            if( [_currentPairDeviceMacAddress isEqualToString:device.macAddress]&&(device.did.length>0)){
                NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                                   device.did, @"did",
                                   device.ipAddress, @"ipAddress",
                                   device.macAddress, @"macAddress",
                                   device.passcode, @"passcode",
                                   device.productKey, @"productKey",
                                   device.productName, @"productName",
                                   device.remark, @"remark",
                                   device.isConnected, @"isConnected",
                                   device.isDisabled, @"isDisabled",
                                   device.isLAN, @"isLAN",
                                   device.isOnline, @"isOnline",
                                   @"",@"error",
                                   nil];
                
                for (NSString *key in d) {
                    NSLog(@"=======didDiscovered:success key: %@ value: %@", key, d[key]);
                }
                _currentPairDeviceMacAddress=nil;
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:d];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
            }
        }
    }
}

- (void)dealloc:(CDVInvokedUrlCommand *)command
{
    NSLog(@"//====dealloc...====");
    _shareInstance = nil;
    _currentPairDeviceMacAddress=nil;
     _shareInstance.delegate = nil;
}


- (void)dispose{
    NSLog(@"//====disposed...====");
    _shareInstance=nil;
    _currentPairDeviceMacAddress=nil;
     _shareInstance.delegate = nil;
}
@end
