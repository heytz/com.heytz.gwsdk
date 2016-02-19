/********* gwsdkwrapper.m Cordova Plugin Implementation *******/

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

@property (strong,nonatomic) CDVInvokedUrlCommand * commandHolder;
@property (strong, nonatomic) NSArray * _deviceList;

@end

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
int attempts;//尝试次数
//操作状态的枚举
typedef NS_ENUM(NSInteger, GwsdkStateCode) {
    //以下是枚举成员
    SetWifiCode = 0,            //只配对设备
    GetDevcieListCode = 1,      //发现设备列表
    ControlCode = 2,            //控制设备
    SetDeviceWifiBindDevice=3   //配对设备并且绑定设备
};



-(void)pluginInitialize{

}

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
/*
 *
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
    NSArray *abc = [[NSArray alloc] initWithObjects:@(XPGWifiGAgentTypeHF),nil];
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
 * @brief 回调接口，返回发现设备的结果
 * @param deviceList：为 XPGWifiDevice* 的集合
 * @param result：0为成功，其他失败
 * @see 触发函数：[XPGWifiSDK getBoundDevicesWithUid:token:specialProductKeys:]
 */
-(void)getDeviceList:(CDVInvokedUrlCommand *)command{
    [self init:command];
    currentState=GetDevcieListCode;
    NSLog(@"\n======productkeys%@=====\n",command.arguments[1]);
    [[XPGWifiSDK sharedInstance] getBoundDevices:command.arguments[2] token:command.arguments[3] specialProductKeys:command.arguments[1]];
}
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
-(void)deviceControl:(CDVInvokedUrlCommand *)command{
    _uid=command.arguments[2];
    _token=command.arguments[3];
    _mac=command.arguments[4];
    _controlObject=command.arguments[5];//todo: back to value:5

    currentState=ControlCode;
    [self init:command];//初始化设置appid
    [[XPGWifiSDK sharedInstance] getBoundDevices:command.arguments[2] token:command.arguments[3] specialProductKeys:command.arguments[1]];

}

-(void)deviceBingding:(NSString *)did uid:(NSString *)uid token:(NSString *)token passcode:(NSString *)passcode remark:(NSString *)remark {

    [[XPGWifiSDK sharedInstance] bindDeviceWithUid:_uid token:_token did:did passCode:passcode remark:remark];
}
/*!
 login device 的回调
 判断这个device是否登录成功，如果成功则发送控制命令
 !*/
- (void)XPGWifiDevice:(XPGWifiDevice *)device didLogin:(int)result
{
    if(result == 0 && device){
        [self  cWrite:device];
    }
}
/**
 发送控制命令
 */
