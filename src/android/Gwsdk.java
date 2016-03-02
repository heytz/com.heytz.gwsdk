package com.heytz.gwsdk;

import android.content.Context;
import android.util.Base64;
import android.util.Log;
import com.xtremeprog.xpgconnect.*;
import com.xtremeprog.xpgconnect.XPGWifiSDK.XPGWifiConfigureMode;
import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;


/**
 * This class wrapping Gizwits WifiSDK called from JavaScript.
 */
public class Gwsdk extends CordovaPlugin {

    private HeytzApp app = new HeytzApp();
    private CallbackContext airLinkCallbackContext;
    private Context context;

    private final String TAG = "\n===gwsdkwrapper====\n";
    private Boolean debug = true;            //debug 状态

    //private String _appId;
    //private String _productKey;              //当前的productkey
    //private String _currentDeviceMac;       //当前配对的设备Mac地址.
    //private String _uid;                     //当前用户的uid
//    private String _token;                   //当前用户的token


    private List<XPGWifiDevice> _devicesList;//筛选出来的设备列表
    private Object _controlObject;           //用户控制的值.
    private Boolean _controlState;           //锁定用户的控制状态
    private XPGWifiDevice _currentDevice;     //当前缓存中的device
    private int attempts;                    //尝试次数

    private Operation operation;

