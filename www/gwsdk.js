var exec = require('cordova/exec');
var productToArray = function (products) {
    var proArr = [];
    if (products instanceof Array)
        proArr = productKey;
    else
        proArr.push(products);
    return proArr;
}
/**
 *  cordova 配对设备上网
 *
 *  @param command [appid,"",ssid,pwd,timeout]
 */
exports.setDeviceWifi = function (appid, productKey, wifiSSID, wifiKey, timeout, success, error) {
    exec(success, error, "gwsdk", "setDeviceWifi", [appid, productToArray(productKey), wifiSSID, wifiKey, timeout ? timeout : 60,]);
};
/**
 * 配对并且绑定设备
 * todo ios下面: 如果同一个设备,第一次被配对上网,再去配对第二次会出现配对失败(error HTTP response error format.),再次配对才可以成功
 * @param appid
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
exports.setDeviceWifiBindDevice = function (appid, productKey, wifiSSID, wifiKey, uid, token, timeout, mode, softAPSSIDPrefix, wifiGAgentType, success, error) {
    exec(success, error, "gwsdk", "setDeviceWifiBindDevice", [
        appid,
        productToArray(productKey),
        wifiSSID,
        wifiKey,
        uid,
        token,
        timeout ? timeout : 60,
        mode ? mode : XPGConfigureMode.XPGWifiSDKAirLinkMode,
        softAPSSIDPrefix,
        wifiGAgentType
    ]);
};
/**
 *  cordova 获取设备列表
 *
 *  @param command [appid,[productkey],uid,token]
 */
exports.getDeviceList = function (appid, productKey, uid, token, success, error) {
    exec(success, error, "gwsdk", "getDeviceList", [appid, productToArray(productKey), uid, token]);
};
/**
 *  cordova 绑定设备
 *
 *  @param command ["appid","uid","token","did","passcode","remark"]
 */
exports.deviceBinding = function (appid, uid, token, did, passcode, remark) {
    exec(success, error, "gwsdk", "deviceBinding", [appid, uid, token, did, passcode, remark])
};
/**
 *  cordova 控制设备
 *
 *  @param command ["appid",["prodctkeys"],"uid","token","mac","value"]
 */
exports.deviceControl = function (appid, productKey, uid, token, mac, value, success, error) {
    exec(success, error, "gwsdk", "deviceControl", [appid, productToArray(productKey), uid, token, mac, value]);
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
exports.startDevcieListener = function (success, error) {
    exec(success, error, "gwsdk", "startDevcieListener", []);
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
 *  cordova 释放内存
 *
 *  @param command []
 */
exports.deAlloc = function (success, error) {
    exec(success, error, "gwsdk", "dealloc", []);
};
/**
 XPGConfigureMode枚举，描述SDK支持的设备配置方式
 */
XPGConfigureMode = {
    /**
     SoftAP配置模式
     */
    XPGWifiSDKSoftAPMode: 1,
    /**
     AirLink配置模式
     */
    XPGWifiSDKAirLinkMode: 2,
};
/**
 XPGWifiGAgentType枚举，描述SDK支持的Wifi模组类型
 */
XPGWifiGAgentType = {
    /**
     MXCHIP 模组（庆科3162）
     */
    XPGWifiGAgentTypeMXCHIP: 0,

    /**
     HF 模组（汉枫）
     */
    XPGWifiGAgentTypeHF: 1,

    /**
     RTK 模组（RealTek）
     */
    XPGWifiGAgentTypeRTK: 2,

    /**
     WM 模组（联盛德）
     */
    XPGWifiGAgentTypeWM: 3,

    /**
     ESP 模组（乐鑫）
     */
    XPGWifiGAgentTypeESP: 4,

    /**
     QCA 模组（高通）
     */
    XPGWifiGAgentTypeQCA: 5,

    /**
     TI 模组（TI）
     */
    XPGWifiGAgentTypeTI: 6,

    /**
     FSK 模组（宇音天下）
     */
    XPGWifiGAgentTypeFSK: 7,

    /**
     MXCHIP3.x 协议 模组（庆科3088或5088）
     */
    XPGWifiGAgentTypeMXCHIP3: 8,

    /**
     BL 模组（古北）
     */
    XPGWifiGAgentTypeBL: 9
};