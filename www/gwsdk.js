var exec = require('cordova/exec');
var checkProduct = function (products) {
    var proArr = [];
    if (products) {
        if (products instanceof Array)
            proArr = products;
        else
            proArr.push(products);
    }
    return proArr;
};
var checkWifiGAgentType = function (wifiGAgentTypes) {
    var wifiGAgentTypeArr = [];
    if (wifiGAgentTypes) {
        if (wifiGAgentTypes instanceof Array)
            wifiGAgentTypeArr = wifiGAgentTypes;
        else
            wifiGAgentTypeArr.push(wifiGAgentTypes);
    }
    return wifiGAgentTypeArr;
};
/**
 *  cordova 配对设备上网
 *
 *  @param command ["",ssid,pwd,timeout]
 */
exports.setDeviceOnboarding = function (wifiSSID, wifiKey, mode, timeout, softAPSSIDPrefix, wifiGAgentType, success, error) {
    exec(success, error, "gwsdk", "setDeviceOnboarding", [wifiSSID, wifiKey, mode,
        timeout ? timeout : 60, softAPSSIDPrefix, checkWifiGAgentType(wifiGAgentType)
    ]);
};
/**
 * 配对并且绑定设备
 * todo ios下面: 如果同一个设备,第一次被配对上网,再去配对第二次会出现配对失败(error HTTP response error format.),再次配对才可以成功
 * @param productKey
 * @param wifiSSID
 * @param wifiKey
 * @param uid
 * @param token
 * @param timeout   默认: 60s
 * @param mode      默认: AirLink
 * @param softAPSSIDPrefix
 SoftAPMode模式下SoftAP的SSID前缀或全名（
 XPGWifiSDK以此判断手机当前是否连上了SoftAP，AirLink配置时该参数无意义，
 传nil即可）
 * @param wifiGAgentType types 配置的wifi模组类型列表，存放NSNumber对象，SDK默认同时发送庆科和汉枫模组配置包；
 *        SoftAPMode模式下该参数无意义。types为nil，SDK按照默认处理。如果只想配置庆科模组，types中请加入@XPGWifiGAgentTypeMXCHIP类；
 *        如果只想配置汉枫模组，types中请加入@XPGWifiGAgentTypeHF；如果希望多种模组配置包同时传，
 *        可以把对应类型都加入到types中。XPGWifiGAgentType枚举类型定义SDK支持的所有模组类型。
 * @param success object
 {
   did: "Zt8Vw8kVpDYyXfNGuEyGmK",
   passcode: "QEKASRXAYP",
   productKey: "36d6b9a11d374a1db939f6b8c9d7bf95",
   macAddress: "C893464A06BD"
 }
 * @param error string
 */
exports.setDeviceWifiBindDevice = function (productKey, wifiSSID, wifiKey, uid, token, timeout, mode, softAPSSIDPrefix, wifiGAgentType, success, error) {
    exec(success, error, "gwsdk", "setDeviceWifiBindDevice", [
        checkProduct(productKey),
        wifiSSID,
        wifiKey,
        uid,
        token,
        timeout ? timeout : 60,
        mode ? mode : XPGConfigureMode.XPGWifiSDKAirLinkMode,
        softAPSSIDPrefix ? softAPSSIDPrefix : null,
        checkWifiGAgentType(wifiGAgentType)
    ]);
};
/**
 *  cordova 获取设备列表
 *
 *  @param command [[productkey],uid,token]
 */
exports.getDeviceList = function (productKey, uid, token, success, error) {
    exec(success, error, "gwsdk", "getDeviceList", [checkProduct(productKey), uid, token]);
};
/**
 * 开启固定间隔 获取设备列表
 * @param productKey
 * @param uid
 * @param token
 * @param interval
 * @param success
 * @param error
 */
exports.startGetDeviceList = function (productKey, uid, token, interval, success, error) {
    exec(success, error, "gwsdk", "startGetDeviceList", [checkProduct(productKey), uid, token, interval]);
};
exports.stopGetDeviceList = function (success, error) {
    exec(success, error, "gwsdk", "stopGetDeviceList", []);
};
/**
 *  cordova 绑定设备
 *
 *  @param command ["uid","token","did","passcode","remark"]
 */
