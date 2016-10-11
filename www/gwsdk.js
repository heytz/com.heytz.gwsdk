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
 * @param wifiSSID
 * @param wifiKey
 * @param mode
 * @param timeout       默认 60秒
 * @param softAPSSIDPrefix
 * @param wifiGAgentType
 * @param success
 * @param error
 */
exports.setDeviceOnboarding = function (wifiSSID, wifiKey, mode, timeout, softAPSSIDPrefix, wifiGAgentType, success, error) {
    exec(success, error, "gwsdk", "setDeviceOnboarding", [wifiSSID, wifiKey, mode,
        timeout ? timeout : 60, softAPSSIDPrefix, checkWifiGAgentType(wifiGAgentType)
    ]);
};
exports.setDeviceOnboardingAndBindDevice = function (wifiSSID, wifiKey, mode, timeout, softAPSSIDPrefix, wifiGAgentType,
                                                     uid, token, productSecret, success, error) {
    exec(success, error, "gwsdk", "setDeviceOnboardingAndBindDevice", [wifiSSID, wifiKey, mode,
        timeout ? timeout : 60, softAPSSIDPrefix, checkWifiGAgentType(wifiGAgentType),
        uid, token, productSecret
    ]);
};
/**
 *  cordova 获取设备列表
 *
 *  @param command [[productkey],uid,token]
 */
exports.getBoundDevices = function (uid, token, productKey, success, error) {
    exec(success, error, "gwsdk", "getBoundDevices", [uid, token, checkProduct(productKey)]);
};
exports.bindRemoteDevice = function (uid, token, mac, productKey, productSecret, success, error) {
    exec(success, error, "gwsdk", "bindRemoteDevice", [uid, token, mac, productKey, productSecret])
};
/**
 *
 * @param did
 * @param remark
 * @param alias
 * @param success
 * @param error
 */
exports.setCustomInfo = function (did, remark, alias, success, error) {
    exec(success, error, "gwsdk", "setCustomInfo", [did, remark, alias])
};

/**
 *  cordova 解绑设备
 *
 *  @param command ["uid","token","did","passcode","remark"]
 */
exports.unbindDevice = function (uid, token, did, success, error) {
    exec(success, error, "gwsdk", "unbindDevice", [uid, token, did])
};
/**
 * cordova 订阅设备
 * @param did
 * @param subState
 * @param success
 * @param error
 */
exports.setSubscribe = function (did, subState, success, error) {
    exec(success, error, "gwsdk", "setSubscribe", [did, subState])
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
/*
 GizWifiDeviceNetStatus 枚举，描述 SDK 支持的设备网路状态
 */
GizWifiDeviceNetStatus = {
    /*
     离线状态
     */
    GizDeviceOffline: 0,
    /*
     在线状态
     */
    GizDeviceOnline: 1,
    /*
     可控状态
     */
    GizDeviceControlled: 2,
    GizDeviceUnavailable: 3,
};