/********* gwsdkwrapper.m Cordova Plugin Implementation *******/

#import "gwsdk.h"
#import "GwsdkUtils.h"


@implementation gwsdk

@synthesize commandHolder;
@synthesize _deviceList;

NSString *_currentPairDeviceMacAddress;
NSInteger currentState;
bool _debug = true;
NSString *_uid, *_token, *_mac, *_remark, *_alias;
NSMutableDictionary *_controlObject;
BOOL isDiscoverLock;
GizWifiDevice *_currentDevice;
NSArray *_memoryDeviceList; //内存中的device列表。
NSArray *devices; //内存中的device列表。
NSString *currentUpdateProductKey;
//当前更新的设备
NSTimer *timer;

CDVInvokedUrlCommand *listenerCommandHolder;
//添加listener的callback
CDVInvokedUrlCommand *updateDeviceFromServerCommandHolder;
//更新本地配置信息，必须
CDVInvokedUrlCommand *writeCommandHolder;
//写入设备的callbackId
CDVInvokedUrlCommand *startDeviceListCommandHolder;
//获取设备列表的回调
CDVInvokedUrlCommand *getHardwareInfoCommandHolder;
//获取设备详细信息
int attempts;//尝试次数
/**
 *  控制状态枚举
 */
typedef NS_ENUM(NSInteger, GwsdkStateCode) {
    /**
     *  只配对设备
     */
            SetWifiCode = 0,
    /**
     *  发现设备列表
     */
            GetDevcieListCode = 1,
    /**
     *  控制设备
     */
            ControlCode = 2,
    /**
     *  配对设备并且绑定设备
     */
            SetDeviceWifiBindDevice = 3,
    /**
     * 循环获取设备列表
     */
            StartGetDeviceListCode = 4,

    setDeviceOnboardingCode = 5,
    setDeviceOnboardingAndBindDeviceCode = 6,
    getBoundDevicesCode = 7
};


- (void)pluginInitialize {
    NSString *gizwAppId = [[self.commandDelegate settings] objectForKey:@"gizwappid"];
    if (gizwAppId) {
        [GizWifiSDK startWithAppID:gizwAppId];
        self.gizwAppId = gizwAppId;
    }

}

/**
 *  初始化状态，设置appid
 *
 *  @param command <#command description#>
 */
- (void)init:(CDVInvokedUrlCommand *)command {
    if (!([GizWifiSDK sharedInstance].delegate)) {
        [GizWifiSDK sharedInstance].delegate = self;
    }
    devices = [GizWifiSDK sharedInstance].deviceList;
    _currentPairDeviceMacAddress = nil;
    isDiscoverLock = true;
    attempts = 2;//尝试两次绑定。
    self.commandHolder = command;
}

/**
 *  cordova 配对设备上网
 *
 *  @param command [appid,"",ssid,pwd,timeout]
 */
- (void)setDeviceWifi:(CDVInvokedUrlCommand *)command {

    [self init:command];
    currentState = SetWifiCode;

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
    NSString *timeout = [command.arguments objectAtIndex:3];
    //新接口 11.24
    if (_debug) {
        NSLog(@"ssid:%@,pwd:%@", command.arguments[1], command.arguments[2]);
    }
    [[XPGWifiSDK sharedInstance] setDeviceWifi:command.arguments[1] key:command.arguments[2] mode:XPGWifiSDKAirLinkMode softAPSSIDPrefix:nil timeout:[timeout intValue] wifiGAgentType:nil];
}

/**
 *  cordova 配对上网，并且绑定这个设备
 *
 *  @param command ["appid","","ssid","pwd",uid,token,timeout,mode,softApssidPrefix,wifiGAgentType]
 */
- (void)setDeviceWifiBindDevice:(CDVInvokedUrlCommand *)command {

    [self init:command];
    currentState = SetDeviceWifiBindDevice;
    _uid = command.arguments[3];
    _token = command.arguments[4];

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
    NSString *timeout = [command.arguments objectAtIndex:5];
    NSString *mode = [command.arguments objectAtIndex:6];
    //新接口 11.24
    if (_debug) {
        NSLog(@"ssid:%@,pwd:%@ uid:%@ token:%@ timeout:%@ mode:%@ softAPssidPrefix:%@ wifiGAgentType:%@",
                command.arguments[1],
                command.arguments[2],
                command.arguments[3],
                command.arguments[4],
                command.arguments[5],
                command.arguments[6],
                command.arguments[7],
                command.arguments[8]);
    }
//    NSArray *abc = [[NSArray alloc] initWithObjects:@(XPGWifiGAgentTypeHF),nil];
    //todo 如果上一次配对没有结束，下次请求会上报 -46	XPGWifiError_IS_RUNNING	当前事件正在处理 超时以后可以继续配置
    [[XPGWifiSDK sharedInstance]
            setDeviceWifi:command.arguments[1]
                      key:command.arguments[2]
                     mode:[mode intValue]
         softAPSSIDPrefix:([command.arguments objectAtIndex:7] == [NSNull null]) ? nil : command.arguments[7]
                  timeout:[timeout intValue]
           wifiGAgentType:nil];//[command.arguments objectAtIndex:8]==[NSNull null]?nil:[command.arguments objectAtIndex:8]];

}

/**
 *  cordova 获取设备列表
 *
 *  @param command [appid,[productkey],uid,token]
 */
- (void)getDeviceList:(CDVInvokedUrlCommand *)command {
    [self init:command];
    currentState = GetDevcieListCode;
    _uid = command.arguments[1];
    _token = command.arguments[2];
    NSLog(@"\n======productkeys%@=====\n", command.arguments[0]);
    [[XPGWifiSDK sharedInstance] getBoundDevices:command.arguments[1] token:command.arguments[2] specialProductKeys:command.arguments[0]];
}

- (void)startGetDeviceList:(CDVInvokedUrlCommand *)command {
    startDeviceListCommandHolder = command;
    currentState = StartGetDeviceListCode;
    _uid = command.arguments[1];
    _token = command.arguments[2];
    float interval = [command.arguments[3] floatValue];
    if (interval > 0) {
        interval = interval / 1000;
        if (!timer) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    _uid, @"uid",
                    _token, @"token",
                            nil];
            timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                     target:self
                                                   selector:@selector(startScan:)
                                                   userInfo:userInfo
                                                    repeats:YES];
        }
    } else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"interval is zero!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)startScan:(NSTimer *)timer {
    NSLog(@"=======%@====", @"startScan");
    NSString *uid = [[timer userInfo] objectForKey:@"uid"];
    NSString *token = [[timer userInfo] objectForKey:@"token"];
    [XPGWifiSDK sharedInstance].delegate = self;
    [[XPGWifiSDK sharedInstance] getBoundDevices:uid
                                           token:token
                              specialProductKeys:nil];

}