exports.deviceBinding = function (uid, token, did, passcode, remark, success, error) {
    exec(success, error, "gwsdk", "deviceBinding", [uid, token, did, passcode, remark])
};
/**
 *  cordova 解绑设备
 *
 *  @param command ["uid","token","did","passcode","remark"]
 */
exports.unbindDevice = function (uid, token, did, passcode, success, error) {
    exec(success, error, "gwsdk", "unbindDevice", [uid, token, did, passcode])
};
/**
 *  cordova 控制设备
 *
 *  @param command [["prodctkeys"],"uid","token","mac","value"]
 */
exports.deviceControl = function (productKey, uid, token, mac, value, success, error) {
    exec(success, error, "gwsdk", "deviceControl", [checkProduct(productKey), uid, token, mac, value]);
};
/**
 * cordova 获取ssid列表
 *
 *  @param command []
 */
exports.getWifiSSIDList = function (success, error) {
    exec(success, error, "gwsdk", "getWifiSSIDList", []);
};
/**
 *  cordova 开始device的监听
 *
 *  @param command []
 */
exports.startDeviceListener = function (success, error) {
    exec(success, error, "gwsdk", "startDeviceListener", []);
};
/**
 *  cordova 停止device的监听
 *
 *  @param command []
 */
exports.stopDeviceListener = function (success, error) {
    exec(success, error, "gwsdk", "stopDeviceListener", []);
};
/**
 * cordova 连接设备
 *
 *  @param command ["uid","token","did"]
 */
exports.connect = function (uid, token, did, success, error) {
    exec(success, error, "gwsdk", "connect", [uid, token, did]);
};
/**
 * cordova 断开连接
 *
 *  @param command ["did"]
 */
exports.disconnect = function (did, success, error) {
    exec(success, error, "gwsdk", "disconnect", [did]);
};
/**
 * cordova 发送控制命令
 *
 *  @param command ["did","value"]
 */
exports.write = function (did, value, success, error) {
    exec(success, error, "gwsdk", "write", [did, value]);
};
/**
 * cordova 获取设备硬件信息
 *
 *  @param command ["did","value"]
 */
exports.getHardwareInfo = function (did, success, error) {
    exec(success, error, "gwsdk", "getHardwareInfo", [did]);
};
/**
 * cordova 下载产品配置文件 配置文件，是定义 APP 与指定设备通信的规则
 * @param productKey
 * @param success
 * @param error
 */
exports.updateDeviceFromServer = function (productKey, success, error) {
    console.error("此接口已废弃!");
    // exec(success, error, "gwsdk", "updateDeviceFromServer", [productKey]);
};
/**
 *  cordova 释放内存
 *
 *  @param command []
 */
exports.deAlloc = function (success, error) {
    exec(success, error, "gwsdk", "dealloc", []);
};

/*
 GizWifiConfigureMode枚举，描述SDK支持的设备配置方式
 */
GizWifiConfigureMode = {
    /*
     SoftAP配置模式
     */
    GizWifiSoftAP: 0,
    /*
     AirLink配置模式
     */
    GizWifiAirLink: 1,
};
/*
 GizWifiGAgentType 模组类型 ，描述SDK支持的Wifi模组类型
 */
GizWifiGAgentType = {
    /*
     庆科3162模组
     */
    GizGAgentMXCHIP: 0,
    /*
     汉枫模组
     */
    GizGAgentHF: 1,
    /*
     瑞昱模组
     */
    GizGAgentRTK: 2,
    /*
     联盛德模组
     */
    GizGAgentWM: 3,
    /*
     乐鑫模组
     */
    GizGAgentESP: 4,
    /*
     高通模组
     */
    GizGAgentQCA: 5,
    /*
     TI 模组
     */
    GizGAgentTI: 6,
    /*
     宇音天下模组
     */
    GizGAgentFSK: 7,
    /*
     庆科V3
     */
    GizGAgentMXCHIP3: 8,
    /*
     古北模组
     */
    GizGAgentBL: 9
};
