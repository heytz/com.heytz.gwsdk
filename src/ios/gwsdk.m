/********* gwsdkwrapper.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <XPGWifiSDK/XPGWifiSDK.h>

@interface gwsdk : CDVPlugin<XPGWifiDeviceDelegate,XPGWifiSDKDelegate> {
    // Member variables go here.
}

-(void)setDeviceWifi:(CDVInvokedUrlCommand *)command;
-(void)getDeviceList:(CDVInvokedUrlCommand *)command;
-(void)deviceControl:(CDVInvokedUrlCommand *)command;
-(void)dealloc:(CDVInvokedUrlCommand *)command;

@property (strong,nonatomic) CDVInvokedUrlCommand * commandHolder;
@property (strong, nonatomic) NSArray * _deviceList;

@end

@implementation gwsdk

@synthesize commandHolder;
@synthesize _deviceList;

NSString * productKey;
NSString    *_currentPairDeviceMacAddress;
NSInteger currentState;
bool      _debug=true;
NSString * _appId,*_uid,*_token,*_mac;
NSMutableDictionary *_controlObject;
XPGWifiSDK * _shareInstance;
BOOL isDiscoverLock;

//操作状态的枚举
typedef NS_ENUM(NSInteger, GwsdkStateCode) {
    //以下是枚举成员
    SetWifiCode = 0,
    GetDevcieListCode = 1,
    ControlCode = 2
};



-(void)pluginInitialize{

}

-(void)init:(CDVInvokedUrlCommand *) command{
    if(_appId== nil){
        _appId = command.arguments[0];
        [XPGWifiSDK startWithAppID:_appId];
    }
    if(!([XPGWifiSDK sharedInstance].delegate)){
        [XPGWifiSDK sharedInstance].delegate = self;
    }

   self.commandHolder = command;
}
/*
 *
 */
-(void)setDeviceWifi:(CDVInvokedUrlCommand *)command{

    [self init:command];
    currentState=SetWifiCode;
    _currentPairDeviceMacAddress=nil;

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
    //新接口 11.24
    NSLog(@"ssid:@s,pwd:@s",command.arguments[2],command.arguments[3]);
    [[XPGWifiSDK  sharedInstance] setDeviceWifi:command.arguments[2] key:command.arguments[3] mode:XPGWifiSDKAirLinkMode softAPSSIDPrefix:nil timeout:180 wifiGAgentType:nil];
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

    isDiscoverLock = true;
    [[XPGWifiSDK sharedInstance] getBoundDevicesWithUid:command.arguments[3] token:command.arguments[4] specialProductKeys:command.arguments[1], nil];
}

