/********* gwsdkwrapper.m Cordova Plugin Implementation *******/

#import "gwsdk.h"
#import "GwsdkUtils.h"

@implementation gwsdk

@synthesize commandHolder;
@synthesize _deviceList;

NSString    *_currentPairDeviceMacAddress;
NSInteger currentState;
bool      _debug=true;
NSString  *_uid,*_token,*_mac;
NSMutableDictionary *_controlObject;
BOOL isDiscoverLock;
XPGWifiDevice *_currentDevice;
NSArray *_memoryDeviceList; //内存中的device列表。
NSString *currentUpdateProductKey;//当前更新的设备
NSTimer *timer ;

CDVInvokedUrlCommand *listenerCommandHolder;//添加listener的callback
CDVInvokedUrlCommand *updateDeviceFromServerCommandHolder;//更新本地配置信息，必须
CDVInvokedUrlCommand *writeCommandHolder;//写入设备的callbackId
CDVInvokedUrlCommand *startDeviceListCommandHolder;//获取设备列表的回调
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
    SetDeviceWifiBindDevice=3,
    /**
     * 循环获取设备列表
     */
    StartGetDeviceListCode=4,
};


-(void)pluginInitialize{
     NSString* gizwAppId = [[self.commandDelegate settings] objectForKey:@"gizwappid"];
    if(gizwAppId){
        [XPGWifiSDK startWithAppID:gizwAppId];
        self.gizwAppId=gizwAppId;
    }

}
/**
 *  初始化状态，设置appid
 *
 *  @param command <#command description#>
 */
-(void)init:(CDVInvokedUrlCommand *) command{
    if(!([XPGWifiSDK sharedInstance].delegate)){
        [XPGWifiSDK sharedInstance].delegate = self;
    }
    _currentPairDeviceMacAddress=nil;
    isDiscoverLock=true;
    attempts=2;//尝试两次绑定。
    self.commandHolder = command;
}
/**
 *  cordova 配对设备上网
 *
 *  @param command [appid,"",ssid,pwd,timeout]
 */
-(void)setDeviceWifi:(CDVInvokedUrlCommand *)command{

    [self init:command];
    currentState=SetWifiCode;

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
      NSString *timeout=[command.arguments objectAtIndex:3];
    //新接口 11.24
    if (_debug) {
        NSLog(@"ssid:%@,pwd:%@",command.arguments[1],command.arguments[2]);
    }
    [[XPGWifiSDK  sharedInstance] setDeviceWifi:command.arguments[1] key:command.arguments[2] mode:XPGWifiSDKAirLinkMode softAPSSIDPrefix:nil timeout:[timeout intValue] wifiGAgentType:nil];
}
/**
 *  cordova 配对上网，并且绑定这个设备
 *
 *  @param command ["appid","","ssid","pwd",uid,token,timeout,mode,softApssidPrefix,wifiGAgentType]
 */
-(void)setDeviceWifiBindDevice:(CDVInvokedUrlCommand *)command{

    [self init:command];
    currentState=SetDeviceWifiBindDevice;
    _uid=command.arguments[3];
    _token=command.arguments[4];

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
    NSString *timeout=[command.arguments objectAtIndex:5];
    NSString *mode=[command.arguments objectAtIndex:6];
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
    [[XPGWifiSDK  sharedInstance]
     setDeviceWifi:command.arguments[1]
     key:command.arguments[2]
     mode:[mode intValue]
     softAPSSIDPrefix:([command.arguments objectAtIndex:7]==[NSNull null])?nil:command.arguments[7]
     timeout:[timeout intValue]
     wifiGAgentType:nil];//[command.arguments objectAtIndex:8]==[NSNull null]?nil:[command.arguments objectAtIndex:8]];

}
/**
 *  cordova 获取设备列表
 *
 *  @param command [appid,[productkey],uid,token]
 */