- (void)stopGetDeviceList:(CDVInvokedUrlCommand *)command {
    if (timer) {
        [timer invalidate];
        timer = nil;
        startDeviceListCommandHolder = nil;
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"timer is null!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

/**
 *  cordova 绑定设备
 *
 *  @param command ["appid","prodctekey","uid","token","did","passcode","remark"]
 */
- (void)deviceBinding:(CDVInvokedUrlCommand *)command {
    [self init:command];//初始化设置appid
    /**
     绑定设备到服务器
     @param token 登录成功后得到的token
     @param uid 登录成功后得到的uid
     @param did 待绑定设备的did
     @param passCode 待绑定设备的passCode（能得到就传，得不到可传Nil，SDK会内部尝试获取PassCode）
     @param remark 待绑定设备的别名，无别名可传nil
     @see 对应的回调接口：[XPGWifiSDKDelegate XPGWifiSDK:didBindDevice:error:errorMessage:]
     */
    _uid = command.arguments[0];
    _token = command.arguments[1];
    [[XPGWifiSDK sharedInstance] bindDeviceWithUid:command.arguments[0] token:command.arguments[1] did:command.arguments[2] passCode:command.arguments[3] remark:command.arguments[4]];
}

/**
 *  cordova 绑定设备
 *
 *  @param command ["appid","prodctekey","uid","token","did","passcode"]
 */
- (void)unbindDevice:(CDVInvokedUrlCommand *)command {
    [self init:command];//初始化设置appid
    /**
     绑定设备到服务器
     @param token 登录成功后得到的token
     @param uid 登录成功后得到的uid
     @param did 待绑定设备的did
     @param passCode 待绑定设备的passCode（能得到就传，得不到可传Nil，SDK会内部尝试获取PassCode）
     @see 对应的回调接口：[XPGWifiSDKDelegate XPGWifiSDK:didUnbindDevice:error:errorMessage:]
     */
    _uid = command.arguments[0];
    _token = command.arguments[1];
    [[XPGWifiSDK sharedInstance] unbindDeviceWithUid:command.arguments[0] token:command.arguments[1] did:command.arguments[2] passCode:command.arguments[3]];
}

/**
 *  cordova 控制设备
 *
 *  @param command ["appid",["prodctkeys"],"uid","token","mac","value"]
 */
- (void)deviceControl:(CDVInvokedUrlCommand *)command {
    _uid = command.arguments[1];
    _token = command.arguments[2];
    _mac = command.arguments[3];
    _controlObject = command.arguments[4];//todo: back to value:5

    currentState = ControlCode;
    [self init:command];//初始化设置appid
    [[XPGWifiSDK sharedInstance] getBoundDevices:command.arguments[1] token:command.arguments[2] specialProductKeys:command.arguments[0]];

}

/**
 * cordova 获取ssid列表
 *
 *  @param command []
 */
- (void)getWifiSSIDList:(CDVInvokedUrlCommand *)command {
    self.commandHolder = command;
    [[XPGWifiSDK sharedInstance] getSSIDList];
}

/**
 *  cordova 开始device的监听
 *
 *  @param command []
 */
- (void)startDeviceListener:(CDVInvokedUrlCommand *)command {
    listenerCommandHolder = nil;
    listenerCommandHolder = command;
}

/**
 *  cordova 停止device的监听
 *
 *  @param command []
 */
- (void)stopDeviceListener:(CDVInvokedUrlCommand *)command {
    listenerCommandHolder = nil;
}

/**
 * cordova 连接设备
 *
 *  @param command ["uid","token","did"]
 */
- (void)connect:(CDVInvokedUrlCommand *)command {
    NSString *uid = command.arguments[0];
    NSString *token = command.arguments[1];
    NSString *did = command.arguments[2];
    self.commandHolder = command;
    BOOL isExist = false;
    for (XPGWifiDevice *device in _deviceList) {
        if ([did isEqualToString:device.did]) {
            selectedDevices = device;
            selectedDevices.delegate = self;
            isExist = true;
            //判断是否是登陆状态，如果是的话就直接返回成功。
            if (selectedDevices.isConnected == YES) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils deviceToDictionary:selectedDevices uid:_uid]];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                [selectedDevices login:uid token:token];
            }
        }
    }
    if (isExist == false) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This device does not exist!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }

}

/**
 * cordova 断开连接
 *
 *  @param command ["did"]
 */
- (void)disconnect:(CDVInvokedUrlCommand *)command {
    NSString *did = command.arguments[0];
    self.commandHolder = command;
    BOOL isExist = NO;//判断是否存在相同did的设备
    for (XPGWifiDevice *device in _deviceList) {
        if ([did isEqualToString:device.did]) {
            isExist = YES;
            [device disconnect];
        }
    }
    if (isExist == NO) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This device does not exist!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

/**
 * cordova 发送控制命令
 *
 *  @param command ["did","value"]
 */
- (void)write:(CDVInvokedUrlCommand *)command {
    NSString *did = command.arguments[0];
    NSMutableDictionary *value = command.arguments[1];
    BOOL isExist = false;

    for (XPGWifiDevice *device in _deviceList) {
        if ([did isEqualToString:device.did]) {
            //判断是否是登陆状态，如果是的话就直接返回成功。
            if (selectedDevices.isConnected == YES) {
                selectedDevices = device;
                selectedDevices.delegate = self;
                isExist = true;
                value = @{@"cmd" : @1, @"entity0" : value};
                NSLog(@"Write data: %@", value);
                [device write:value];
//                 writeCommandHolder=command;
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success!"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                /**
                 *  设备没有连接
                 */
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The device is not connected!"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }
    }
    if (isExist == false) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This device does not exist!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:writeCommandHolder.callbackId];
    }
}

- (void)getHardwareInfo:(CDVInvokedUrlCommand *)command {
    getHardwareInfoCommandHolder = command;
    NSString *did = command.arguments[0];
    BOOL isExist = NO;//判断是否存在相同did的设备
    for (XPGWifiDevice *device in _deviceList) {
        if ([did isEqualToString:device.did]) {
            isExist = YES;
            [device getHardwareInfo];
        }
    }
    if (isExist == NO) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This device does not exist!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

/**
 *  cordova 获取设备配置文件 配置文件，是定义 APP 与指定设备通信的规则
 *
 *  @param command ["productKey"]
 */
- (void)updateDeviceFromServer:(CDVInvokedUrlCommand *)command {
    updateDeviceFromServerCommandHolder = command;
    currentUpdateProductKey = command.arguments[0];
    [XPGWifiSDK updateDeviceFromServer:command.arguments[0]];
}

/**
 *  回调
 *
 *  @param wifiSDK wifiSDK
 *  @param product product
 *  @param result  int
 */
- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didUpdateProduct:(NSString *)product result:(int)result {
    if (updateDeviceFromServerCommandHolder != nil) {
        if (currentUpdateProductKey != nil && [product isEqualToString:currentUpdateProductKey]) {
            //说明下载的是这个产品
            if (result == XPGWifiError_NONE) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:product];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:updateDeviceFromServerCommandHolder.callbackId];
            } else {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:updateDeviceFromServerCommandHolder.callbackId];
            }
            currentUpdateProductKey = nil;
        }
    }
    if (result == XPGWifiError_NONE) {
        //下载配置成功
        NSLog(@"======didUpdateProduct==success:=\nproduct:%@\n====\nresult:%d", product, result);
    }
    else {
        //下载配置失败
        NSLog(@"======didUpdateProduct==error:=\nproduct:%@\n====\nresult:%d", product, result);
    }
}

