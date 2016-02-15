var exec = require('cordova/exec');

exports.setDeviceWifi = function (appid,productKey,wifiSSID,wifiKey, success, error) {
    exec(success, error, "gwsdk", "setDeviceWifi", [appid,productKey,wifiSSID,wifiKey]);
};
exports.setDeviceWifiBindDevice = function (appid,productKey,wifiSSID,wifiKey,uid,token ,success, error) {
    var proArr=[];
    if(productKey instanceof Array)
        proArr=productKey;
    else
      proArr.push(productKey);

    exec(success, error, "gwsdk", "setDeviceWifiBindDevice", [appid,proArr,wifiSSID,wifiKey,uid,token]);
};
exports.getDeviceList = function (appid,productKey,uid,token, success, error) {
    exec(success, error, "gwsdk", "getDeviceList", [appid,productKey,uid,token]);
};
exports.deviceControl = function (appid,productKey,uid,token,mac,value, success, error) {
    exec(success, error, "gwsdk", "deviceControl", [appid,productKey,uid,token,mac,value]);
};

exports.deAlloc = function(success, error){
    exec(success, error, "gwsdk", "dealloc",[]);
};
