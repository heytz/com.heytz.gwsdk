package com.heytz.gwsdk;

import android.content.Context;
import com.xtremeprog.xpgconnect.XPGWifiDevice;
import com.xtremeprog.xpgconnect.XPGWifiSDK;
import com.xtremeprog.xpgconnect.XPGWifiSDK.XPGWifiConfigureMode;
import org.apache.cordova.*;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;


/**
 * This class wrapping Gizwits WifiSDK called from JavaScript.
 */
public class Gwsdk extends CordovaPlugin {
    private static final String GIZ_APP_ID = "gizwappid";
    //    private CallbackContext airLinkCallbackContext;
    private Context context;
    private final String TAG = "\n===gwsdkwrapper====\n";
    private Boolean debug = true;            //debug 状态
    //private Object _controlObject;           //用户控制的值.
    //private Boolean _controlState;           //锁定用户的控制状态
    private HeytzApp app = new HeytzApp();
    private HeytzXPGWifiSDKListener wifiSDKListener = new HeytzXPGWifiSDKListener();

//    private XPGWifiSDKListener wifiSDKListener = new XPGWifiSDKListener() {
//
//        private JSONObject toJSONObjfrom(XPGWifiDevice device) {
//            JSONObject json = new JSONObject();
//            try {
//                json.put("did", device.getDid());
//                json.put("macAddress", device.getMacAddress());
//                json.put("isLAN", device.isLAN() ? "1" : "0");
//                json.put("isOnline", device.isOnline() ? "1" : "0");
//                json.put("isConnected", device.isConnected() ? "1" : "0");
//                json.put("isDisabled", device.isDisabled() ? "1" : "0");
//                json.put("isBind", device.isBind(_uid) ? "1" : "0");
//            } catch (JSONException e) {
//
//            }
//            return json;
//        }
//
//
//        private Boolean hasDone(List<XPGWifiDevice> deviceList) {
//            if (_devicesList == null) return false;
//            return _devicesList.size() == deviceList.size();
//        }
//
//        private void sendDeviceInfo(XPGWifiDevice device) {
//            JSONObject json = new JSONObject();
//            try {
//                json.put("productKey", device.getProductKey());
//                json.put("did", device.getDid());
//                json.put("macAddress", device.getMacAddress());
//                json.put("passcode", device.getPasscode());
//            } catch (JSONException e) {
//                if (debug)
//                    Log.e("====parseJSON====", e.getMessage());
//                //异常处理
//                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, e.getMessage());
//                airLinkCallbackContext.sendPluginResult(pr);
//            }
//            if (debug)
//                Log.e("====didDiscovered====", "success:" + device.getDid());
//            //成功的返回
//            PluginResult pr = new PluginResult(PluginResult.Status.OK, json);
//            airLinkCallbackContext.sendPluginResult(pr);
//        }
//
//        /**
//         * wifi配对的回调,这个回调不保证可以获取到设备的did
//         * 所以我们拿到这个设备的MacAddress,去didDiscovered 等待设备详细的信息反馈,
//         * @param error
//         * @param device
//         */
//        @Override
//        public void didSetDeviceWifi(int error, XPGWifiDevice device) {
//            if (error == XPGWifiErrorCode.XPGWifiError_NONE && device.getMacAddress().length() > 0) {
//                logDevice("\n======didsetDeviceWifi======\n", device);
//                switch (GwsdkStateCode.getCurrentState()) {
//                    case GwsdkStateCode.SetWifiCode:
//                        //如果存在did那么就直接返回成功,现在测试只会返回一次
//                        if (_currentDeviceMac == null && device.getDid().length() > 0) {
//                            sendDeviceInfo(device);
//                        } else {//否则获取配对到的设备地址,去didDiscovered 等待设备did的信息
//                            _currentDeviceMac = device.getMacAddress();
//                        }
//                        break;
//                    case GwsdkStateCode.SetDeviceWifiBindDevice:
//                        //如果存在did那么就直接返回成功,现在测试只会返回一次
//                        if (_currentDeviceMac == null && device.getDid().length() > 0) {
//                            _currentDevice = device;
//                            XPGWifiSDK.sharedInstance().bindDevice(_uid, _token, device.getDid(), null, null);
//                        } else {//否则获取配对到的设备地址,去didDiscovered 等待设备did的信息
//                            _currentDeviceMac = device.getMacAddress();
//                        }
//                        break;
//                }
//            } else if (error == XPGWifiErrorCode.XPGWifiError_CONNECT_TIMEOUT) {
//                //超时的回调
//                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, error);
//                airLinkCallbackContext.sendPluginResult(pr);
//            } else {
//                //设备配对有可能返回多次,这里不做处理.
//            }
//        }
//
//
//        @Override
//        public void didDiscovered(int result, List<XPGWifiDevice> devicesList) {
//            if (result == XPGWifiErrorCode.XPGWifiError_NONE && devicesList.size() > 0) {
//                switch (GwsdkStateCode.getCurrentState()) {
//                    case GwsdkStateCode.SetWifiCode:
//                        //如果当前配对的DeviceMac 存在.
//                        if (_currentDeviceMac != null) {
//                            for (int i = 0; i < devicesList.size(); i++) {
//                                //判断did 是否为空
//                                if (devicesList.get(i).getDid().length() > 0) {
//                                    //判断当前设备是否为正在配对的设备(*Mac地址判断),
//                                    if ((devicesList.get(i).getMacAddress().indexOf(_currentDeviceMac) > -1)) {
//                                        //清空内存中的Mac
//                                        _currentDeviceMac = null;
//                                        sendDeviceInfo(devicesList.get(i));
//                                    }
//                                } else {
//                                    if (debug)
//                                        Log.e("====didDiscovered====", "did is null:" + devicesList.get(i).getMacAddress());
//                                }
//                            }
//                        }
//                        break;
//                    case GwsdkStateCode.GetDevcieListCode:
//                        if (hasDone(devicesList)) {
//                            JSONArray cdvResult = new JSONArray();
//                            for (int i = 0; i < devicesList.size(); i++) {
//                                cdvResult.put(toJSONObjfrom(devicesList.get(i)));
//                            }
//                            PluginResult pr = new PluginResult(PluginResult.Status.ERROR, cdvResult);
//                            pr.setKeepCallback(true);
//                            airLinkCallbackContext.success(cdvResult);
//                        } else {
//                            _devicesList = devicesList;
//                        }
//                        break;
//                    case GwsdkStateCode.ControlCode:
//                        _devicesList = devicesList;
//                        deviceLogin(_uid, _token, _currentDeviceMac);
//                        Log.d(TAG, "deviceLoing()");
//                        break;
//                    case GwsdkStateCode.SetDeviceWifiBindDevice:
//                        //如果当前配对的DeviceMac 存在.
//                        if (_currentDeviceMac != null) {
//                            for (int i = 0; i < devicesList.size(); i++) {
//                                logDevice("\n=====SetDeviceWifiBindDevic=====\n", devicesList.get(i));
//                                //判断did 是否为空
//                                if (devicesList.get(i).getDid().length() > 0) {
//                                    //判断当前设备是否为正在配对的设备(*Mac地址判断),
//                                    if ((devicesList.get(i).getMacAddress().indexOf(_currentDeviceMac) > -1)) {
//                                        _currentDevice = devicesList.get(i);
//                                        if (_controlState == true) {
//                                            _controlState = false;
//                                            XPGWifiSDK.sharedInstance().bindDevice(_uid, _token, devicesList.get(i).getDid(), null, null);
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        break;
//                    default:
//
//                }
//            }
//        }
//
//        @Override
//        public void didBindDevice(int result, String errorMessage, String did) {
//            if (result == XPGWifiErrorCode.XPGWifiError_NONE) {
//                Log.e("\n===binding success===\n", errorMessage + did);
//
//                //绑定设备成功，登录设备进行控制
//                PluginResult pr = new PluginResult(PluginResult.Status.OK, deviceToJsonObject(_currentDevice));
//                airLinkCallbackContext.sendPluginResult(pr);
//                //清空内存中的Mac
//                _currentDeviceMac = null;
//                _currentDevice = null;
//            } else {
//                Log.e("\n===binding error===\n", errorMessage);
//                if (attempts > 0) {
//                    _controlState = true;
//                    attempts = attempts - 1;
//                } else {
//                    //清空内存中的Mac
//                    _currentDeviceMac = null;
//                    _currentDevice = null;
//                    //绑定设备失败，弹出错误信息
//                    PluginResult pr = new PluginResult(PluginResult.Status.ERROR, errorMessage);
//                    airLinkCallbackContext.sendPluginResult(pr);
//                }
//            }
//
//        }
//    };
//

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        // your init code here
        context = cordova.getActivity().getApplicationContext();
        //设置appId
        String appId = webView.getPreferences().getString(GIZ_APP_ID, "");
        XPGWifiSDK.sharedInstance().startWithAppID(context, appId);
        wifiSDKListener.setAttempts(2);
        wifiSDKListener.setControlState(true);
        // set listener
        XPGWifiSDK.sharedInstance().setListener(wifiSDKListener);
        wifiSDKListener.setApp(app);
    }

    /**
     * @param action          The action to execute.
     * @param args            The exec() arguments.
     *                        setDeviceWifi: (appid,productKey,wifiSSID,wifiKey)
     *                        getDeviceList: (appid,productKey,uid,token)
     *                        deviceControl: (appid,productKey,uid,token,mac,value)
     * @param callbackContext The callback context used when calling back into JavaScript.
     * @return
     * @throws JSONException
     */
    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {


        if (action.equals(Operation.SET_DEVICE_WIFI.getMethod())) {
            app.setCallbackContext(Operation.SET_DEVICE_WIFI.getMethod(), callbackContext);
            int timeout = args.getInt(3);
            this.setDeviceWifi(args.getString(1), args.getString(2), timeout);
            return true;
        }
        if (action.equals(Operation.SET_DEVICE_WIFI_AND_BIND)) {
            app.setCallbackContext(Operation.SET_DEVICE_WIFI_AND_BIND.getMethod(), callbackContext);
            wifiSDKListener.setAttempts(2);
            List<String> list = new ArrayList<String>();
            for (int i = 0; i < args.getJSONArray(0).length(); i++) {
                list.add(args.getJSONArray(0).get(i).toString());
            }
            app.seProductKeys(list);
            String ssid = args.getString(1);
            String ssidWifi = args.getString(2);
            app.setUid(args.getString(3));
            app.setToken(args.getString(4));
            int timeout = args.getInt(5);
            XPGWifiConfigureMode xpgWifiConfigureMode = XPGWifiConfigureMode.XPGWifiConfigureModeAirLink;
            switch (args.getInt(6)) {
                case 1:
                    xpgWifiConfigureMode = XPGWifiConfigureMode.XPGWifiConfigureModeSoftAP;
                    break;
                case 2:
                    xpgWifiConfigureMode = XPGWifiConfigureMode.XPGWifiConfigureModeAirLink;
                    break;
            }
            String softAPSSIDPrefix = args.getString(7);
            this.setDeviceWifiBindDevice(ssid, ssidWifi,
                    xpgWifiConfigureMode,
                    timeout, softAPSSIDPrefix, null
                    , callbackContext);
            return true;
        }
        /**
         * 绑定设备
         */
        if (action.equals(Operation.DEVICE_BINDING.getMethod())) {
            app.setCallbackContext(Operation.UNBIND_DEVICE.getMethod(), callbackContext);
            String uid = args.getString(0);
            String token = args.getString(1);
            String did = args.getString(2);
            String passcode = args.getString(3);
            String remark = args.getString(4);
            app.setUid(uid);
            app.setToken(token);
            XPGWifiSDK.sharedInstance().bindDevice(uid, token, did, passcode, remark);
            return true;
        }
        /**
         * 解绑设备
         */
        if (action.equals(Operation.UNBIND_DEVICE.getMethod())) {
            app.setCallbackContext(Operation.UNBIND_DEVICE.getMethod(), callbackContext);
            String uid = args.getString(0);
            String token = args.getString(1);
            String did = args.getString(2);
            String passcode = args.getString(3);
            app.setUid(uid);
            app.setToken(token);
            XPGWifiSDK.sharedInstance().unbindDevice(uid, token, did, passcode);
            return true;
        }
        if (action.equals(Operation.GET_DEVICE_LIST.getMethod())) {
            app.setCallbackContext(Operation.GET_DEVICE_LIST.getMethod(), callbackContext);
            List<String> products = new ArrayList<String>();
            for (int i = 0; i < args.getJSONArray(0).length(); i++) {
                products.add(args.getJSONArray(0).get(i).toString());
            }
            app.seProductKeys(products);
            app.setUid(args.getString(1));
            app.setToken(args.getString(2));
            this.getDeviceList(args.getString(1), args.getString(2), products);
            return true;
        }
        if (action.equals(Operation.CONTROL_DEVICE.getMethod())) {
            wifiSDKListener.setControlState(true);
            app.setCallbackContext(Operation.CONTROL_DEVICE.getMethod(), callbackContext);
            List<String> products = new ArrayList<String>();
            for (int i = 0; i < args.getJSONArray(0).length(); i++) {
                products.add(args.getJSONArray(0).get(i).toString());
            }
            app.setUid(args.getString(1));
            app.setToken(args.getString(2));
            app.setMac(args.getString(3));
            app.setControlObject(args.getString(4));
            this.getDeviceList(args.getString(1), args.getString(2), products);
            return true;
        }
        if (action.equals(Operation.GET_WIFI_SSID_LIST.getMethod())) {
            app.setCallbackContext(Operation.GET_WIFI_SSID_LIST.getMethod(), callbackContext);
            XPGWifiSDK.sharedInstance().getSSIDList();
            return true;
        }
        if (action.equals(Operation.START_DEVICE_LISTENER.getMethod())) {
            app.setCallbackContext(Operation.START_DEVICE_LISTENER.getMethod(), callbackContext);
            return true;
        }
        if (action.equals(Operation.STOP_DEVICE_LISTENER.getMethod())) {
            app.removeCallbackContext(Operation.STOP_DEVICE_LISTENER.getMethod());
            callbackContext.success();
            return true;
        }
        if (action.equals(Operation.CONNECT.getMethod())) {
            app.setCallbackContext(Operation.CONNECT.getMethod(), callbackContext);
            app.setUid(args.getString(0));
            app.setToken(args.getString(1));
            String did = args.getString(2);
            this.connact(did);
            return true;
        }
        if (action.equals(Operation.DISCONNECT.getMethod())) {
            app.setCallbackContext(Operation.DISCONNECT.getMethod(), callbackContext);
            String did = args.getString(0);
            this.disconnact(did);
            return true;
        }
        if (action.equals(Operation.WRITE.getMethod())) {
            app.setCallbackContext(Operation.WRITE.getMethod(), callbackContext);
            String did = args.getString(0);
            Object value = args.getJSONObject(1);
            app.setControlObject(value);
            this.write(did,args.getJSONObject(1));
            return true;
        }

        if (action.equals(Operation.UPDATE_DEVICE_FROM_SERVER.getMethod())) {
            String productKey = args.getString(0);
            app.setCallbackContext(Operation.UPDATE_DEVICE_FROM_SERVER.getMethod(), callbackContext);
            XPGWifiSDK.sharedInstance().updateDeviceFromServer(productKey);
            return true;
        }
        //销毁内存中的Listener
        if (action.equals(Operation.DEALLOC.getMethod())) {
            this.dealloc();
            return true;
        }
        return false;
    }

    /**
     * 方法 wifi配对
     *
     * @param wifiSSID
     * @param wifiKey
     */
    private void setDeviceWifi(String wifiSSID, String wifiKey, int timeout) {
        if (wifiSSID != null && wifiSSID.length() > 0 && wifiKey != null && wifiKey.length() > 0) {
            //15.11.24 切换成新接口
            XPGWifiSDK.sharedInstance().setDeviceWifi(wifiSSID, wifiKey, XPGWifiConfigureMode.XPGWifiConfigureModeAirLink, null, timeout, null);
        } else {
            app.getCallbackContext(Operation.SET_DEVICE_WIFI.getMethod()).error("args is empty or null");
            app.removeCallbackContext(Operation.SET_DEVICE_WIFI.getMethod());
        }
    }

    /**
     * 方法 配对wifi 并且绑定设备
     *
     * @param wifiSSID
     * @param wifiKey
     * @param mode
     * @param timeout
     * @param softAPSSIDPrefix
     * @param types
     * @param callbackContext
     */
    private void setDeviceWifiBindDevice(String wifiSSID, String wifiKey, XPGWifiConfigureMode mode, int timeout, String softAPSSIDPrefix, List<XPGWifiSDK.XPGWifiGAgentType> types, CallbackContext callbackContext) {
        if (wifiSSID != null && wifiSSID.length() > 0 && wifiKey != null && wifiKey.length() > 0) {
            //15.11.24 切换成新接口
            XPGWifiSDK.sharedInstance().setDeviceWifi(wifiSSID, wifiKey,
                    mode, softAPSSIDPrefix,
                    timeout, null);
        } else {
            app.getCallbackContext(Operation.SET_DEVICE_WIFI_AND_BIND.getMethod()).error("args is empty or null");
            app.removeCallbackContext(Operation.SET_DEVICE_WIFI_AND_BIND.getMethod());

        }
    }

    /**
     * 方法 获取设备列表
     *
     * @param uid
     * @param token
     * @param productKey
     */
    private void getDeviceList(String uid, String token, List<String> productKey) {
        XPGWifiSDK.sharedInstance().getBoundDevices(uid, token, productKey);
    }

    /**
     * 方法 连接设备
     *
     * @param did
     */
    private void connact(String did) {
        List<XPGWifiDevice> list = app.getDeviceList();
        boolean isExist = false;
        for (XPGWifiDevice aList : list) {
            if (aList.getDid().equals(did)) {
                isExist = true;
                if (aList.isConnected()) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, HeytzUtil.deviceToJsonObject(aList, app.getUid()));
                    app.getCallbackContext(Operation.CONNECT.getMethod()).sendPluginResult(pluginResult);
                    app.removeCallbackContext(Operation.CONNECT.getMethod());
                } else {
                    aList.login(app.getUid(), app.getToken());
                }
            }
        }
        if (!isExist) {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "This device does not exist!");
            app.getCallbackContext(Operation.CONNECT.getMethod()).sendPluginResult(pluginResult);
            app.removeCallbackContext(Operation.CONNECT.getMethod());
        }
    }

    /**
     * 方法 断开设备连接
     *
     * @param did
     */
    private void disconnact(String did) {
        List<XPGWifiDevice> list = app.getDeviceList();
        boolean isExist = false;
        for (XPGWifiDevice aList : list) {
            if (aList.getDid().equals(did)) {
                isExist = true;
                if (!aList.isConnected()) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, did);
                    app.getCallbackContext(Operation.DISCONNECT.getMethod()).sendPluginResult(pluginResult);
                    app.removeCallbackContext(Operation.DISCONNECT.getMethod());
                } else {
                    aList.disconnect();
                }
            }
        }
        if (!isExist) {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "This device does not exist!");
            app.getCallbackContext(Operation.DISCONNECT.getMethod()).sendPluginResult(pluginResult);
            app.removeCallbackContext(Operation.DISCONNECT.getMethod());
        }
    }

    private void write(String did,JSONObject jsonObject) {
        List<XPGWifiDevice> list = app.getDeviceList();
        boolean isExist = false;
        for (XPGWifiDevice aList : list) {
            if (aList.getDid().equals(did)) {
                isExist = true;
                if (aList.isConnected()) {
                    JSONObject jsonsend = new JSONObject();
                    //写入命令字段（所有产品一致）
                    try {
                        jsonsend.put("cmd", 1);
                        jsonsend.put("entity0", jsonObject);
                    } catch (JSONException e) {
                        PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "Field error");
                        app.getCallbackContext(Operation.WRITE.getMethod()).sendPluginResult(pluginResult);
                        app.removeCallbackContext(Operation.WRITE.getMethod());
                    }
                    aList.write(jsonsend.toString());
                } else {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "The device is not connected!");
                    app.getCallbackContext(Operation.WRITE.getMethod()).sendPluginResult(pluginResult);
                    app.removeCallbackContext(Operation.WRITE.getMethod());
                }
            }
        }
        if (!isExist) {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "This device does not exist!");
            app.getCallbackContext(Operation.WRITE.getMethod()).sendPluginResult(pluginResult);
            app.removeCallbackContext(Operation.WRITE.getMethod());
        }
    }

    private void dealloc() {
        XPGWifiSDK.sharedInstance().setListener(null);
        XPGWifiSDK.sharedInstance().setListener(wifiSDKListener);
    }
}