/**
 *  方法 发送控制命令
 *  必须是已经配对的设备，并且连接
 *  @param device     要控制的设备
 *  @param objecValue 命令的object
 */
- (void)cWrite:(XPGWifiDevice *)device objecValue:(NSMutableDictionary *)objecValue {
    NSDictionary *data = nil;
    NSMutableDictionary *data1 = [NSMutableDictionary dictionaryWithDictionary:objecValue];
    @try {
        NSEnumerator *enumerator1 = [objecValue keyEnumerator];
        id key = [enumerator1 nextObject];
        while (key) {
            NSString *object = [objecValue objectForKey:key];
            NSData *data = [GwsdkUtils stringToHex:object];
            NSString *encodeStr = [XPGWifiBinary encode:data];
            NSLog(@"%@===%@", object, encodeStr);
            [data1 setObject:encodeStr forKey:key];
            key = [enumerator1 nextObject];
        }

        data = @{@"cmd" : @1, @"entity0" : data1};
        NSLog(@"Write data: %@", data);
        [device write:data];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:commandHolder.callbackId];

    }
    @catch (NSException *exception) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[exception reason]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:commandHolder.callbackId];

    }
}

/**
 *  方法 验证devicelist是否匹配
 *
 *  @param devicList <#devicList description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)hasDone:(NSArray *)devicList {
    if (_deviceList == nil) return false;
    return (_deviceList.count == devicList.count);
}

/**
 *  回调:获取ssid列表
 *
 *  @param wifiSDK  <#wifiSDK description#>
 *  @param ssidList <#ssidList description#>
 *  @param result   <#result description#>
 */
- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didGetSSIDList:(NSArray *)ssidList result:(int)result {
    //    self._arraySsidList=ssidList;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:ssidList];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandHolder.callbackId];
}

/**
 *  回调 设备断开连接
 *
 *  @param device XPGWifiDevice
 *  @param result int
 */
- (void)XPGWifiDeviceDidDisconnected:(XPGWifiDevice *)device result:(int)result {
    if (result == 0) {
        NSString *did = device.did;
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:did];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    } else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    }
}

/**
 *  回调 设备登陆的状态
 *
 *  @param device 当前连接的设备
 *  @param result 返回状态
 */
- (void)XPGWifiDevice:(XPGWifiDevice *)device didLogin:(int)result {
    if (result == 0 && device) {
//        if(_controlObject!=nil){
//            [self  cWrite:device objecValue:_controlObject];
//        }
        [GwsdkUtils logDevice:@"===didLogin=success===" device:device];
        selectedDevices = device;
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils deviceToDictionary:selectedDevices uid:_uid]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    } else {
        NSLog(@"===didLogin=error===%d", result);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    }
}

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
        switch (currentState) {
            case SetDeviceWifiBindDevice:
                //判断mac是否存在
                if ([device macAddress].length > 0 || device.macAddress.length > 0) {
                    //判断did是否存在
                    if (_currentPairDeviceMacAddress == nil && device.did.length > 0) {
                        selectedDevices = device;

                        //                                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                        //                                    [dict setValue:device.did forKey:@"did"];
                        //                                    [dict setValue:_uid forKey:@"uid"];
                        //                                    [dict setValue:_token forKey:@"token"];
                        //                                    [dict setValue:nil forKey:@"passcode"];
                        //                                    [dict setValue:nil forKey:@"remark"];
                        //                                    //设置定时器 三秒以后执行一次 等待3秒，因为需要等待服务器解绑已经绑定的设备
                        //                                    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(deviceBingding:uid:token:passcode:remark:) userInfo:dict repeats:NO];
                        // 让主线程暂停3秒，因为需要等待服务器解绑已经绑定的设备。第二种方法，可能造成app卡顿 不再使用
                        //[NSThread sleepForTimeInterval:10.00f];
                        NSString *passcode = device.passcode;
                        [[XPGWifiSDK sharedInstance] bindDeviceWithUid:_uid token:_token did:device.did passCode:passcode remark:nil];

                    } else {
                        _currentPairDeviceMacAddress = device.macAddress;
                    }
                }

                break;
            case SetWifiCode:
                //判断mac是否存在
                if ([device macAddress].length > 0 || device.macAddress.length > 0) {
                    //判断did是否存在
                    if (_currentPairDeviceMacAddress == nil && device.did.length > 0) {
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils deviceToDictionary:device uid:self.commandHolder.arguments[2]]];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
                    } else {
                        _currentPairDeviceMacAddress = device.macAddress;
                    }
                }
                break;
            default:
                break;
        }
    } else if (result == XPGWifiError_CONFIGURE_TIMEOUT) {
        if (_debug)
            NSLog(@"======timeout=====");

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"timeout"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    } else {
        if (_debug) {
            NSLog(@"======error code:===%d", result);
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    }
}