-(void) cWrite:(XPGWifiDevice *)device{
    NSDictionary *data=nil;
    NSMutableDictionary * data1 = [NSMutableDictionary dictionaryWithDictionary: _controlObject];
    @try {
        NSEnumerator *enumerator1= [_controlObject keyEnumerator];
        id key=[enumerator1 nextObject];
        while (key) {
            NSString *object=[_controlObject objectForKey:key];
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
 string 转换为Data
 **/
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
 * XPGWifiDevice 转换为dictionary
 **/
-(NSDictionary *) deviceToDictionary:(XPGWifiDevice *)device{
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                       device.did, @"did",
                       //device.ipAddress, @"ipAddress",
                       device.macAddress, @"macAddress",
                       device.passcode, @"passcode",
                       device.productKey, @"productKey",
                       //device.productName, @"productName",
                       //device.remark, @"remark",
                       //device.isConnected, @"isConnected",
                       //device.isDisabled, @"isDisabled",
                       //device.isLAN, @"isLAN",
                       //device.isOnline, @"isOnline",
                       nil];
    return d;
}
/**
 *打印device的log
 **/
-(void) logDevice:(NSString *)map device:(XPGWifiDevice *)device{
    NSLog(@"\n======%@=====\n currentMac:%@ \nmacAddress:%@ \ndid:%@ \npasscode:%@\n",
          map,
          _currentPairDeviceMacAddress,
          device.macAddress,
          device.did,
          device.passcode);

}
/**
 验证devicelist是否匹配
 **/
- (BOOL)hasDone:(NSArray *)devicList{
    if(_deviceList == nil) return false;
    return (_deviceList.count == devicList.count);
}
/**
 * 配置事件 回调接口
 **/
-(void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didSetDeviceWifi:(XPGWifiDevice *)device result:(int)result{
    if(result == XPGWifiError_NONE) {
        [self logDevice:@"didSetDeviceWifi" device:device];
        switch (currentState) {
            case SetDeviceWifiBindDevice:
                //判断mac是否存在
                if ([device macAddress].length > 0||device.macAddress.length > 0) {
                    //判断did是否存在
                    if ( _currentPairDeviceMacAddress==nil&&device.did.length>0) {
                        _currentDevice=device;

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
 ＊ 搜索设备 回调接口
 **/
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
                            NSString * did=device.did;
                            NSString * mac = device.macAddress;
                            NSString * isOnline =  device.isOnline ? @"1" :@"0";
                            NSString * isLAN = device.isLAN ? @"1" : @"0";
                            NSString * isDisabled = device.isDisabled ? @"1" : @"0";
                            NSString * isConnected = device.isConnected ? @"1" : @"0";
                            NSString * isBind = [device isBind: self.commandHolder.arguments[3]] ? @"1" : @"0";
                            NSMutableDictionary * d = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                       did, @"did",
                                                       // device.ipAddress, @"ipAddress",
                                                       mac, @"macAddress",
                                                       device.passcode, @"passcode",
                                                       device.productKey, @"productKey",
                                                       // device.productName, @"productName",
                                                       // device.remark, @"remark",
                                                       //device.ui, @"ui",
                                                       isConnected, @"isConnected",
                                                       isDisabled, @"isDisabled",
                                                       isLAN, @"isLAN",
                                                       isOnline, @"isOnline",
                                                       isBind, @"isBind",
                                                       nil];
                            [jsonArray addObject:d];
                        }
                        _deviceList = nil;
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

                        //_deviceList=deviceList;
                        //                        for (int i=0; i<[deviceList count]; i++) {
                        //                            // NSLog(@"%@",[deviceList[i] macAddress]);
                        //                        }

                        for (int i=0; i<[deviceList count]; i++) {
                            NSLog(@"=======%@",[deviceList[i] macAddress]);
                            XPGWifiDevice *device = deviceList[i];
                            //[[deviceList[i] macAddress]]


                            if ([device.macAddress isEqualToString: [_mac uppercaseString]]) {
                                isDiscoverLock=false;//设置锁定状态
                                if (device.isConnected) {
                                    [self cWrite:device];
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
                            _currentDevice=device;
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
 * 绑定事件 回调接口
 **/
-(void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didBindDevice:(NSString *)did error:(NSNumber *)error errorMessage:(NSString *)errorMessage{
    if([error intValue] == XPGWifiError_NONE){

        //绑定成功
        NSLog(@"\n =========binding success========\n %@",did);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self deviceToDictionary:_currentDevice]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHolder.callbackId];
        //清空缓存
        _currentDevice=nil;
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
            _currentDevice=nil;
            _currentPairDeviceMacAddress=nil;
        }
    }


}

/**
 * write 的回调 这里判断发送消息是否成功
 **/
- (void)XPGWifiDevice:(XPGWifiDevice *)device didReceiveData:(NSDictionary *)data result:(int)result
{
    //基本数据，与发送的数据格式⼀一致
    NSDictionary *_data = [data valueForKey:@"data"];
    NSMutableArray *rows = [NSMutableArray array];



    //警告
    NSArray *alarms = [data valueForKey:@"alarms"];

    //错误
    NSArray *faults = [data valueForKey:@"faults"];

    //透传数据
    NSDictionary *binary = [data valueForKey:@"binary"];


}

- (void)dealloc:(CDVInvokedUrlCommand *)command
{
    NSLog(@"//====dealloc...====");
    _currentPairDeviceMacAddress=nil;
    _currentDevice=nil;
    [XPGWifiSDK sharedInstance].delegate=nil;
    [XPGWifiSDK sharedInstance].delegate=self;
}


- (void)dispose{
    NSLog(@"//====disposed...====");
    _currentPairDeviceMacAddress=nil;
    _currentDevice=nil;
    [XPGWifiSDK sharedInstance].delegate=nil;
    [XPGWifiSDK sharedInstance].delegate=self;
}

@end