-(void)getDeviceList:(CDVInvokedUrlCommand *)command{
    [self init:command];
    currentState=GetDevcieListCode;
    _uid=command.arguments[1];
    _token=command.arguments[2];
    NSLog(@"\n======productkeys%@=====\n",command.arguments[0]);
    [[XPGWifiSDK sharedInstance] getBoundDevices:command.arguments[1] token:command.arguments[2] specialProductKeys:command.arguments[0]];
}
-(void)startGetDeviceList:(CDVInvokedUrlCommand *)command{
    startDeviceListCommandHolder=command;
    currentState=StartGetDeviceListCode;
    _uid=command.arguments[1];
    _token=command.arguments[2];
    float interval=[command.arguments[3] floatValue];
    if(interval>0) {
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
    } else{
        CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"interval is zero!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}
- (void)startScan:(NSTimer*)timer {
    NSLog(@"=======%@====",@"startScan");
    NSString *uid=[[timer userInfo] objectForKey:@"uid"];
     NSString *token=[[timer userInfo] objectForKey:@"token"];
      [XPGWifiSDK sharedInstance].delegate = self;
    [[XPGWifiSDK sharedInstance] getBoundDevices:uid
                                           token:token
                              specialProductKeys:nil];

}
-(void)stopGetDeviceList:(CDVInvokedUrlCommand *)command{
    if(timer){
        [timer invalidate];
        timer=nil;
        startDeviceListCommandHolder=nil;
        CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else{
        CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"timer is null!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}
/**
 *  cordova 绑定设备
 *
 *  @param command ["appid","prodctekey","uid","token","did","passcode","remark"]
 */
-(void)deviceBinding:(CDVInvokedUrlCommand *)command{
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
    _uid=command.arguments[0];
    _token=command.arguments[1];
    [[XPGWifiSDK sharedInstance] bindDeviceWithUid:command.arguments[0] token:command.arguments[1] did:command.arguments[2] passCode:command.arguments[3] remark:command.arguments[4]];
}
/**
 *  cordova 绑定设备
 *
 *  @param command ["appid","prodctekey","uid","token","did","passcode"]
 */
-(void)unbindDevice:(CDVInvokedUrlCommand *)command{
    [self init:command];//初始化设置appid
    /**
     绑定设备到服务器
     @param token 登录成功后得到的token
     @param uid 登录成功后得到的uid
     @param did 待绑定设备的did
     @param passCode 待绑定设备的passCode（能得到就传，得不到可传Nil，SDK会内部尝试获取PassCode）
     @see 对应的回调接口：[XPGWifiSDKDelegate XPGWifiSDK:didUnbindDevice:error:errorMessage:]
     */
    _uid=command.arguments[0];
    _token=command.arguments[1];
    [[XPGWifiSDK sharedInstance] unbindDeviceWithUid:command.arguments[0] token:command.arguments[1] did:command.arguments[2] passCode:command.arguments[3]];
}

/**
 *  cordova 控制设备
 *
 *  @param command ["appid",["prodctkeys"],"uid","token","mac","value"]
 */
-(void)deviceControl:(CDVInvokedUrlCommand *)command{
    _uid=command.arguments[1];
    _token=command.arguments[2];
    _mac=command.arguments[3];
    _controlObject=command.arguments[4];//todo: back to value:5

    currentState=ControlCode;
    [self init:command];//初始化设置appid
    [[XPGWifiSDK sharedInstance] getBoundDevices:command.arguments[1] token:command.arguments[2] specialProductKeys:command.arguments[0]];

}
/**
 * cordova 获取ssid列表
 *
 *  @param command []
 */
-(void)getWifiSSIDList:(CDVInvokedUrlCommand *)command{
     self.commandHolder = command;
    [[XPGWifiSDK sharedInstance] getSSIDList];
}
/**
 *  cordova 开始device的监听
 *
 *  @param command []
 */
-(void)startDeviceListener:(CDVInvokedUrlCommand *)command{
    listenerCommandHolder=nil;
    listenerCommandHolder=command;
}
/**
 *  cordova 停止device的监听
 *
 *  @param command []
 */
-(void)stopDeviceListener:(CDVInvokedUrlCommand *)command{
    listenerCommandHolder=nil;
}
/**
 * cordova 连接设备
 *
 *  @param command ["uid","token","did"]
 */
-(void)connect:(CDVInvokedUrlCommand *)command{
    NSString *uid=command.arguments[0];
    NSString *token=command.arguments[1];
    NSString *did=command.arguments[2];
    self.commandHolder=command;
    BOOL isExist=false;
    for(XPGWifiDevice *device in _deviceList){
        if ([did isEqualToString:device.did]) {
            selectedDevices=device;
            selectedDevices.delegate=self;
            isExist=true;
            //判断是否是登陆状态，如果是的话就直接返回成功。
            if (selectedDevices.isConnected==YES) {
               CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils deviceToDictionary:selectedDevices uid:_uid]];
                 [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }else{
                [selectedDevices login:uid token:token];
            }
        }
    }
    if(isExist==false){
         CDVPluginResult  *pluginResult= [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This device does not exist!"];
         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }

}
/**
 * cordova 断开连接
 *
 *  @param command ["did"]
 */
-(void)disconnect:(CDVInvokedUrlCommand *)command{
    NSString *did=command.arguments[0];
    self.commandHolder=command;
    BOOL isExist=NO;//判断是否存在相同did的设备
    for(XPGWifiDevice *device in _deviceList){
        if ([did isEqualToString:device.did]) {
            isExist=YES;
            [device disconnect];
        }
    }
    if(isExist==NO){
        CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This device does not exist!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}
/**
 * cordova 发送控制命令
 *
 *  @param command ["did","value"]
 */
-(void)write:(CDVInvokedUrlCommand *)command{
    NSString *did=command.arguments[0];
    NSMutableDictionary *value=command.arguments[1];
    BOOL isExist=false;

    for(XPGWifiDevice *device in _deviceList){
        if ([did isEqualToString:device.did]) {
            //判断是否是登陆状态，如果是的话就直接返回成功。
            if (selectedDevices.isConnected==YES) {
                selectedDevices=device;
                selectedDevices.delegate=self;
                isExist=true;
                value=@{@"cmd":@1,@"entity0":value};
                NSLog(@"Write data: %@", value);
                [device write:value];
//                 writeCommandHolder=command;
                CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success!"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                /**
                 *  设备没有连接
                 */
                CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The device is not connected!"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }
    }
    if(isExist==false){
        CDVPluginResult  *pluginResult= [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This device does not exist!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:writeCommandHolder.callbackId];
    }
}
/**
 *  cordova 获取设备配置文件 配置文件，是定义 APP 与指定设备通信的规则
 *
 *  @param command ["productKey"]
 */
-(void)updateDeviceFromServer:(CDVInvokedUrlCommand *)command{
    updateDeviceFromServerCommandHolder=command;
    currentUpdateProductKey=command.arguments[0];
    [XPGWifiSDK updateDeviceFromServer:command.arguments[0]];
}
/**
 *  回调
 *
 *  @param wifiSDK wifiSDK
 *  @param product product
 *  @param result  int
 */
-(void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didUpdateProduct:(NSString *)product result:(int)result{
    if (updateDeviceFromServerCommandHolder!=nil) {
        if(currentUpdateProductKey!=nil&&[product isEqualToString:currentUpdateProductKey]){
                //说明下载的是这个产品
                if(result == XPGWifiError_NONE){
                    CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:product];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:updateDeviceFromServerCommandHolder.callbackId];
                }else{
                    CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:updateDeviceFromServerCommandHolder.callbackId];
            }
                currentUpdateProductKey=nil;
        }
    }
    if(result == XPGWifiError_NONE)
    {
        //下载配置成功
        NSLog(@"======didUpdateProduct==success:=\nproduct:%@\n====\nresult:%d",product,result);
    }
    else
    {
        //下载配置失败
         NSLog(@"======didUpdateProduct==error:=\nproduct:%@\n====\nresult:%d",product,result);
    }
}
/**
 *  方法 发送控制命令
 *  必须是已经配对的设备，并且连接
 *  @param device     要控制的设备
 *  @param objecValue 命令的object
 */
-(void) cWrite:(XPGWifiDevice *)device objecValue:(NSMutableDictionary *)objecValue{
    NSDictionary *data=nil;
    NSMutableDictionary * data1 = [NSMutableDictionary dictionaryWithDictionary: objecValue];
    @try {
        NSEnumerator *enumerator1= [objecValue keyEnumerator];
        id key=[enumerator1 nextObject];
        while (key) {
            NSString *object=[objecValue objectForKey:key];
            NSData *data =[GwsdkUtils stringToHex:object];
            NSString * encodeStr= [XPGWifiBinary encode:data];
            NSLog(@"%@===%@",object,encodeStr);
            [data1 setObject:encodeStr forKey:key];
            key=[enumerator1 nextObject];
        }

        data=@{@"cmd":@1,@"entity0":data1};
        NSLog(@"Write data: %@", data);
        [device write:data];
        CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:commandHolder.callbackId];

    }
    @catch (NSException *exception) {
        CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[exception reason]];
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
- (BOOL)hasDone:(NSArray *)devicList{
    if(_deviceList == nil) return false;
    return (_deviceList.count == devicList.count);
}

/**
 *  回调:获取ssid列表
 *
 *  @param wifiSDK  <#wifiSDK description#>
 *  @param ssidList <#ssidList description#>
 *  @param result   <#result description#>
 */
-(void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didGetSSIDList:(NSArray *)ssidList result:(int)result{
    //    self._arraySsidList=ssidList;
    CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:ssidList];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandHolder.callbackId];
}
/**
 *  回调 设备断开连接
 *
 *  @param device XPGWifiDevice
 *  @param result int
 */
-(void)XPGWifiDeviceDidDisconnected:(XPGWifiDevice *)device result:(int)result{
    if (result==0) {
         NSString *did=device.did;
        CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:did];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    }else{
        CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    }
}
/**
 *  回调 设备登陆的状态
 *
 *  @param device 当前连接的设备
 *  @param result 返回状态
 */
- (void)XPGWifiDevice:(XPGWifiDevice *)device didLogin:(int)result{
    if(result == 0 && device){
//        if(_controlObject!=nil){
//            [self  cWrite:device objecValue:_controlObject];
//        }
        [GwsdkUtils  logDevice:@"===didLogin=success===" device:device];
        selectedDevices=device;
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils deviceToDictionary:selectedDevices uid:_uid]];
         [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    }else{
         NSLog(@"===didLogin=error===%d", result);
         CDVPluginResult  *pluginResult= [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
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
-(void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didSetDeviceWifi:(XPGWifiDevice *)device result:(int)result{
    if(result == XPGWifiError_NONE) {

        [GwsdkUtils logDevice:@"didSetDeviceWifi" device:device];
        switch (currentState) {
            case SetDeviceWifiBindDevice:
                //判断mac是否存在
                if ([device macAddress].length > 0||device.macAddress.length > 0) {
                    //判断did是否存在
                    if ( _currentPairDeviceMacAddress==nil&&device.did.length>0) {
                        selectedDevices=device;

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
                          NSString *passcode=device.passcode;
                        [[XPGWifiSDK sharedInstance] bindDeviceWithUid:_uid token:_token did:device.did passCode:passcode remark:nil];

                    }else{
                        _currentPairDeviceMacAddress=device.macAddress;
                    }
                }

                break;
            case SetWifiCode:
                //判断mac是否存在
                if ([device macAddress].length > 0||device.macAddress.length > 0) {
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
    }else if(result == XPGWifiError_CONFIGURE_TIMEOUT){
        if (_debug)
            NSLog(@"======timeout=====");

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"timeout"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    }else {
        if (_debug){
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
-(void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didDiscovered:(NSArray *)deviceList result:(int)result{
    if(result==0){
        if(startDeviceListCommandHolder!=nil){
            if (deviceList.count > 0) {
                _deviceList=deviceList;
                NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
                for (XPGWifiDevice *device in deviceList){

                    [jsonArray addObject:[GwsdkUtils deviceToDictionary:device uid:_uid]];
                }
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:jsonArray];
                [pluginResult setKeepCallbackAsBool:true];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:startDeviceListCommandHolder.callbackId];
            }else{
                //deviceList is zero;
            }
        }
        switch (currentState) {
            case SetWifiCode:
                if (deviceList.count > 0) {
                    for (XPGWifiDevice *device in deviceList){
                        [GwsdkUtils logDevice:@"didDiscovered" device:device];
                        if( [_currentPairDeviceMacAddress isEqualToString:device.macAddress]&&(device.did.length>0)){
                            _currentPairDeviceMacAddress=nil;
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
                        for (XPGWifiDevice *device in deviceList){
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
                            NSNumber *isBind=[NSNumber numberWithBool:[device isBind: _uid]];

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
                            [jsonArray addObject:d];
                        }
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:jsonArray];
                        [pluginResult setKeepCallbackAsBool:true];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
                    }else{
                        _deviceList=deviceList;
                    }
                }else{
                    //deviceList is zero;
                }

                break;
            case ControlCode:
                if(isDiscoverLock){//如果锁定状态为true 那么就是控制命令已经发送成功
                    if(deviceList.count>0 && result==0){
                        for (int i=0; i<[deviceList count]; i++) {
                            NSLog(@"=======%@",[deviceList[i] macAddress]);
                            XPGWifiDevice *device = deviceList[i];
                            //[[deviceList[i] macAddress]]


                            if ([device.macAddress isEqualToString: [_mac uppercaseString]]) {
                                isDiscoverLock=false;//设置锁定状态
                                if (device.isConnected) {
                                    [self cWrite:device objecValue:_controlObject];
                                }else{
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
                if (deviceList.count > 0&&_currentPairDeviceMacAddress!=nil) {
                    for (XPGWifiDevice *device in deviceList){
                        [GwsdkUtils logDevice:@"didDiscovered" device:device];
                        if([_currentPairDeviceMacAddress isEqualToString:device.macAddress]&&(device.did.length>0)){
                            selectedDevices=device;
                            if(isDiscoverLock==true){
                                isDiscoverLock=false;

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
                                NSString *passcode=device.passcode;
                                [[XPGWifiSDK sharedInstance] bindDeviceWithUid:_uid token:_token did:device.did passCode:passcode remark:nil];
                            }
                        }
                    }
                }
                break;
            default:
                break;
        }
    }else{
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
-(void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didBindDevice:(NSString *)did error:(NSNumber *)error errorMessage:(NSString *)errorMessage{

    if([error intValue] == XPGWifiError_NONE){
        CDVPluginResult *pluginResult ;
        //绑定成功
        NSLog(@"\n =========binding success========\n %@",did);
        if(selectedDevices){
            pluginResult= [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[GwsdkUtils deviceToDictionary:selectedDevices uid:_uid]];
        }else{
             pluginResult= [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:did];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
        //清空缓存
        selectedDevices=nil;
        _currentPairDeviceMacAddress=nil;
    } else {
        //绑定失败
        NSLog(@"\n =========binding error========\n error:%@ \n errorMessage:%@ \n attempts:%d \n",error,errorMessage,attempts);
        if(attempts>0){
            isDiscoverLock=true;
            --attempts;
        } else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
            //清空缓存
            selectedDevices=nil;
            _currentPairDeviceMacAddress=nil;
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
- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didUnbindDevice:(NSString *)did error:(NSNumber *)error errorMessage:(NSString *)errorMessage{
    if([error intValue] == XPGWifiError_NONE){
        //解绑成功
        NSLog(@"\n =========didUnbindDevice success========\n %@",did);
         CDVPluginResult   *pluginResult= [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:did];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    } else {
        //解绑失败
        NSLog(@"\n =========didUnbindDevice error========\n error:%@ \n errorMessage:%@ \n",error,errorMessage);
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
    }

}
/**
 *  回调 这里判断发送消息是否成功和接收设备上报的数据
 *
 *  @param device <#device description#>
 *  @param data   <#data description#>
 *  @param result <#result description#>
 */
- (void)XPGWifiDevice:(XPGWifiDevice *)device didReceiveData:(NSDictionary *)data result:(int)result{
    [GwsdkUtils logDevice:@"didReceiveData" device:device];
    NSString *did=device.did;
    NSLog(@"\n================didReceiveData=====================\n收到了:%d\n上报: %@\n===================end==================", result, data);

//    if (writeCommandHolder!=nil) {
//        if (result==0) {
//            CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//            [self.commandDelegate sendPluginResult:pluginResult callbackId:writeCommandHolder.callbackId];
//        }else{
//            CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
//            [self.commandDelegate sendPluginResult:pluginResult callbackId:writeCommandHolder.callbackId];
//        }
//        writeCommandHolder=nil;
//    }



    if(result==XPGWifiError_NONE){
        //基本数据，与发送的数据格式⼀一致
        NSDictionary *sendData = [data valueForKey:@"data"];
        if (sendData.count==0) {
            return;
        }
        //警告
        NSData *alerts = [data valueForKey:@"alerts"];
        //错误
        NSData *faults = [data valueForKey:@"faults"];

        NSNumber *cmd= [[data valueForKey:@"data"] valueForKey:@"cmd"];

        if([cmd isEqualToNumber:[NSNumber numberWithInteger:1]]==YES){
            //    向设备发送控制指令	1
            NSLog(@"\n================向设备发送控制指令====\ndid:%@",did);
            if (writeCommandHolder!=nil) {
                CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:writeCommandHolder.callbackId];
            }
        }else if([cmd isEqualToNumber:[NSNumber numberWithInteger:2]]==YES){
            //    向设备请求设备状态	2
        }else if([cmd isEqualToNumber:[NSNumber numberWithInteger:3]]==YES){
            //    设备返回请求的设备状态	3
        }else if([cmd isEqualToNumber:[NSNumber numberWithInteger:4]]==YES){
            //    设备推送当前设备状态	4
            NSMutableDictionary * d = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       sendData, @"data",
                                       alerts, @"alerts",
                                       faults, @"faults",
                                       did,@"did",
                                       nil];
            if (listenerCommandHolder!=nil) {
                CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:d];
                [pluginResult setKeepCallbackAsBool:true];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:listenerCommandHolder.callbackId];
            }
        }
    }else if(result==XPGWifiError_RAW_DATA_TRANSMIT){
        //透传数据
        NSData *binary=[data valueForKey:@"binary"];
        if (listenerCommandHolder!=nil) {
            CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer:binary];
            [pluginResult setKeepCallbackAsBool:true];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:listenerCommandHolder.callbackId];
        }
    }else if (result == -7) {
        NSLog(@"设备连接已断开 %d",result);
    }

}
/**
 *  回调 获取硬件信息 [device getHardwareInfo];
 *
 *  @param device <#device description#>
 *  @param hwInfo <#hwInfo description#>
 */
- (void)XPGWifiDevice:(XPGWifiDevice *)device didQueryHardwareInfo: (NSDictionary *)hwInfo{
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
    NSLog(@"=========didQueryHardwareInfo=========\n %@",hardWareInfo);
}
/**
 *  cordova 释放内存
 *
 *  @param command []
 */
- (void)dealloc:(CDVInvokedUrlCommand *)command
{
    NSLog(@"//====dealloc...====");
    _currentPairDeviceMacAddress=nil;
    selectedDevices=nil;
     currentUpdateProductKey=nil;
    [XPGWifiSDK sharedInstance].delegate=nil;
    [XPGWifiSDK sharedInstance].delegate=self;
}


- (void)dispose{
    NSLog(@"//====disposed...====");
    _currentPairDeviceMacAddress=nil;
    selectedDevices=nil;
     currentUpdateProductKey=nil;
    [XPGWifiSDK sharedInstance].delegate=nil;
    [XPGWifiSDK sharedInstance].delegate=self;
}

@end