/**
 *  回调 设备列表的返回
 *  配对成功以后会触发，获取设备列表会触发
 *  @param wifiSDK    <#wifiSDK description#>
 *  @param deviceList <#deviceList description#>
 *  @param result     <#result description#>
 */
- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didDiscovered:(NSArray *)deviceList result:(int)result {
    if (result == 0) {
        if (startDeviceListCommandHolder != nil) {
            if (deviceList.count > 0) {
                _deviceList = deviceList;
                NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
                for (XPGWifiDevice *device in deviceList) {

                    [jsonArray addObject:[GwsdkUtils deviceToDictionary:device uid:_uid]];
                }
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:jsonArray];
                [pluginResult setKeepCallbackAsBool:true];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:startDeviceListCommandHolder.callbackId];
            } else {
                //deviceList is zero;
            }
        }
        switch (currentState) {
            case SetWifiCode:
                if (deviceList.count > 0) {
                    for (XPGWifiDevice *device in deviceList) {
                        [GwsdkUtils logDevice:@"didDiscovered" device:device];
                        if ([_currentPairDeviceMacAddress isEqualToString:device.macAddress] && (device.did.length > 0)) {
                            _currentPairDeviceMacAddress = nil;
                            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils deviceToDictionary:device uid:self.commandHolder.arguments[2]]];
                            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
                        }
                    }
                }
                break;
            case GetDevcieListCode:
                if (deviceList.count > 0) {
                    if ([self hasDone:deviceList]) {
                        NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
                        for (XPGWifiDevice *device in deviceList) {
                            //设备的物理地址。如果是 VIRTUAL:SITE，则是虚拟设备
                            NSString *mac = device.macAddress;
                            //设备云端身份标识 DID
                            NSString *did = device.did;
                            //用于控制设备的密钥
                            NSString *passcode = device.passcode;
                            //设备的小循环 IP 地址
                            NSString *ipAddress = device.ipAddress;
                            //设备的产品唯一标识符
                            NSString *productKey = device.productKey;
                            //设备名称
                            NSString *productName = device.productName;
                            //设备别名。在绑定的时候设置
                            NSString *remark = device.remark;
                            //当前设备是否已经建立连接
                            NSNumber *isConnected = [NSNumber numberWithBool:device.isConnected];
                            //当前设备是否是小循环设备
                            NSNumber *isLAN = [NSNumber numberWithBool:device.isLAN];
                            //云端判断设备是否在线
                            NSNumber *isOnline = [NSNumber numberWithBool:device.isOnline];
                            //云端判断设备是否注销
                            NSNumber *isDisabled = [NSNumber numberWithBool:device.isDisabled];
                            //设备是否跟用户绑定
                            NSNumber *isBind = [NSNumber numberWithBool:[device isBind:_uid]];

                            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObjectsAndKeys:
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
                            [jsonArray addObject:d];
                        }
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:jsonArray];
                        [pluginResult setKeepCallbackAsBool:true];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
                    } else {
                        _deviceList = deviceList;
                    }
                } else {
                    //deviceList is zero;
                }

                break;
            case ControlCode:
                if (isDiscoverLock) {//如果锁定状态为true 那么就是控制命令已经发送成功
                    if (deviceList.count > 0 && result == 0) {
                        for (int i = 0; i < [deviceList count]; i++) {
                            NSLog(@"=======%@", [deviceList[i] macAddress]);
                            XPGWifiDevice *device = deviceList[i];
                            //[[deviceList[i] macAddress]]


                            if ([device.macAddress isEqualToString:[_mac uppercaseString]]) {
                                isDiscoverLock = false;//设置锁定状态
                                if (device.isConnected) {
                                    [self cWrite:device objecValue:_controlObject];
                                } else {
                                    device.delegate = self;
                                    [device login:_uid token:_token];

                                }
                            }
                        }

                        //        [self deviceLogin:deviceList];
                    }
                }
                break;
            case SetDeviceWifiBindDevice:
                if (deviceList.count > 0 && _currentPairDeviceMacAddress != nil) {
                    for (XPGWifiDevice *device in deviceList) {
                        [GwsdkUtils logDevice:@"didDiscovered" device:device];
                        if ([_currentPairDeviceMacAddress isEqualToString:device.macAddress] && (device.did.length > 0)) {
                            selectedDevices = device;
                            if (isDiscoverLock == true) {
                                isDiscoverLock = false;

                                //                                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                //                                [dict setValue:device.did forKey:@"did"];
                                //                                [dict setValue:_uid forKey:@"uid"];
                                //                                [dict setValue:_token forKey:@"token"];
                                //                                [dict setValue:nil forKey:@"passcode"];
                                //                                [dict setValue:nil forKey:@"remark"];
                                //                                //设置定时器 三秒以后执行一次 等待3秒，因为需要等待服务器解绑已经绑定的设备
                                //                                [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(deviceBingding:uid:token:passcode:remark:) userInfo:dict repeats:NO];
                                //让主线程暂停3秒，因为需要等待服务器解绑已经绑定的设备。第二种方法，可能造成app卡顿 不再使用
                                //[NSThread sleepForTimeInterval:10.00f];
                                //用于控制设备的密钥
                                NSString *passcode = device.passcode;
                                [[XPGWifiSDK sharedInstance] bindDeviceWithUid:_uid token:_token did:device.did passCode:passcode remark:nil];
                            }
                        }
                    }
                }
                break;
            default:
                break;
        }
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
        if (selectedDevices) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils deviceToDictionary:selectedDevices uid:_uid]];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:did];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
        //清空缓存
        selectedDevices = nil;
        _currentPairDeviceMacAddress = nil;
    } else {
        //绑定失败
        NSLog(@"\n =========binding error========\n error:%@ \n errorMessage:%@ \n attempts:%d \n", error, errorMessage, attempts);
        if (attempts > 0) {
            isDiscoverLock = true;
            --attempts;
        } else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
            //清空缓存
            selectedDevices = nil;
            _currentPairDeviceMacAddress = nil;
        }
    }


}

/**
 *  回调 解绑设备
 *
 *  @param wifiSDK      <#wifiSDK description#>
 *  @param did          <#did description#>
 *  @param error        <#error description#>
 *  @param errorMessage <#errorMessage description#>
 */
- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didUnbindDevice:(NSString *)did error:(NSNumber *)error errorMessage:(NSString *)errorMessage {
    if ([error intValue] == XPGWifiError_NONE) {
        //解绑成功
        NSLog(@"\n =========didUnbindDevice success========\n %@", did);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:did];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    } else {
        //解绑失败
        NSLog(@"\n =========didUnbindDevice error========\n error:%@ \n errorMessage:%@ \n", error, errorMessage);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    }

}

/**
 *  回调 获取硬件信息 [device getHardwareInfo];
 *
 *  @param device <#device description#>
 *  @param hwInfo <#hwInfo description#>
 */
- (void)XPGWifiDevice:(XPGWifiDevice *)device didQueryHardwareInfo:(NSDictionary *)hwInfo {
    NSString *hardWareInfo = [NSString stringWithFormat:@"WiFi Hardware Version: %@,\
                              WiFi Software Version: %@,\
                              MCU Hardware Version: %@,\
                              MCU Software Version: %@,\
                              Firmware Id: %@,\
                              Firmware Version: %@,\
                              Product Key: %@,\
                              Device ID: %@,\
                              Device IP: %@,\
                              Device MAC: %@"
            , [hwInfo valueForKey:XPGWifiDeviceHardwareWifiHardVerKey]
            , [hwInfo valueForKey:XPGWifiDeviceHardwareWifiSoftVerKey]
            , [hwInfo valueForKey:XPGWifiDeviceHardwareMCUHardVerKey]
            , [hwInfo valueForKey:XPGWifiDeviceHardwareMCUSoftVerKey]
            , [hwInfo valueForKey:XPGWifiDeviceHardwareFirmwareIdKey]
            , [hwInfo valueForKey:XPGWifiDeviceHardwareFirmwareVerKey]
            , [hwInfo valueForKey:XPGWifiDeviceHardwareProductKey]
            , device.did, device.ipAddress, device.macAddress];
    NSLog(@"=========didQueryHardwareInfo=========\n %@", hardWareInfo);

    NSMutableDictionary *dInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [hwInfo valueForKey:XPGWifiDeviceHardwareWifiHardVerKey], @"XPGWifiDeviceHardwareWifiHardVer",
            [hwInfo valueForKey:XPGWifiDeviceHardwareWifiSoftVerKey], @"XPGWifiDeviceHardwareWifiSoftVer",
            [hwInfo valueForKey:XPGWifiDeviceHardwareMCUHardVerKey], @"XPGWifiDeviceHardwareMCUHardVer",
            [hwInfo valueForKey:XPGWifiDeviceHardwareMCUSoftVerKey], @"XPGWifiDeviceHardwareMCUSoftVer",
            [hwInfo valueForKey:XPGWifiDeviceHardwareFirmwareIdKey], @"XPGWifiDeviceHardwareFirmwareId",
            [hwInfo valueForKey:XPGWifiDeviceHardwareFirmwareVerKey], @"XPGWifiDeviceHardwareFirmwareVer",
            [hwInfo valueForKey:XPGWifiDeviceHardwareProductKey], @"XPGWifiDeviceHardwareProductKey",
            device.did, @"did",
            device.macAddress, @"macAddress",
                    nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dInfo];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:getHardwareInfoCommandHolder.callbackId];

}
//-----------------------------------------------新版接口 16.08.30---------------------------------------------------------
/**
 *  cordova 配对设备上网
 *
 *  @param command [wifiSSID, wifiKey, mode, timeout, softAPSSIDPrefix, wifiGAgentType]
 */
- (void)setDeviceOnboarding:(CDVInvokedUrlCommand *)command {

    [self init:command];
    currentState = setDeviceOnboardingCode;
    /*
       把设备配置到局域网 wifi 上。设备处于 softap 模式时，模组会产生一个热点名称，手机 wifi 连接此热点后就可以配置了。如果是机智云提供的固件，模组热点名称前缀为"XPG-GAgent-"，密码为"123456789"。设备处于 airlink 模式时，手机随时都可以开始配置。但无论哪种配置方式，设备上线时，手机要连接到配置的局域网 wifi 上，才能够确认设备已配置成功。
       设备配置成功时，在回调中会返回设备 mac 地址。如果设备重置了，设备did可能要在设备搜索回调中才能获取。

       @param ssid 待配置的路由 SSID 名
       @param key 待配置的路由密码
       @param mode 配置模式，详细见 GizWifiConfigureMode 枚举定义
       @param softAPSSIDPrefix SoftAPMode 模式下 SoftAP 的 SSID 前缀或全名。默认前缀为：XPG-GAgent-，SDK 以此判断手机当前是否连上了设备的 SoftAP 热点。AirLink 模式时传 nil 即可
       @param timeout 配置的超时时间。SDK 默认执行的最小超时时间为30秒
       @param types 待配置的模组类型，是一个GizWifiGAgentType 枚举数组。若不指定则默认配置乐鑫模组。GizWifiGAgentType定义了 SDK 支持的所有模组类型
       @see 对应的回调接口：[GizWifiSDKDelegate wifiSDK:didSetDeviceOnboarding:device:]
       @see GizConfigureMode
       @see GizWifiGAgentType
     */
    if (_debug) {
        NSLog(@"ssid:%@,pwd:%@", command.arguments[0], command.arguments[1]);
    }
    NSString *ssid = [command.arguments objectAtIndex:0];
    NSString *pwd = [command.arguments objectAtIndex:1];
    NSString *mode = [command.arguments objectAtIndex:2];
    NSString *timeout = [command.arguments objectAtIndex:3];
    NSString *softAPSSIDPrefix = ([command.arguments objectAtIndex:4] == [NSNull null]) ? nil : command.arguments[4];
    NSArray *wifiAgentTypeArr = [command.arguments objectAtIndex:5];

    [[XPGWifiSDK sharedInstance] setDeviceOnboarding:ssid
                                                 key:pwd
                                          configMode:[mode intValue]
                                    softAPSSIDPrefix:softAPSSIDPrefix
                                             timeout:[timeout intValue]
                                      wifiGAgentType:wifiAgentTypeArr];
}

/**
 *  cordova 配对上网，并且绑定这个设备
 *
 *  @param command ["appid","","ssid","pwd",uid,token,timeout,mode,softApssidPrefix,wifiGAgentType]
 */