-(void)deviceControl:(CDVInvokedUrlCommand *)command{

    productKey=command.arguments[1];
    _uid=command.arguments[2];
    _token=command.arguments[3];
    _mac=command.arguments[4];
    _controlObject=command.arguments[5];//todo: back to value:5
    isDiscoverLock=true;
    currentState=ControlCode;
    [self init:command];//初始化设置appid

    /**
     * @brief 获取绑定设备及本地设备列表
     * @param uid：登录成功后得到的uid
     * @param token：登录成功后得到的token
     * @param specialProductKey：指定待筛选设备的产品标识（获取或搜索到未指定设备产品标识的设备将其过滤，指定Nil则不过滤）
     * @see 对应的回调接口：[XPGWifiSDK XPGWifiSDK:didDiscovered:result:]
     */
    [[XPGWifiSDK sharedInstance] getBoundDevicesWithUid:_uid token:_token specialProductKeys:nil,nil];
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



- (BOOL)hasDone:(NSArray *)devicList{
    if(_deviceList == nil) return false;
    return (_deviceList.count == devicList.count);
}
/*
 * 回调接口
 *
 */
-(void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didSetDeviceWifi:(XPGWifiDevice *)device result:(int)result{


                if(result == XPGWifiError_NONE  && [device macAddress].length > 0) {
//                    if (_debug) {
//                    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
//                                       device.did, @"did",
//                                       device.ipAddress, @"ipAddress",
//                                       [device macAddress], @"macAddress",
//                                       device.passcode, @"passcode",
//                                       device.productKey, @"productKey",
//                                       device.productName, @"productName",
//                                       device.remark, @"remark",
//                                       device.isConnected, @"isConnected",
//                                       device.isDisabled, @"isDisabled",
//                                       device.isLAN, @"isLAN",
//                                       device.isOnline, @"isOnline",
//                                       @"",@"error",
//                                       nil];
//                    for (NSString *key in d) {
//                        NSLog(@"=======success [device macAddress] key: %@ value: %@", key, d[key]);
//                    }
//                    }
                    _currentPairDeviceMacAddress=device.macAddress;

                }else if(result == XPGWifiError_NONE  && device.macAddress.length > 0) {
//                    if (_debug) {
//
//                    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
//                                       device.did, @"did",
//                                       device.ipAddress, @"ipAddress",
//                                       device.macAddress, @"macAddress",
//                                       device.passcode, @"passcode",
//                                       device.productKey, @"productKey",
//                                       device.productName, @"productName",
//                                       device.remark, @"remark",
//                                       device.isConnected, @"isConnected",
//                                       device.isDisabled, @"isDisabled",
//                                       device.isLAN, @"isLAN",
//                                       device.isOnline, @"isOnline",
//                                       @"",@"error",
//                                       nil];
//                    for (NSString *key in d) {
//                        NSLog(@"=======success device.macAddress key: %@ value: %@", key, d[key]);
//                    }
//                    }
                    _currentPairDeviceMacAddress=device.macAddress;

                }else if(result == XPGWifiError_CONFIGURE_TIMEOUT){
                    if (_debug)
                        NSLog(@"======timeout=====");
                    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:self.commandHolder.callbackId];
                }else {
                    if (_debug){
                    NSLog(@"======error code:===%d", result);
                    NSLog(@"======did===%@", device.did);
                    }
                }
             }

-(void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didDiscovered:(NSArray *)deviceList result:(int)result{
    if(result==0){
        switch (currentState) {
            case SetWifiCode:
                if (deviceList.count > 0) {
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
                if(_debug){
                for (NSString *key in d) {
                    NSLog(@"=======didDiscovered:success key: %@ value: %@", key, d[key]);
                }
                }

                _currentPairDeviceMacAddress=nil;
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:d];
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
                                                       // device.passcode, @"passcode",
                                                       // device.productKey, @"productKey",
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
                        for (int i=0; i<[deviceList count]; i++) {
                            // NSLog(@"%@",[deviceList[i] macAddress]);
                        }

                        for (int i=0; i<[deviceList count]; i++) {
                            NSLog(@"=======%@",[deviceList[i] macAddress]);
                            XPGWifiDevice *device = deviceList[i];
                            //[[deviceList[i] macAddress]]


                            if ([device.macAddress isEqualToString: [_mac uppercaseString]]) {
                                isDiscoverLock=false;//设置锁定状态
                                if (device.isConnected) {
                                    [self cWrite:deviceList[i]];
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
            default:
                break;
        }
    }else{
        //error
    }


}

/**
 write 的回调，
 这里判断发送消息是否成功
 **/
- (void)XPGWifiDevice:(XPGWifiDevice *)device didReceiveData:(NSDictionary *)data result:(int)result
{
    /**
     * 数据部分
     */
    NSDictionary *_data = [data valueForKey:@"data"];
    NSMutableArray *rows = [NSMutableArray array];

}

- (void)dealloc:(CDVInvokedUrlCommand *)command
{
    NSLog(@"//====dealloc...====");
    _currentPairDeviceMacAddress=nil;
    [XPGWifiSDK sharedInstance].delegate=nil;
    [XPGWifiSDK sharedInstance].delegate=self;
}


- (void)dispose{
    NSLog(@"//====disposed...====");
    _currentPairDeviceMacAddress=nil;
    [XPGWifiSDK sharedInstance].delegate=nil;
    [XPGWifiSDK sharedInstance].delegate=self;
}

@end
