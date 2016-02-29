/********* gwsdkwrapper.m Cordova Plugin Implementation *******/

#import "gwsdk.h"

@implementation gwsdk

@synthesize commandHolder;
@synthesize _deviceList;

NSString    *_currentPairDeviceMacAddress;
NSInteger currentState;
bool      _debug=true;
NSString *_appId,*_uid,*_token,*_mac;
NSMutableDictionary *_controlObject;
BOOL isDiscoverLock;
XPGWifiDevice *_currentDevice;
NSArray *_memoryDeviceList; //内存中的device列表。

CDVInvokedUrlCommand *listenerCommandHolder;//添加listener的callback
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
    SetDeviceWifiBindDevice=3
};


-(void)pluginInitialize{

}
/**
 *  初始化状态，设置appid
 *
 *  @param command <#command description#>
 */
-(void)init:(CDVInvokedUrlCommand *) command{
    NSString *appId=command.arguments[0];
    if(_appId== nil||![appId isEqualToString:_appId]){

        _appId =appId;
        [XPGWifiSDK startWithAppID:_appId];
    }
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
      NSString *timeout=[command.arguments objectAtIndex:4];
    //新接口 11.24
    if (_debug) {
        NSLog(@"ssid:%@,pwd:%@",command.arguments[2],command.arguments[3]);
    }
    [[XPGWifiSDK  sharedInstance] setDeviceWifi:command.arguments[2] key:command.arguments[3] mode:XPGWifiSDKAirLinkMode softAPSSIDPrefix:nil timeout:[timeout intValue] wifiGAgentType:nil];
}
/**
 *  cordova 配对上网，并且绑定这个设备
 *
 *  @param command ["appid","","ssid","pwd",uid,token,timeout,mode,softApssidPrefix,wifiGAgentType]
 */
-(void)setDeviceWifiBindDevice:(CDVInvokedUrlCommand *)command{

    [self init:command];
    currentState=SetDeviceWifiBindDevice;
    _uid=command.arguments[4];
    _token=command.arguments[5];

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
    NSString *timeout=[command.arguments objectAtIndex:6];
    NSString *mode=[command.arguments objectAtIndex:7];
    //新接口 11.24
    if (_debug) {
        NSLog(@"ssid:%@,pwd:%@ uid:%@ token:%@ timeout:%@ mode:%@ softAPssidPrefix:%@ wifiGAgentType:%@",
              command.arguments[2],
              command.arguments[3],
              command.arguments[4],
              command.arguments[5],
              command.arguments[6],
              command.arguments[7],
              command.arguments[8],
              command.arguments[9]);
    }
//    NSArray *abc = [[NSArray alloc] initWithObjects:@(XPGWifiGAgentTypeHF),nil];
    //todo 如果上一次配对没有结束，下次请求会上报 -46	XPGWifiError_IS_RUNNING	当前事件正在处理 超时以后可以继续配置
    [[XPGWifiSDK  sharedInstance]
     setDeviceWifi:command.arguments[2]
     key:command.arguments[3]
     mode:[mode intValue]
     softAPSSIDPrefix:([command.arguments objectAtIndex:8]==[NSNull null])?nil:command.arguments[8]
     timeout:[timeout intValue]
     wifiGAgentType:nil];//[command.arguments objectAtIndex:9]==[NSNull null]?nil:[command.arguments objectAtIndex:9]];

}
/**
 *  cordova 获取设备列表
 *
 *  @param command [appid,[productkey],uid,token]
 */
-(void)getDeviceList:(CDVInvokedUrlCommand *)command{
    [self init:command];
    currentState=GetDevcieListCode;
    _uid=command.arguments[2];
    _token=command.arguments[3];
    NSLog(@"\n======productkeys%@=====\n",command.arguments[1]);
    [[XPGWifiSDK sharedInstance] getBoundDevices:command.arguments[2] token:command.arguments[3] specialProductKeys:command.arguments[1]];
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
    [[XPGWifiSDK sharedInstance] bindDeviceWithUid:command.arguments[2] token:command.arguments[3] did:command.arguments[4] passCode:command.arguments[5] remark:command.arguments[6]];
}
/**
 *  cordova 控制设备
 *
 *  @param command ["appid",["prodctkeys"],"uid","token","mac","value"]
 */
-(void)deviceControl:(CDVInvokedUrlCommand *)command{
    _uid=command.arguments[2];
    _token=command.arguments[3];
    _mac=command.arguments[4];
    _controlObject=command.arguments[5];//todo: back to value:5

    currentState=ControlCode;
    [self init:command];//初始化设置appid
    [[XPGWifiSDK sharedInstance] getBoundDevices:command.arguments[2] token:command.arguments[3] specialProductKeys:command.arguments[1]];

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
    listenerCommandHolder=command;
}
/**
 *  cordova 停止device的监听
 *
 *  @param command []
 */
