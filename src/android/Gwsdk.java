package com.heytz.gwsdk;

import android.content.Context;
import android.os.Handler;
import com.xtremeprog.xpgconnect.XPGWifiDevice;
import com.xtremeprog.xpgconnect.XPGWifiSDK;
import com.xtremeprog.xpgconnect.XPGWifiSDK.XPGWifiConfigureMode;
import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;


/**
 * This class wrapping Gizwits WifiSDK called from JavaScript.
 */
public class Gwsdk extends CordovaPlugin {
    private static final String GIZ_APP_ID = "gizwappid";
    private Context context;
    private HeytzApp app = new HeytzApp();
    private HeytzXPGWifiSDKListener wifiSDKListener = new HeytzXPGWifiSDKListener();
    private HeytzXPGWifiDeviceListener heytzXPGWifiDeviceListener = new HeytzXPGWifiDeviceListener();
    private Handler handler = new Handler();
    private Timer timer;

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
        if (action.equals(Operation.SET_DEVICE_WIFI_AND_BIND.getMethod())) {
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
            List<XPGWifiSDK.XPGWifiGAgentType> xpgWifiGAgentTypeList = new ArrayList<XPGWifiSDK.XPGWifiGAgentType>();
            JSONArray productkeys = new JSONArray();
            if (!args.isNull(8)) {
                productkeys = args.getJSONArray(8);
                if (productkeys != null && productkeys.length() > 0) {
                    for (int i = 0; i < productkeys.length(); i++) {
                        XPGWifiSDK.XPGWifiGAgentType xpgWifiGAgentType = HeytzXPGWifiGAgentType.getHeytzXPGWifiGAgentType(productkeys.getInt(i));
                        if (xpgWifiGAgentType != null) {
                            xpgWifiGAgentTypeList.add(xpgWifiGAgentType);
                        }
                    }
                }
            }
            this.setDeviceWifiBindDevice(ssid, ssidWifi,
                    xpgWifiConfigureMode,
                    timeout,
                    softAPSSIDPrefix,
                    xpgWifiGAgentTypeList
            );
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
        ///{products,uid,token,timeInterval}
        if (action.equals(Operation.START_GET_DEVICE_LIST.getMethod())) {
            app.setCallbackContext(Operation.START_GET_DEVICE_LIST.getMethod(), callbackContext);
            List<String> products = new ArrayList<String>();
            for (int i = 0; i < args.getJSONArray(0).length(); i++) {
                products.add(args.getJSONArray(0).get(i).toString());
            }
            app.seProductKeys(products);
            app.setUid(args.getString(1));
            app.setToken(args.getString(2));
            this.startGetDeviceList(args.getInt(3));
            return true;
        }
        if (action.equals(Operation.STOP_GET_DEVICE_LIST.getMethod())) {
            app.setCallbackContext(Operation.STOP_GET_DEVICE_LIST.getMethod(), callbackContext);
            this.stopGetDeviceList();
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
        if (action.equals(Operation.GET_HARDWARE_INFO.getMethod())) {
            app.setCallbackContext(Operation.GET_HARDWARE_INFO.getMethod(), callbackContext);
            String did = args.getString(0);
            this.getHardwareInfo(did);
            return true;
        }

        if (action.equals(Operation.WRITE.getMethod())) {
            app.setCallbackContext(Operation.WRITE.getMethod(), callbackContext);
            String did = args.getString(0);
            Object value = args.getJSONObject(1);
            app.setControlObject(value);
            this.write(did, args.getJSONObject(1));
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
     */
    private void setDeviceWifiBindDevice(String wifiSSID, String wifiKey, XPGWifiConfigureMode mode, int timeout, String softAPSSIDPrefix, List<XPGWifiSDK.XPGWifiGAgentType> types) {
        if (wifiSSID != null && wifiSSID.length() > 0 && wifiKey != null && wifiKey.length() > 0) {

            //15.11.24 切换成新接口
            XPGWifiSDK.sharedInstance().setDeviceWifi(wifiSSID, wifiKey,
                    mode, null,
                    timeout, types);
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

        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                XPGWifiSDK.sharedInstance().getBoundDevices(app.getUid(), app.getToken(), app.getProductKeys());
                handler.postDelayed(this, 2000);
            }
        };
        handler.postDelayed(runnable, 2000);//每两秒执行一次runnable

        XPGWifiSDK.sharedInstance().getBoundDevices(uid, token, productKey);
    }

    /**
     * 根据间隔时间 请求列表
     *
     * @param interval
     */
    private void startGetDeviceList(int interval) {
        if (timer == null) {
            if (interval > 0) {
                timer = new Timer(true);
                timer.schedule(new TimerTask() {
                    public void run() {
                        XPGWifiSDK.sharedInstance().getBoundDevices(app.getUid(), app.getToken(), app.getProductKeys());
                    }
                }, 0, interval);
            } else {
                app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()).error("interval is zero!");
                app.removeCallbackContext(Operation.START_DEVICE_LISTENER.getMethod());
            }
        }
    }
    /**
     * 停止当前的定时器
     */
    private void stopGetDeviceList() {
        if (timer != null) {
            timer.cancel();
            timer.purge();
            timer = null;
            app.getCallbackContext(Operation.STOP_DEVICE_LISTENER.getMethod()).success();
            app.removeCallbackContext(Operation.STOP_DEVICE_LISTENER.getMethod());
        } else {
            app.getCallbackContext(Operation.STOP_DEVICE_LISTENER.getMethod()).error("timer is null!");
            app.removeCallbackContext(Operation.STOP_DEVICE_LISTENER.getMethod());
        }
    }

    /**
     * 方法 连接设备
     *
     * @param did
     */

    private void connact(String did) {
        List<XPGWifiDevice> list = app.getDeviceList();
        boolean isExist = false;
        for (XPGWifiDevice xpgWifiDevice : list) {
            if (xpgWifiDevice.getDid().equals(did)) {
                isExist = true;
                app.setCurrentDevice(xpgWifiDevice);
                heytzXPGWifiDeviceListener.setApp(app);
                xpgWifiDevice.setListener(heytzXPGWifiDeviceListener);
                if (xpgWifiDevice.isConnected()) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, HeytzUtil.deviceToJsonObject(xpgWifiDevice, app.getUid()));
                    app.getCallbackContext(Operation.CONNECT.getMethod()).sendPluginResult(pluginResult);
                    app.removeCallbackContext(Operation.CONNECT.getMethod());
                } else {
                    xpgWifiDevice.login(app.getUid(), app.getToken());
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

    private void getHardwareInfo(String did) {
        List<XPGWifiDevice> list = app.getDeviceList();
        boolean isExist = false;
        for (XPGWifiDevice xpgWifiDevice : list) {
            if (xpgWifiDevice.getDid().equals(did)) {
                isExist = true;
                app.setCurrentDevice(xpgWifiDevice);
                heytzXPGWifiDeviceListener.setApp(app);
                xpgWifiDevice.setListener(heytzXPGWifiDeviceListener);
                xpgWifiDevice.getHardwareInfo();
            }
        }
        if (!isExist) {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "This device does not exist!");
            app.getCallbackContext(Operation.GET_HARDWARE_INFO.getMethod()).sendPluginResult(pluginResult);
            app.removeCallbackContext(Operation.GET_HARDWARE_INFO.getMethod());
        }
    }

    /**
     * 方法  发送控制命令
     *
     * @param did
     * @param jsonObject
     */
    private void write(String did, JSONObject jsonObject) {
        List<XPGWifiDevice> list = app.getDeviceList();
        boolean isExist = false;
        for (XPGWifiDevice xpgWifiDevice : list) {
            if (xpgWifiDevice.getDid().equals(did)) {
                isExist = true;
                if (xpgWifiDevice.isConnected()) {
                    //写入命令字段（所有产品一致）
                    try {
                        JSONObject jsonsend = new JSONObject();
                        jsonsend.put("cmd", 1);
                        jsonsend.put("entity0", jsonObject);
                        app.setCurrentDevice(xpgWifiDevice);
                        heytzXPGWifiDeviceListener.setApp(app);
                        xpgWifiDevice.setListener(heytzXPGWifiDeviceListener);
                        xpgWifiDevice.write(jsonsend.toString());
                        app.getCallbackContext(Operation.WRITE.getMethod()).success();
                        app.removeCallbackContext(Operation.WRITE.getMethod());
                    } catch (JSONException e) {
                        PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "Field error");
                        HeytzUtil.sendAndRemoveCallback(app, Operation.WRITE.getMethod(), pluginResult);
                    }
                } else {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "The device is not connected!");
                    HeytzUtil.sendAndRemoveCallback(app, Operation.WRITE.getMethod(), pluginResult);
                }
            }
        }
        if (!isExist) {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "This device does not exist!");
            HeytzUtil.sendAndRemoveCallback(app, Operation.WRITE.getMethod(), pluginResult);
        }
    }

    private void dealloc() {
        XPGWifiSDK.sharedInstance().setListener(null);
        XPGWifiSDK.sharedInstance().setListener(wifiSDKListener);
    }
}