- (void)setDeviceOnboardingAndBindDevice:(CDVInvokedUrlCommand *)command {

    [self init:command];
    currentState = setDeviceOnboardingAndBindDeviceCode;

    /*
          把设备配置到局域网 wifi 上。设备处于 softap 模式时，模组会产生一个热点名称，手机 wifi 连接此热点后就可以配置了。如果是机智云提供的固件，模组热点名称前缀为"XPG-GAgent-"，密码为"123456789"。设备处于 airlink 模式时，手机随时都可以开始配置。但无论哪种配置方式，设备上线时，手机要连接到配置的局域网 wifi 上，才能够确认设备已配置成功。
          设备配置成功时，在回调中会返回设备 mac 地址。如果设备重置了，设备did可能要在设备搜索回调中才能获取。

          @param ssid 待配置的路由 SSID 名
          @param key 待配置的路由密码
          @param mode 配置模式，详细见 GizWifiConfigureMode 枚举定义
          @param softAPSSIDPrefix SoftAPMode 模式下 SoftAP 的 SSID 前缀或全名。默认前缀为：XPG-GAgent-，SDK 以此判断手机当前是否连上了设备的 SoftAP 热点。AirLink 模式时传 nil 即可
          @param timeout 配置的超时时间。SDK 默认执行的最小超时时间为30秒
          @param types 待配置的模组类型，是一个GizWifiGAgentType 枚举数组。若不指定则默认配置乐鑫模组。GizWifiGAgentType定义了 SDK 支持的所有模组类型
          @see 对应的回调接口：[GizWifiSDKDelegate wifiSDK:didSetDeviceOnboarding:device:]
          @see GizConfigureMode
          @see GizWifiGAgentType
        */
    //新接口 8.31
    if (_debug) {
        NSLog(@"ssid:%@,pwd:%@ mode:%@ timeout:%@ softAPssidPrefix:%@ wifiGAgentType:%@ uid:%@ token:%@ ",
                command.arguments[1],
                command.arguments[2],
                command.arguments[3],
                command.arguments[4],
                command.arguments[5],
                command.arguments[6],
                command.arguments[7]);
    }

    NSString *ssid = [command.arguments objectAtIndex:0];
    NSString *pwd = [command.arguments objectAtIndex:1];
    NSString *mode = [command.arguments objectAtIndex:2];
    NSString *timeout = [command.arguments objectAtIndex:3];
    NSString *softAPSSIDPrefix = ([command.arguments objectAtIndex:4] == [NSNull null]) ? nil : command.arguments[7];
    NSArray *wifiAgentTypeArr = [command.arguments objectAtIndex:5];
    _uid = command.arguments[6];
    _token = command.arguments[7];
    _remark = command.arguments[8];
    _alias = command.arguments[9];


    [[XPGWifiSDK sharedInstance] setDeviceOnboarding:ssid
                                                 key:pwd
                                          configMode:[mode intValue]
                                    softAPSSIDPrefix:softAPSSIDPrefix
                                             timeout:[timeout intValue]
                                      wifiGAgentType:wifiAgentTypeArr];
}

/**
 *  cordova 绑定设备
 *
 *  @param command ["appid","prodctekey","uid","token","did","passcode"]
 */
- (void)unbindDevice2:(CDVInvokedUrlCommand *)command {
    [self init:command];//初始化设置appid
    /**
     绑定设备到服务器
     @param token 登录成功后得到的token
     @param uid 登录成功后得到的uid
     @param did 待绑定设备的did
     @param passCode 待绑定设备的passCode（能得到就传，得不到可传Nil，SDK会内部尝试获取PassCode）
     @see 对应的回调接口：[XPGWifiSDKDelegate XPGWifiSDK:didUnbindDevice:error:errorMessage:]
     */
    _uid = command.arguments[0];
    _token = command.arguments[1];
    [[XPGWifiSDK sharedInstance] unbindDevice:_uid token:_token did:command.arguments[2]];
}

/**
 *  cordova 获取设备列表
 *
 *  @param command [appid,[productkey],uid,token]
 */
- (void)getBoundDevices:(CDVInvokedUrlCommand *)command {
    [self init:command];
    currentState = getBoundDevicesCode;
    _uid = command.arguments[1];
    _token = command.arguments[2];
    NSLog(@"\n======productkeys%@=====\n", command.arguments[0]);
    NSArray *productkeys = [command.arguments objectAtIndex:0];
    [[XPGWifiSDK sharedInstance] getBoundDevices:command.arguments[1] token:command.arguments[2]
                              specialProductKeys:productkeys];
}

/**
 *  cordova 获取硬件信息
 *
 *  不订阅设备也可以获取硬件信息。APP可以获取模块协议版本号，mcu固件版本号等硬件信息，但只有局域网设备才支持该功能。
 */
