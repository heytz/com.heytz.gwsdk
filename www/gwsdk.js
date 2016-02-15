var exec = require('cordova/exec');
var productToArray = function (products) {
    var proArr = [];
    if (products instanceof Array)
        proArr = productKey;
    else
        proArr.push(products);
    return proArr;
}
exports.setDeviceWifi = function (appid, productKey, wifiSSID, wifiKey, success, error) {
    exec(success, error, "gwsdk", "setDeviceWifi", [appid, productToArray(productKey), wifiSSID, wifiKey]);
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
 * @param success object
 {
   did: "Zt8Vw8kVpDYyXfNGuEyGmK",
   passcode: "QEKASRXAYP",
   productKey: "36d6b9a11d374a1db939f6b8c9d7bf95",
   macAddress: "C893464A06BD"
 }
 * @param error string
 */
exports.setDeviceWifiBindDevice = function (appid, productKey, wifiSSID, wifiKey, uid, token, success, error) {
    exec(success, error, "gwsdk", "setDeviceWifiBindDevice", [appid, productToArray(productKey), wifiSSID, wifiKey, uid, token]);
};
exports.getDeviceList = function (appid, productKey, uid, token, success, error) {
    exec(success, error, "gwsdk", "getDeviceList", [appid, productToArray(productKey), uid, token]);
};
exports.deviceControl = function (appid, productKey, uid, token, mac, value, success, error) {
    exec(success, error, "gwsdk", "deviceControl", [appid, productToArray(productKey), uid, token, mac, value]);
};

exports.deAlloc = function (success, error) {
    exec(success, error, "gwsdk", "dealloc", []);
};
