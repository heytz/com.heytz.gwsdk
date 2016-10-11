package com.heytz.gwsdk;

import com.gizwits.gizwifisdk.api.GizWifiDevice;
import com.gizwits.gizwifisdk.api.GizWifiSDK;
import com.gizwits.gizwifisdk.enumration.GizWifiConfigureMode;
import com.gizwits.gizwifisdk.enumration.GizWifiGAgentType;
import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;


/**
 * This class wrapping Gizwits WifiSDK called from JavaScript.
 */
public class Gwsdk extends CordovaPlugin {
    private static final String GIZ_APP_ID = "gizwappid";
    private HeytzApp app = new HeytzApp();
    private HeytzGizWifiSDKListener heytzGizWifiSDKListener = new HeytzGizWifiSDKListener();
    private HeytzGizWifiDeviceListener heytzGizWifiDeviceListener = new HeytzGizWifiDeviceListener();


    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        //设置appId
        String appId = webView.getPreferences().getString(GIZ_APP_ID, "");
        GizWifiSDK.sharedInstance().startWithAppID(cordova.getActivity().getApplicationContext(), appId);
        GizWifiSDK.sharedInstance().setListener(heytzGizWifiSDKListener);
        heytzGizWifiSDKListener.setApp(app);
        app.setDeviceList(GizWifiSDK.sharedInstance().getDeviceList());
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