- (void)getHardwareInfo2:(CDVInvokedUrlCommand *)command {
    getHardwareInfoCommandHolder = command;
    NSString *did = command.arguments[0];
    BOOL isExist = NO;//判断是否存在相同did的设备
    for (XPGWifiDevice *device in _deviceList) {
        if ([did isEqualToString:device.did]) {
            isExist = YES;
            device.delegate = self;
            [device getHardwareInfo];
        }
    }
    if (isExist == NO) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This device does not exist!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

/**
 * cordova 发送控制指令
 * 设备订阅变成可控状态后，APP可以发送控制指令。控制指令是字典格式，键值对为数据点名称和值。操作指令的确认回复，通过didReceiveData回调返回。
   APP下发操作指令时可以指定sn，通过回调参数中的sn能够对应到下发指令是否发送成功了。但回调参数dataMap有可能是空字典，
   这取决于设备回复时是否携带当前数据点的状态。
   如果APP下发指令后只关心是否有设备状态上报，那么下发指令的sn可填0，这时回调参数sn也为0。
 *  @param command ["did","value"]
 */
- (void)write1:(CDVInvokedUrlCommand *)command {
    NSString *did = command.arguments[0];
    NSMutableDictionary *value = command.arguments[1];
    BOOL isExist = false;

    for (GizWifiDevice *device in _deviceList) {
        if ([did isEqualToString:device.did]) {
            isExist = true;
            device.delegate = self;
            value = @{@"cmd" : @1, @"entity0" : value};
            NSLog(@"Write data: %@", value);
            [device write:value withSN:0];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success!"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            /**
             *  设备没有连接
             */
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The device is not connected!"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
    if (isExist == false) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This device does not exist!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:writeCommandHolder.callbackId];
    }
}


/**
 * 回调  新版本回调接口 16,08,30
 */
- (void)wifiSDK:(GizWifiSDK *)wifiSDK didSetDeviceOnboarding:(NSError *)result mac:(NSString *)mac
            did:(NSString *)did productKey:(NSString *)productKey {
    NSLog(@"code:%ld mac:%@ did:%@, productkey:%@", (long) result.code, mac, did, productKey);
    if (result.code == GIZ_SDK_SUCCESS) {
        // 配置成功
        switch (currentState) {
            case setDeviceOnboardingAndBindDeviceCode:
                //判断mac是否存在
                if (_currentPairDeviceMacAddress == nil && mac.length > 0 && did.length > 0) {
                    // [[GizWifiSDK sharedInstance] bindRemoteDevice:_uid token:_tokenmac:mac productKey:productKey productSecret:@"27d79f833378428ab25bead62819f91a"];
                    _currentPairDeviceMacAddress = mac;
                }
                break;
            case setDeviceOnboardingCode:
                //判断did是否存在
                if (mac.length > 0 && did.length > 0) {
                    NSMutableDictionary *d = [@{@"macAddress" : mac,
                            @"did" : did,
                            @"productKey" : productKey} mutableCopy];
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:d];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
                }
                break;
            default:
                break;
        }
    } else {
        // 配置失败
        if (_debug) {
            NSLog(@"======配置失败 \n error code:===%d", result);
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    }
}

/**
 * 回调  非局域网设备绑定
 */
- (void)wifiSDK:(GizWifiSDK *)wifiSDK didBindDevice:(NSError *)result did:(NSString *)did {
    if (result.code == GIZ_SDK_SUCCESS) {
        // 绑定成功
    } else {
        // 绑定失败
    }
}

/**
 * 回调 设置设备绑定信息
 *
 * 不订阅设备也可以设置设备的绑定信息。在设备列表中找到要修改的设备，如果是已绑定的，就可以修改remark和alias信息。
 */
- (void)device:(GizWifiDevice *)device didSetCustomInfo:(NSError *)result {
    if (result.code == GIZ_SDK_SUCCESS) {
        // 修改成功
        CDVPluginResult *pluginResult= [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils gizDeviceToDictionary:device]];
        NSLog(@"\n =========binding success========\n %@");
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
        //清空缓存
        selectedDevices = nil;
        _currentPairDeviceMacAddress = nil;
    } else {
        // 修改失败
    }
}

/**
 * 回调 实现回调
 */
- (void)wifiSDK:(GizWifiSDK *)wifiSDK didUnbindDevice:(NSError *)result did:(NSString *)did {
    if (result.code == GIZ_SDK_SUCCESS) {
        // 解绑成功
    } else {
        // 解绑失败
    }
}

/**
 * 回调 获取硬件信息
 * 不订阅设备也可以获取硬件信息。APP可以获取模块协议版本号，mcu固件版本号等硬件信息，但只有局域网设备才支持该功能。
 */
- (void)device:(GizWifiDevice *)device didGetHardwareInfo:(NSError *)result hardwareInfo:(NSDictionary *)hardwareInfo {
    if (result.code == GIZ_SDK_SUCCESS) {
        // 获取成功
//        NSString *Info = [NSString stringWithFormat:@"\
//            WiFi Hardware Version: %@,\
//            WiFi Software Version: %@,\
//            MCU Hardware Version: %@,\
//            MCU Software Version: %@,\
//            Firmware Id: %@,\
//            Firmware Version: %@,\
//             Product Key: %@“
//                , [hardwareInfo valueForKey:@"wifiHardVersion"]
//                , [hardwareInfo valueForKey:@"wifiSoftVersion"]
//                , [hardwareInfo valueForKey:@"mcuHardVersion"]
//                , [hardwareInfo valueForKey:@"mcuSoftVersion"]
//                , [hardwareInfo valueForKey:@"wifiFirmwareId"]
//                , [hardwareInfo valueForKey:@"wifiFirmwareVer"]
//                , [hardwareInfo valueForKey:@"productKey"]];

        NSMutableDictionary *dInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                [hardwareInfo valueForKey:@"wifiHardVersion"], @"XPGWifiDeviceHardwareWifiHardVer",
                [hardwareInfo valueForKey:@"wifiSoftVersion"], @"XPGWifiDeviceHardwareWifiSoftVer",
                [hardwareInfo valueForKey:@"mcuHardVersion"], @"XPGWifiDeviceHardwareMCUHardVer",
                [hardwareInfo valueForKey:@"mcuSoftVersion"], @"XPGWifiDeviceHardwareMCUSoftVer",
                [hardwareInfo valueForKey:@"wifiFirmwareId"], @"XPGWifiDeviceHardwareFirmwareId",
                [hardwareInfo valueForKey:@"wifiFirmwareVer"], @"XPGWifiDeviceHardwareFirmwareVer",
                [hardwareInfo valueForKey:@"productKey"], @"XPGWifiDeviceHardwareProductKey",
                device.did, @"did",
                device.macAddress, @"macAddress",
                        nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dInfo];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:getHardwareInfoCommandHolder.callbackId];
    } else {
        // 获取失败
    }
}

/**
 * 回调  接收设备列表变化上报
 *
 * APP设置好委托，启动SDK后，就可以收到SDK的设备列表推送。每次局域网设备或者用户绑定设备发生变化时，SDK都会主动上报最新的设备列表。设备断电再上电、有新设备上线等都会触发设备列表发生变化。用户登录后，SDK会主动把用户已绑定的设备列表上报给APP，绑定设备在不同的手机上登录帐号都可获取到。
   如果APP想要刷新绑定设备列表，可以调用绑定设备列表接口，同时可以指定自己关心的产品类型标识，SDK会把筛选后的设备列表返回给APP。
   SDK提供设备列表缓存，设备列表中的设备对象在整个APP生命周期中一直有效。缓存的设备列表会与当前最新的已发现设备同步更新。
 */
- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscovered:(NSError *)result deviceList:(NSArray *)deviceList {
    // 提示错误原因
    if (result.code != GIZ_SDK_SUCCESS) {
        NSLog(@"result: %@", result.localizedDescription);
        switch (currentState) {
            case setDeviceOnboardingAndBindDeviceCode:
                if (deviceList.count > 0 && _currentPairDeviceMacAddress != nil) {
                    for (GizWifiDevice *device in deviceList) {
                        if ([_currentPairDeviceMacAddress isEqualToString:device.macAddress] && (device.did.length > 0)) {
                            if (isDiscoverLock == true) {
                                isDiscoverLock = false;
                                device.delegate = self;
                                [device setCustomInfo:_remark alias:_alias];
                            }
                        }
                    }
                }
                break;
            default:
                break;
        }
    }
    // 显示变化后的设备列表
    NSLog(@"discovered deviceList: %@", deviceList);
    devices = deviceList;
}