    private HeytzXPGWifiSDKListener wifiSDKListener = new HeytzXPGWifiSDKListener();

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        // your init code here
        context = cordova.getActivity().getApplicationContext();
    }

    /**
     * 要初始化监听的listener
     * 如果是第一次加载 那么初始化设置 第一次加载的判断为 是否存在_appId
     */
    private void init(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        String appId = app.getAppID();
        if (appId == null || XPGWifiSDK.sharedInstance() == null) {  //if (_appId == null||XPGWifiSDK.sharedInstance() == null) {
            // set listener
            XPGWifiSDK.sharedInstance().setListener(wifiSDKListener);
        }
        if (appId == null || !args.getString(0).equals(appId)) {
            appId = args.getString(0);
            app.setAppID(appId);
            XPGWifiSDK.sharedInstance().startWithAppID(context, appId);
        }
        wifiSDKListener.setAttempts(2);
        wifiSDKListener.setControlState(true);
        app.setProductKey(args.getString(1)); //this._productKey = args.getString(1);
        wifiSDKListener.setCallbackContext(callbackContext);

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
        //销毁内存中的Listener
        if (action.equals("dealloc")) {
            this.dealloc();
            return true;
        }
        init(args, callbackContext);
        if (action.equals("setDeviceWifi")) {
            GwsdkStateCode.setCurrentState(GwsdkStateCode.SetWifiCode);
            int timeout = args.getInt(4);
            this.setDeviceWifi(args.getString(2), args.getString(3), timeout, callbackContext);
            return true;
        }
        if (action.equals("setDeviceWifiBindDevice")) {
            GwsdkStateCode.setCurrentState(GwsdkStateCode.SetDeviceWifiBindDevice);
            app.setUid(args.getString(4));// _uid = args.getString(4);
            app.setToken(args.getString(5)); //_token = args.getString(5);
            int timeout = args.getInt(6);
            String softAPSSIDPrefix = args.getString(8);

            XPGWifiConfigureMode xpgWifiConfigureMode = XPGWifiConfigureMode.XPGWifiConfigureModeAirLink;
            switch (args.getInt(7)) {
                case 1:
                    xpgWifiConfigureMode = XPGWifiConfigureMode.XPGWifiConfigureModeSoftAP;
                    break;
                case 2:
                    xpgWifiConfigureMode = XPGWifiConfigureMode.XPGWifiConfigureModeAirLink;
                    break;
            }
            this.setDeviceWifiBindDevice(args.getString(2), args.getString(3),
                    xpgWifiConfigureMode,
                    timeout, softAPSSIDPrefix, null
                    , callbackContext);
            return true;
        }
        if (action.equals("getDeviceList")) {
            GwsdkStateCode.setCurrentState(GwsdkStateCode.GetDevcieListCode);
            app.setUid(args.getString(2)); //this._uid = args.getString(2);
            app.setToken(args.getString(5)); //this._token = args.getString(3);
            List<String> products = new ArrayList<String>();
            for (int i = 0; i < args.getJSONArray(1).length(); i++) {
                products.add(args.getJSONArray(1).get(i).toString());
            }
            this.getDeviceList(args.getString(2), args.getString(3), products);
            return true;
        }
        if (action.equals("deviceControl")) {
            GwsdkStateCode.setCurrentState(GwsdkStateCode.ControlCode);
            app.setMac(args.getString(4)); //this._currentDeviceMac = args.getString(4);
            this._controlObject = args.getString(5);
            List<String> products = new ArrayList<String>();
            for (int i = 0; i < args.getJSONArray(1).length(); i++) {
                products.add(args.getJSONArray(1).get(i).toString());
            }
            Log.w("tag", products.toString());
            this.getDeviceList(args.getString(2), args.getString(3), products);
            return true;
        }

        if ("connectDevice".equals(action)) {

            // TODO 链接设备
            System.out.println("connectDevice");

            GwsdkStateCode.setCurrentState(GwsdkStateCode.ConnectDevice);
            app.setMac(args.getString(4)); //this._currentDeviceMac = args.getString(4);
            this._controlObject = args.getString(5);
            List<String> products = new ArrayList<String>();
            for (int i = 0; i < args.getJSONArray(1).length(); i++) {
                products.add(args.getJSONArray(1).get(i).toString());
            }
            Log.w("tag", products.toString());
            this.getDeviceList(args.getString(2), args.getString(3), products);
            return true;
        }

        if ("getDeviceMessage".equals(action)) {
            // TODO 获取设备信息
            System.out.println("getDeviceMessage");
        }

        if ("disconnectDevice".equals(action)) {
            // TODO 断开设备链接
            System.out.println("disconnectDevice");
        }

        if ("sendControlMessage".equals(action)) {
            // TODO 发送控制指令
            System.out.println("sendControlMessage");
        }
        return false;
    }

    /**
     * wifi配对
     *
     * @param wifiSSID
     * @param wifiKey
     * @param callbackContext
     */
    private void setDeviceWifi(String wifiSSID, String wifiKey, int timeout, CallbackContext callbackContext) {
        if (wifiSSID != null && wifiSSID.length() > 0 && wifiKey != null && wifiKey.length() > 0) {
            airLinkCallbackContext = callbackContext;
            //15.11.24 切换成新接口
            XPGWifiSDK.sharedInstance().setDeviceWifi(wifiSSID, wifiKey, XPGWifiConfigureMode.XPGWifiConfigureModeAirLink, null, timeout, null);
        } else {
            callbackContext.error("args is empty or null");
        }
    }

    private void setDeviceWifiBindDevice(String wifiSSID, String wifiKey, XPGWifiConfigureMode mode, int timeout, String softAPSSIDPrefix, List<XPGWifiSDK.XPGWifiGAgentType> types, CallbackContext callbackContext) {
        if (wifiSSID != null && wifiSSID.length() > 0 && wifiKey != null && wifiKey.length() > 0) {
            airLinkCallbackContext = callbackContext;
            //15.11.24 切换成新接口
            XPGWifiSDK.sharedInstance().setDeviceWifi(wifiSSID, wifiKey,
                    mode, softAPSSIDPrefix,
                    timeout, null);
        } else {
            callbackContext.error("args is empty or null");
        }
    }

    /**
     * 获取设备列表
     *
     * @param uid
     * @param token
     * @param productKey
     */
    private void getDeviceList(String uid, String token, List<String> productKey) {
//        XPGWifiSDK.sharedInstance().getBoundDevices(uid, token, productKey);
        XPGWifiSDK.sharedInstance().getBoundDevices(uid, token, productKey);
    }

    private void dealloc() {
        XPGWifiSDK.sharedInstance().setListener(null);
        XPGWifiSDK.sharedInstance().setListener(wifiSDKListener);
        app.setMac(null); //_currentDeviceMac = null;
    }
}

final class GwsdkStateCode {
    private static int CurrentState;
    public static final int SetWifiCode = 0;            //只配对设备
    public static final int GetDevcieListCode = 1;      //发现列表
    public static final int ControlCode = 2;            //控制设备
    public static final int SetDeviceWifiBindDevice = 3;   //配对设备并且绑定设备
    public static final int ConnectDevice = 4;   //连接设备
    public static final int DisconnectDevice = 5; //断开设备
    public static final int SendControlMessage = 6; //发送控制指令
    public static final int GetDeviceMesssage = 7; //获取设备信息

    public static void setCurrentState(int currentState) {
        CurrentState = currentState;
    }

    public static int getCurrentState() {
        return CurrentState;
    }
}