        //配对上网[wifiSSID, wifiKey, mode, timeout, softAPSSIDPrefix, wifiGAgentType]
        if (action.equals(Operation.SET_DEVICE_ON_BOARDING.getMethod())) {
            app.setCallbackContext(Operation.SET_DEVICE_ON_BOARDING.getMethod(), callbackContext);
            String ssid = args.getString(0);
            String pwd = args.getString(1);
            int mode = args.getInt(2);
            int timeout = args.getInt(3);
            GizWifiConfigureMode wifiConfigMode = GizWifiConfigureMode.GizWifiAirLink;
            if (mode == 2) {
                wifiConfigMode = GizWifiConfigureMode.GizWifiSoftAP;
            }
            String softAppSSIDPrefix = args.getString(4);
            List<GizWifiGAgentType> list = new ArrayList<GizWifiGAgentType>();
            JSONArray wifigagentTypeArray = args.getJSONArray(5);
            for (int i = 0; i < wifigagentTypeArray.length(); i++) {
                list.add(HeytzGizWifiGAgentType.getHeytzGizWifiGAgentType(wifigagentTypeArray.getInt(i)));
            }
            this.setDeviceOnboarding(ssid, pwd, wifiConfigMode
                    , softAppSSIDPrefix, timeout, list);
            return true;
        }
        //wifiSSID, wifiKey, mode, timeout, softAPSSIDPrefix, wifiGAgentType,
        // uid, token, device_remark, device_alias, productSecret,
        if (action.equals(Operation.SET_DEVICE_ON_BOARDING_AND_BIND_DEVICE.getMethod())) {
            app.setCallbackContext(Operation.SET_DEVICE_ON_BOARDING_AND_BIND_DEVICE.getMethod(), callbackContext);
            String ssid = args.getString(0);
            String pwd = args.getString(1);
            int mode = args.getInt(2);
            int timeout = args.getInt(3);
            String softAppSSIDPrefix = args.isNull(4) ? null : args.getString(4);

            JSONArray wifigagentTypeArray = args.getJSONArray(5);
            app.setUid(args.getString(6));
            app.setToken(args.getString(7));
            String productSecret = args.getString(8);
            app.setProductSecret(productSecret);
            GizWifiConfigureMode wifiConfigMode = GizWifiConfigureMode.GizWifiAirLink;
            if (mode == 2) {
                wifiConfigMode = GizWifiConfigureMode.GizWifiSoftAP;
            }
            List<GizWifiGAgentType> list = new ArrayList<GizWifiGAgentType>();

            for (int i = 0; i < wifigagentTypeArray.length(); i++) {
                list.add(HeytzGizWifiGAgentType.getHeytzGizWifiGAgentType(wifigagentTypeArray.getInt(i)));
            }
            this.setDeviceOnboarding(ssid, pwd, wifiConfigMode
                    , softAppSSIDPrefix, timeout, list);
            return true;
        }
        if (action.equals(Operation.GET_BOUND_DEVICES.getMethod())) {
            app.setCallbackContext(Operation.GET_BOUND_DEVICES.getMethod(), callbackContext);
            app.setUid(args.getString(0));
            app.setToken(args.getString(1));
            List<String> products = new ArrayList<String>();
            for (int i = 0; i < args.getJSONArray(2).length(); i++) {
                products.add(args.getJSONArray(2).getString(i));
            }
            app.seProductKeys(products);
            this.getBoundDevices(args.getString(0), args.getString(1), products);
            return true;
        }
        if (action.equals(Operation.BIND_REMOTE_DEVICE.getMethod())) {
            app.setCallbackContext(Operation.BIND_REMOTE_DEVICE.getMethod(), callbackContext);
            GizWifiSDK.sharedInstance().bindRemoteDevice(args.getString(0), args.getString(1), args.getString(2)
                    , args.getString(3), args.getString(4));
            return true;
        }
        if (action.equals(Operation.SET_CUSTOM_INFO.getMethod())) {
            app.setCallbackContext(Operation.GET_BOUND_DEVICES.getMethod(), callbackContext);
            this.setCustomInfo(args.getString(0), args.getString(1), args.getString(2));
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
            app.setUid(uid);
            app.setToken(token);
            GizWifiSDK.sharedInstance().unbindDevice(uid, token, did);
            return true;
        }
        /**
         * 订阅 设备
         */
        if (action.equals(Operation.SET_SUBSCRIBE.getMethod())) {
            app.setCallbackContext(Operation.SET_SUBSCRIBE.getMethod(), callbackContext);
            this.setSubscribe(args.getString(0), args.getBoolean(1));
            return true;
        }
        /**
         * 获取 WiFi_SSID
         */
        if (action.equals(Operation.GET_WIFI_SSID_LIST.getMethod())) {
            app.setCallbackContext(Operation.GET_WIFI_SSID_LIST.getMethod(), callbackContext);
            GizWifiSDK.sharedInstance().getSSIDList();
            return true;
        }
        if (action.equals(Operation.START_DEVICE_LISTENER.getMethod())) {
            app.setCallbackContext(Operation.START_DEVICE_LISTENER.getMethod(), callbackContext);
            return true;
        }
        if (action.equals(Operation.STOP_DEVICE_LISTENER.getMethod())) {
            app.removeCallbackContext(Operation.START_DEVICE_LISTENER.getMethod());
            callbackContext.success();
            return true;
        }
        if (action.equals(Operation.WRITE.getMethod())) {
            app.setCallbackContext(Operation.WRITE.getMethod(), callbackContext);
            String did = args.getString(0);
            this.write(did, args.getJSONObject(1));
            return true;
        }
        if (action.equals(Operation.GET_HARDWARE_INFO.getMethod())) {
            app.setCallbackContext(Operation.GET_HARDWARE_INFO.getMethod(), callbackContext);
            String did = args.getString(0);
            this.getHardwareInfo(did);
            return true;
        }
        //销毁内存中的Listener
        if (action.equals(Operation.DEALLOC.getMethod())) {
            this.dealloc();
            return true;
        }
        return false;
    }

    private void setDeviceOnboarding(String wifiSSID, String wifiKey, GizWifiConfigureMode mode,
                                     String softAPSSIDPrefix, int timeout, List<GizWifiGAgentType> types) {
        if (wifiSSID != null && wifiSSID.length() > 0 && wifiKey != null && wifiKey.length() > 0) {
            GizWifiSDK.sharedInstance().setDeviceOnboarding(wifiSSID, wifiKey, mode, softAPSSIDPrefix, timeout, types);
        } else {
            if (app.getCallbackContext(Operation.SET_DEVICE_ON_BOARDING.getMethod()) != null) {
                app.getCallbackContext(Operation.SET_DEVICE_ON_BOARDING.getMethod()).error("args is empty or null");
                app.removeCallbackContext(Operation.SET_DEVICE_ON_BOARDING.getMethod());
            }
            if (app.getCallbackContext(Operation.SET_DEVICE_ON_BOARDING_AND_BIND_DEVICE.getMethod()) != null) {
                app.getCallbackContext(Operation.SET_DEVICE_ON_BOARDING_AND_BIND_DEVICE.getMethod()).error("args is empty or null");
                app.removeCallbackContext(Operation.SET_DEVICE_ON_BOARDING_AND_BIND_DEVICE.getMethod());
            }
        }
    }

    private void getBoundDevices(String uid, String token, List<String> productKey) {
        GizWifiSDK.sharedInstance().getBoundDevices(uid, token, productKey);
    }

    private void setCustomInfo(String did, String remark, String alias) {
        List<GizWifiDevice> list = app.getDeviceList();
        boolean isExist = false;
        for (GizWifiDevice gizWifiDevice : list) {
            if (gizWifiDevice.getDid().equals(did)) {
                isExist = true;
                app.setCurrentDevice(gizWifiDevice);
                heytzGizWifiDeviceListener.setApp(app);
                gizWifiDevice.setListener(heytzGizWifiDeviceListener);
                gizWifiDevice.setCustomInfo(remark, alias);
            }
        }
        if (!isExist) {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "This device does not exist!");
            app.getCallbackContext(Operation.SET_CUSTOM_INFO.getMethod()).sendPluginResult(pluginResult);
            app.removeCallbackContext(Operation.SET_CUSTOM_INFO.getMethod());
        }
    }

    private void setSubscribe(String did, Boolean isSub) {
        List<GizWifiDevice> list = app.getDeviceList();
        boolean isExist = false;
        for (GizWifiDevice gizWifiDevice : list) {
            if (gizWifiDevice.getDid().equals(did)) {
                isExist = true;
                app.setCurrentDevice(gizWifiDevice);
                heytzGizWifiDeviceListener.setApp(app);
                gizWifiDevice.setListener(heytzGizWifiDeviceListener);
                gizWifiDevice.setSubscribe(isSub);
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
    private void write(String did, JSONObject jsonObject) throws JSONException {
        List<GizWifiDevice> list = app.getDeviceList();
        boolean isExist = false;
        for (GizWifiDevice gizWifiDevice : list) {
            if (gizWifiDevice.getDid().equals(did)) {
                isExist = true;
                app.setCurrentDevice(gizWifiDevice);
                heytzGizWifiDeviceListener.setApp(app);
                gizWifiDevice.setListener(heytzGizWifiDeviceListener);
                gizWifiDevice.write(HeytzUtil.jsonToMap(jsonObject), 1);
            }
        }
        if (!isExist) {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "This device does not exist!");
            app.getCallbackContext(Operation.GET_HARDWARE_INFO.getMethod()).sendPluginResult(pluginResult);
            app.removeCallbackContext(Operation.GET_HARDWARE_INFO.getMethod());
        }
    }

    private void getHardwareInfo(String did) {
        List<GizWifiDevice> list = app.getDeviceList();
        boolean isExist = false;
        for (GizWifiDevice gizWifiDevice : list) {
            if (gizWifiDevice.getDid().equals(did)) {
                isExist = true;
                app.setCurrentDevice(gizWifiDevice);
                heytzGizWifiDeviceListener.setApp(app);
                gizWifiDevice.setListener(heytzGizWifiDeviceListener);
                gizWifiDevice.getHardwareInfo();
            }
        }
        if (!isExist) {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "This device does not exist!");
            app.getCallbackContext(Operation.GET_HARDWARE_INFO.getMethod()).sendPluginResult(pluginResult);
            app.removeCallbackContext(Operation.GET_HARDWARE_INFO.getMethod());
        }
    }


    private void dealloc() {
        GizWifiSDK.sharedInstance().setListener(null);
        GizWifiSDK.sharedInstance().setListener(heytzGizWifiSDKListener);
    }
}