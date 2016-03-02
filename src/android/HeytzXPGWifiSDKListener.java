package com.heytz.gwsdk;

import android.util.Log;
import com.xtremeprog.xpgconnect.*;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Iterator;
import java.util.List;

/**
 * Created by Alben on 16-3-2.
 */
public class HeytzXPGWifiSDKListener extends XPGWifiSDKListener {

    private HeytzApp app;

    //private XPGWifiDevice _currentDevice;

    private CallbackContext callbackContext;

    private int attempts;

    private Object controlObject;           //用户控制的值.

    private boolean controlState;

    //private XPGWifiDevice currentDevice;     //当前缓存中的device


    @Override
    public void didBindDevice(int result, String errorMessage, String did) {
        if (result == XPGWifiErrorCode.XPGWifiError_NONE) {
            Log.e("\n===binding success===\n", errorMessage + did);

            //绑定设备成功，登录设备进行控制
            PluginResult pr = new PluginResult(PluginResult.Status.OK, HeytzUtil.deviceToJsonObject(app.getCurrentDevice()));
            callbackContext.sendPluginResult(pr);
            //清空内存中的Mac
            app.setMac(null); //_currentDeviceMac = null;
            app.setCurrentDevice(null);
        } else {
            Log.e("\n===binding error===\n", errorMessage);
            if (attempts > 0) {
                controlState = true;
                --attempts;
            } else {
                //清空内存中的Mac
                app.setMac(null); //t_currentDeviceMac = null;
                app.setCurrentDevice(null);
                //绑定设备失败，弹出错误信息
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, errorMessage);
                callbackContext.sendPluginResult(pr);
            }
        }

    }


    /**
     * wifi配对的回调,这个回调不保证可以获取到设备的did
     * 所以我们拿到这个设备的MacAddress,去didDiscovered 等待设备详细的信息反馈,
     *
     * @param error
     * @param device
     */
    @Override
    public void didSetDeviceWifi(int error, XPGWifiDevice device) {
        if (error == XPGWifiErrorCode.XPGWifiError_NONE && device.getMacAddress().length() > 0) {
            HeytzUtil.logDevice("\n======didsetDeviceWifi======\n", device);
            String currentDeviceMac = app.getMac();
            switch (GwsdkStateCode.getCurrentState()) {
                case GwsdkStateCode.SetWifiCode:
                    //如果存在did那么就直接返回成功,现在测试只会返回一次
//                        if (_currentDeviceMac == null && device.getDid().length() > 0) {
                    if (currentDeviceMac == null && device.getDid().length() > 0) {
                        sendDeviceInfo(device);
                    } else {//否则获取配对到的设备地址,去didDiscovered 等待设备did的信息
                        app.setMac(device.getMacAddress()); //_currentDeviceMac = device.getMacAddress();
                    }
                    break;
                case GwsdkStateCode.SetDeviceWifiBindDevice:
                    //如果存在did那么就直接返回成功,现在测试只会返回一次
                    //if (_currentDeviceMac == null && device.getDid().length() > 0) {
                    if (currentDeviceMac == null && device.getDid().length() > 0) {
                        //XPGWifiSDK.sharedInstance().bindDevice(app.getUid(), _token, device.getDid(), null, null);
                        XPGWifiSDK.sharedInstance().bindDevice(app.getUid(), app.getToken(), device.getDid(), null, null);

                        //XPGWifiSDK.sharedInstance().bindDevice(_uid, _token, device.getDid(), null, null);
                    } else {//否则获取配对到的设备地址,去didDiscovered 等待设备did的信息
                        app.setMac(device.getMacAddress()); //_currentDeviceMac = device.getMacAddress();
                    }
                    break;
            }
        } else if (error == XPGWifiErrorCode.XPGWifiError_CONNECT_TIMEOUT) {
            //超时的回调
            PluginResult pr = new PluginResult(PluginResult.Status.ERROR, error);
            callbackContext.sendPluginResult(pr);
        } else {
            //设备配对有可能返回多次,这里不做处理.
        }
    }

    @Override
    public void didDiscovered(int result, List<XPGWifiDevice> devicesList) {
        if (result == XPGWifiErrorCode.XPGWifiError_NONE && devicesList.size() > 0) {
            String currentDeviceMac = app.getMac();
            switch (GwsdkStateCode.getCurrentState()) {
                case GwsdkStateCode.SetWifiCode:
                    //如果当前配对的DeviceMac 存在.
                    if (currentDeviceMac != null) { //if (_currentDeviceMac != null) {
                        for (int i = 0; i < devicesList.size(); i++) {
                            if (HeytzApp.DEBUG) {
                                Log.e("didDiscovered", devicesList.get(i).getMacAddress());
                                Log.e("didDiscovered", devicesList.get(i).getDid());
                                Log.e("didDiscovered", devicesList.get(i).getIPAddress());
                                Log.e("didDiscovered", devicesList.get(i).getProductKey());
                            }
                            //判断did 是否为空
                            if (devicesList.get(i).getDid().length() > 0) {
                                //判断当前设备是否为正在配对的设备(*Mac地址判断),
                                //if ((devicesList.get(i).getMacAddress().indexOf(_currentDeviceMac) > -1)) {
                                if ((devicesList.get(i).getMacAddress().indexOf(currentDeviceMac) > -1)) {
                                    //清空内存中的Mac
                                    app.setMac(null);//_currentDeviceMac = null;
                                    sendDeviceInfo(devicesList.get(i));
//                                        JSONObject json = new JSONObject();
//                                        try {
//                                            json.put("productKey", devicesList.get(i).getProductKey());
//                                            json.put("did", devicesList.get(i).getDid());
//                                            json.put("macAddress", devicesList.get(i).getMacAddress());
//                                            json.put("passcode", devicesList.get(i).getPasscode());
//                                        } catch (JSONException e) {
//                                            if (debug)
//                                                Log.e("====parseJSON====", e.getMessage());
//                                            //异常处理
//                                            PluginResult pr = new PluginResult(PluginResult.Status.ERROR, e.getMessage());
//                                            airLinkCallbackContext.sendPluginResult(pr);
//                                        }
//                                        if (debug)
//                                            Log.e("====didDiscovered====", "success:" + devicesList.get(i).getDid());
//                                        //成功的返回
//                                        PluginResult pr = new PluginResult(PluginResult.Status.OK, json);
//                                        airLinkCallbackContext.sendPluginResult(pr);
                                }
                            } else {
                                if (HeytzApp.DEBUG)
                                    Log.e("====didDiscovered====", "did is null:" + devicesList.get(i).getMacAddress());
                            }
                        }
                    }
                    break;
                case GwsdkStateCode.GetDevcieListCode:
                    if (app.hasDone(devicesList)) {
                        JSONArray cdvResult = new JSONArray();
                        for (int i = 0; i < devicesList.size(); i++) {
                            //cdvResult.put(toJSONObjfrom(devicesList.get(i)));
                            cdvResult.put(HeytzUtil.toJSONObjfrom(devicesList.get(i), app));
                        }
                        app.getDeviceList().clear(); // = null;
                        callbackContext.success(cdvResult);

                    } else {
                        app.setDeviceList(devicesList);
                    }
                    break;
                case GwsdkStateCode.ControlCode:
                    app.setDeviceList(devicesList);
                    //deviceLogin(_uid, _token, _currentDeviceMac);
                    deviceLogin(app.getUid(), app.getToken(), currentDeviceMac); //deviceLogin(app.getUid(), _token, _currentDeviceMac);
                    Log.d(HeytzApp.TAG, "deviceLoing()");
                    break;
                case GwsdkStateCode.SetDeviceWifiBindDevice:
                    //如果当前配对的DeviceMac 存在.
                    if (currentDeviceMac != null) { //if (_currentDeviceMac != null) {
                        for (int i = 0; i < devicesList.size(); i++) {
                            HeytzUtil.logDevice("\n=====SetDeviceWifiBindDevic=====\n", devicesList.get(i));
                            //判断did 是否为空
                            if (devicesList.get(i).getDid().length() > 0) {
                                //判断当前设备是否为正在配对的设备(*Mac地址判断),
                                //if ((devicesList.get(i).getMacAddress().indexOf(_currentDeviceMac) > -1)) {
                                if ((devicesList.get(i).getMacAddress().indexOf(currentDeviceMac) > -1)) {
                                    app.setCurrentDevice(devicesList.get(i)); //currentDevice = ;
                                    if (controlState == true) {
                                        controlState = false;
                                        //XPGWifiSDK.sharedInstance().bindDevice(_uid, _token, devicesList.get(i).getDid(), null, null);
                                        XPGWifiSDK.sharedInstance().bindDevice(app.getUid(), app.getToken(), devicesList.get(i).getDid(), null, null);
                                    }
                                }
                            }
                        }
                    }
                    break;
                case GwsdkStateCode.ConnectDevice:
                    break;
                default:

            }
        }
    }

    /**
     * 如果device没有登录那么登录，发送控制命令到cWrite 第二步
     *
     * @param uid
     * @param token
     * @param mac
     */
    private void deviceLogin(String uid, String token, String mac) {

        XPGWifiDevice d = null;
        for (int i = 0; i < app.getDeviceList().size(); i++) {
            XPGWifiDevice device = app.getDeviceList().get(i);
            if (device != null) {
                if (HeytzApp.DEBUG)
                    Log.w(HeytzApp.TAG, device.getMacAddress());
                if (device != null && device.getMacAddress().equals(mac.toUpperCase())) {
                    d = device;
                    break;
                }
            }
        }

        if (d != null && controlState == true) {
            controlState = false;
            //判断这个设备的状态,
            if (!d.isConnected()) {
                (d).login(uid, token);

                d.setListener(new XPGWifiDeviceListener() {
                    @Override
                    public void didLogin(XPGWifiDevice device, int result) {
                        cWrite(device, controlObject);
                    }

                    @Override
                    public void didDeviceOnline(XPGWifiDevice device, boolean isOnline) {
                    }

                    @Override
                    public void didDisconnected(XPGWifiDevice device, int result) {
                        if (HeytzApp.DEBUG)
                            Log.d(HeytzApp.TAG, "did disconnected...");
                    }

                    @Override
                    public void didReceiveData(XPGWifiDevice device, java.util.concurrent.ConcurrentHashMap<String, Object> dataMap, int result) {
                        //回调
                        //普通数据点类型，有布尔型、整形和枚举型数据，该种类型一般为可读写
                        if (dataMap.get("data") != null) {
                            Log.i("info", (String) dataMap.get("data"));

                        }
                        //设备报警数据点类型，该种数据点只读，设备发生报警后该字段有内容，没有发生报警则没内容
                        if (dataMap.get("alters") != null) {
                            Log.i("info", (String) dataMap.get("alters"));

                        }
                        //设备错误数据点类型，该种数据点只读，设备发生错误后该字段有内容，没有发生报警则没内容
                        if (dataMap.get("faults") != null) {
                            Log.i("info", (String) dataMap.get("faults"));

                        }
                        //二进制数据点类型，适合开发者自行解析二进制数据
                        if (dataMap.get("binary") != null) {
                            Log.i("info", "Binary data:");
                            //收到后自行解析
                        }
                    }

                    @Override
                    public void didQueryHardwareInfo(XPGWifiDevice device, int result, java.util.concurrent.ConcurrentHashMap<String, String> hardwareInfo) {
                    }
                });
            } else {//如果设备已经登陆,直接控制.
                cWrite(d, controlObject);
            }

        }
    }

    /**
     * 发送控制命令的方法  第三步
     *
     * @param xpgWifiDevice
     * @param value
     */
    private void cWrite(XPGWifiDevice xpgWifiDevice, Object value) {
        try {
            JSONObject arr = new JSONObject(value.toString());
            //创建JSONObject 对象，用于封装所有数据
            JSONObject jsonsend = new JSONObject();
            //写入命令字段（所有产品一致）
            jsonsend.put("cmd", 1);
            //jsonsend.put("aciton", 1);
            //创建JSONObject 对象，用于封装数据点
            JSONObject jsonparam = new JSONObject();
            //写入数据点字段
//            jsonparam.put(key, value);
            Iterator it = arr.keys();
            while (it.hasNext()) {
                String jsonKey = (String) it.next();
                String jsonValue = arr.getString(jsonKey);
                jsonparam.put(jsonKey, HeytzUtil.getData(jsonValue));
            }
//            jsonparam.put("command", getData(arr.getString("command")));
//            jsonparam.put("mac",  getData(arr.getString("mac")));
//            jsonparam.put("control",  getData(arr.getString("control")));
//            jsonparam.put("percent",  getData(arr.getString("percent")));
//            jsonparam.put("angle",  getData(arr.getString("angle")));
            //写入产品字段（所有产品一致）
            jsonsend.put("entity0", jsonparam);
            //{"entity0":"{\"command\":\"0009\",\"control\":\"02\",\"mac\":\"000000008d418d12\",\"percent\":\"00\",\"angle\":\"00\"}","cmd":1}
            // 0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
            // 0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
            //调用发送指令方法
            xpgWifiDevice.write(jsonsend.toString());
            callbackContext.success("success");
        } catch (JSONException e) {
            if (HeytzApp.DEBUG)
                e.printStackTrace();
            callbackContext.error("error");
        }
    }

    private void sendDeviceInfo(XPGWifiDevice device) {
        JSONObject json = new JSONObject();
        try {
            json.put("productKey", device.getProductKey());
            json.put("did", device.getDid());
            json.put("macAddress", device.getMacAddress());
            json.put("passcode", device.getPasscode());
        } catch (JSONException e) {
            if (HeytzApp.DEBUG)
                Log.e("====parseJSON====", e.getMessage());
            //异常处理
            PluginResult pr = new PluginResult(PluginResult.Status.ERROR, e.getMessage());
            callbackContext.sendPluginResult(pr);
        }
        if (HeytzApp.DEBUG)
            Log.e("====didDiscovered====", "success:" + device.getDid());
        //成功的返回
        PluginResult pr = new PluginResult(PluginResult.Status.OK, json);
        callbackContext.sendPluginResult(pr);
    }

    /*
     *  setter getter
     */

    public HeytzApp getApp() {
        return app;
    }

    public void setApp(HeytzApp app) {
        this.app = app;
    }

    public CallbackContext getCallbackContext() {
        return callbackContext;
    }

    public void setCallbackContext(CallbackContext callbackContext) {
        this.callbackContext = callbackContext;
    }

//    public void setCurrentDevice(XPGWifiDevice currentDevice) {
//        this.currentDevice = currentDevice;
//    }

    public void setAttempts(int attempts) {
        this.attempts = attempts;
    }

    public void setControlState(Boolean controlState) {
        this.controlState = controlState;
    }
}