/**
 * 回调 接收设备状态
 *
 * 设备订阅变成可控状态后，APP可以随时收到设备状态的主动上报，仍然通过didReceiveData回调返回。设备上报状态时，回调参数sn为0，回调参数dataMap为设备上报的状态。
 */
- (void)device:(GizWifiDevice *)device didReceiveData:(NSError *)result data:(NSDictionary *)dataMap withSN:(NSNumber *)sn {
    if (result.code == GIZ_SDK_SUCCESS) {

        // 已定义的设备数据点，有布尔、数值、枚举、扩展类型
        NSDictionary *dataDict = dataMap[@"data"];
        // 普通数据点，以布尔类型为例，打印对应的key和value
        BOOL onOff = [dataDict[@"LED_OnOff"] boolValue];
        NSLog(@"开关值LED_OnOff：%@", @(onOff));
        // 扩展类型数据点，key如果是“extData”
        NSData *extData = dataMap[@"extdata"];
        NSLog(@"扩展数据extData：%@", extData);

        // 已定义的设备故障或报警数据点，设备发生故障或报警后该字段有内容，没有发生故障或报警则没内容
        NSDictionary *alertsDict = dataMap[@"alerts"];
        NSDictionary *faultsDict = dataMap[@"faults"];
        NSLog(@"报警：%@, 故障：%@", alertsDict, faultsDict);

        // 透传数据，无数据点定义，适合开发者自行定义协议做数据解析
        NSData *binary = dataMap[@"binary"];
        NSLog(@"透传数据：%@", binary);


        NSString *did = device.did;

        //基本数据，与发送的数据格式⼀一致
        NSDictionary *sendData = dataMap[@"data"];
        if (sendData.count == 0) {
            return;
        }
        //警告
        NSData *alerts = dataMap[@"alerts"];
        //错误
        NSData *faults = dataMap[@"faults"];

        NSNumber *cmd = dataDict[@"cmd"];

        if ([cmd isEqualToNumber:[NSNumber numberWithInteger:1]] == YES) {
            //    向设备发送控制指令	1
            NSLog(@"\n================向设备发送控制指令====\ndid:%@", did);
            if (writeCommandHolder != nil) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:writeCommandHolder.callbackId];
            }
        } else if ([cmd isEqualToNumber:[NSNumber numberWithInteger:2]] == YES) {
            //    向设备请求设备状态	2
        } else if ([cmd isEqualToNumber:[NSNumber numberWithInteger:3]] == YES) {
            //    设备返回请求的设备状态	3
        } else if ([cmd isEqualToNumber:[NSNumber numberWithInteger:4]] == YES) {
            //    设备推送当前设备状态	4
            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    sendData, @"data",
                    alerts, @"alerts",
                    faults, @"faults",
                    did, @"did",
                            nil];
            if (listenerCommandHolder != nil) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:d];
                [pluginResult setKeepCallbackAsBool:true];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:listenerCommandHolder.callbackId];
            }
        }
    } else if (result.code == GIZ_SDK_RAW_DATA_TRANSMIT) {
        //透传数据
        NSData *binary = dataMap[@"binary"];
        if (listenerCommandHolder != nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer:binary];
            [pluginResult setKeepCallbackAsBool:true];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:listenerCommandHolder.callbackId];
        }
    } else {
        //出错，处理 result 信息
    }
}

// 实现系统事件通知回调
- (void)wifiSDK:(GizWifiSDK *)wifiSDK didNotifyEvent:(GizEventType)eventType eventSource:(id)eventSource eventID:(GizWifiErrorCode)eventID eventMessage:(NSString *)eventMessage {
    if (eventType == GizEventSDK) {
        // SDK发生异常的通知
        NSLog(@"SDK event happened: [%@] = %@", @(eventID), eventMessage);
    }
    else if (eventType == GizEventDevice) {
        // 设备连接断开时可能产生的通知
        GizWifiDevice *mDevice = (GizWifiDevice *) eventSource;
        NSLog(@"device mac %@ disconnect caused by %@", mDevice.macAddress, eventMessage);
    }
    else if (eventType == GizEventM2MService) {
        // M2M服务返回的异常通知
        NSLog(@"M2M domain %@ exception happened: [%@] = %@", (NSString *) eventSource, @(eventID), eventMessage);
    }
    else if (eventType == GizEventToken) {
        // token失效通知
        NSLog(@"token %@ expired: %@", (NSString *) eventSource, eventMessage);
    }
}

/**
 * 回调 2.0 SDK会自动探测配置文件是否有更新，有更新时会主动推送给APP。
 * APP只保留didUpdateProduct回调即可，不需要再使用updateDeviceFromServer这个兼容接口做强制更新了。
 */
- (void)wifiSDK:(GizWifiSDK *)wifiSDK didUpdateProduct:(NSError *)result producKey:(NSString *)productKey productUI:(NSString *)productUI {
    if (result.code == GIZ_SDK_SUCCESS) {
        NSLog(@"======didUpdateProduct==Success===\nproduct:%@\nresult:%d \nproductUI:%@", productKey, result, productUI);
    } else {
        NSLog(@"======didUpdateProduct==Error===\nproduct:%@\nresult:%d \nproductUI:%@", productKey, result, productUI);
    }
}

/**
 *  cordova 释放内存
 *
 *  @param command []
 */
- (void)dealloc:(CDVInvokedUrlCommand *)command {
    NSLog(@"//====dealloc...====");
    _currentPairDeviceMacAddress = nil;
    selectedDevices = nil;
    currentUpdateProductKey = nil;
    [XPGWifiSDK sharedInstance].delegate = nil;
    [XPGWifiSDK sharedInstance].delegate = self;
}


- (void)dispose {
    NSLog(@"//====disposed...====");
    _currentPairDeviceMacAddress = nil;
    selectedDevices = nil;
    currentUpdateProductKey = nil;
    [XPGWifiSDK sharedInstance].delegate = nil;
    [XPGWifiSDK sharedInstance].delegate = self;
}

@end