-(void)endDeviceListener:(CDVInvokedUrlCommand *)command{
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
    CDVPluginResult  *pluginResult= [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This device does not exist!"];
    for(XPGWifiDevice *device in _deviceList){
        if ([did isEqualToString:device.did]) {
            selectedDevices=device;
            [selectedDevices login:uid token:token];
            sleep(1000); //todo 等待10s，再去判断设备是否登陆成功，原因是didLogin无法接收回调。
            if(selectedDevices.isConnected==YES){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self deviceToDictionary:selectedDevices]];
            }else{
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"device login error!!"];
            }
        }
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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
            [selectedDevices disconnect];
            listenerCommandHolder=nil;
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
    if(selectedDevices!=nil){
        if ([did isEqualToString:selectedDevices.did]) {
            selectedDevices.delegate = self;
            [self cWrite:selectedDevices objecValue:value];
        }else{
            /**
             *  设备不匹配报错
             */
            CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The device does not match!"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }else{
        /**
         *  设备没有连接的时候报错！
         */
        CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The device is not connected!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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
            NSData *data =[gwsdk stringToHex:object];
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
-(NSDictionary *) deviceToDictionary:(XPGWifiDevice *)device{
//    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
//                       device.did, @"did",
//                       //device.ipAddress, @"ipAddress",
//                       device.macAddress, @"macAddress",
//                       device.passcode, @"passcode",
//                       device.productKey, @"productKey",
//                       //device.productName, @"productName",
//                       //device.remark, @"remark",
//                       //device.isConnected, @"isConnected",
//                       //device.isDisabled, @"isDisabled",
//                       //device.isLAN, @"isLAN",
//                       //device.isOnline, @"isOnline",
//                       nil];
//    return d;
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
    NSNumber *isBind=[NSNumber numberWithBool:[device isBind: self.commandHolder.arguments[2]]];

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
-(void) logDevice:(NSString *)map device:(XPGWifiDevice *)device{
    NSLog(@"\n======%@=====\n currentMac:%@ \nmacAddress:%@ \ndid:%@ \npasscode:%@\n",
          map,
          _currentPairDeviceMacAddress,
          device.macAddress,
          device.did,
          device.passcode);

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
        CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
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
-(void)XPGWifiDevice:(XPGWifiDevice *)device didLogin:(int)result{
    if(result == 0 && device){
        selectedDevices=device;
        [self  cWrite:device objecValue:_controlObject];
    }
}
/**
 *  回调  设备配对状态的返回
 *
 *  @param wifiSDK <#wifiSDK description#>
 *  @param device  <#device description#>
 *  @param result  <#result description#>
 */
-(void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didSetDeviceWifi:(XPGWifiDevice *)device result:(int)result{
    if(result == XPGWifiError_NONE) {
        [self logDevice:@"didSetDeviceWifi" device:device];
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
                        [[XPGWifiSDK sharedInstance] bindDeviceWithUid:_uid token:_token did:device.did passCode:nil remark:nil];

                    }else{
                        _currentPairDeviceMacAddress=device.macAddress;
                    }
                }

                break;
            case SetWifiCode:
                //判断mac是否存在
                if ([device macAddress].length > 0||device.macAddress.length > 0) {
                    //判断did是否存在
                    if ( _currentPairDeviceMacAddress==nil&&device.did.length>0) {
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self deviceToDictionary:device]];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
                    }else{
                        _currentPairDeviceMacAddress=device.macAddress;
                    }

                default:
                    break;
                }
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
        switch (currentState) {
            case SetWifiCode:
                if (deviceList.count > 0) {
                    for (XPGWifiDevice *device in deviceList){
                        [self logDevice:@"didDiscovered" device:device];
                        if( [_currentPairDeviceMacAddress isEqualToString:device.macAddress]&&(device.did.length>0)){
                            _currentPairDeviceMacAddress=nil;
                            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self deviceToDictionary:device]];
                            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
                        }
                    }
                }
                break;
            case GetDevcieListCode:
                if ([self hasDone:deviceList]) {
                    if (deviceList.count > 0) {
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
                            NSNumber *isBind=[NSNumber numberWithBool:[device isBind: self.commandHolder.arguments[2]]];

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
//                        _deviceList = nil;
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:jsonArray];
                        //[pluginResult setKeepCallbackAsBool:true];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
                    }else{
                        //deviceList is zero;
                    }
                }
                else{
                    _deviceList = deviceList;
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
                        [self logDevice:@"didDiscovered" device:device];
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

                                [[XPGWifiSDK sharedInstance] bindDeviceWithUid:_uid token:_token did:device.did passCode:nil remark:nil];
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

        //绑定成功
        NSLog(@"\n =========binding success========\n %@",did);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self deviceToDictionary:selectedDevices]];
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
 *  回调 这里判断发送消息是否成功和接收设备上报的数据
 *
 *  @param device <#device description#>
 *  @param data   <#data description#>
 *  @param result <#result description#>
 */
- (void)XPGWifiDevice:(XPGWifiDevice *)device didReceiveData:(NSDictionary *)data result:(int)result{
    //基本数据，与发送的数据格式⼀一致
    NSDictionary *sendData = [data valueForKey:@"data"];
    //警告
    NSArray *alarms = [data valueForKey:@"alarms"];
    //错误
    NSArray *faults = [data valueForKey:@"faults"];
    //透传数据
    NSDictionary *binary = [data valueForKey:@"binary"];
    for (NSString *key in sendData) {
        NSLog(@"\n=====didReceiveData====\n==sendData key: %@ value: %@\n", key, sendData[key]);
    }
     NSLog(@"====didReceiveData===\n 警告:%@ 错误:%@ ",alarms,faults);
    for (NSString *key in binary) {
        NSLog(@"\n=====didReceiveData====\n binary:key: %@ value: %@\n", key, binary[key]);
    }
    if (listenerCommandHolder!=nil) {
        CDVPluginResult  *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:binary];
        [pluginResult setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:listenerCommandHolder.callbackId];
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
    [XPGWifiSDK sharedInstance].delegate=nil;
    [XPGWifiSDK sharedInstance].delegate=self;
}


- (void)dispose{
    NSLog(@"//====disposed...====");
    _currentPairDeviceMacAddress=nil;
    selectedDevices=nil;
    [XPGWifiSDK sharedInstance].delegate=nil;
    [XPGWifiSDK sharedInstance].delegate=self;
}

@end
