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
public class gwsdk extends CordovaPlugin {

    private CallbackContext airLinkCallbackContext;
    private Context context;
    private String _appId;
    private String _productKey;              //当前的productkey
    private String _currentDeviceMac;       //当前配对的设备Mac地址.
    private final String TAG = "\n===gwsdkwrapper====\n";
    private Boolean debug = true;            //debug 状态

    private String _uid;                     //当前用户的uid
    private String _token;                   //当前用户的token


    private List<XPGWifiDevice> _devicesList;//筛选出来的设备列表
    private Object _controlObject;           //用户控制的值.
    private Boolean _controlState;           //锁定用户的控制状态
    private XPGWifiDevice _currentDevice;     //当前缓存中的device
    private int attempts;                    //尝试次数
    private XPGWifiSDKListener wifiSDKListener = new XPGWifiSDKListener() {

        private JSONObject toJSONObjfrom(XPGWifiDevice device) {
            JSONObject json = new JSONObject();
            try {
                json.put("did", device.getDid());
                json.put("macAddress", device.getMacAddress());
                json.put("isLAN", device.isLAN() ? "1" : "0");
                json.put("isOnline", device.isOnline() ? "1" : "0");
                json.put("isConnected", device.isConnected() ? "1" : "0");
                json.put("isDisabled", device.isDisabled() ? "1" : "0");
                json.put("isBind", device.isBind(_uid) ? "1" : "0");
            } catch (JSONException e) {

            }
            return json;
        }


        private Boolean hasDone(List<XPGWifiDevice> deviceList) {
            if (_devicesList == null) return false;
            return _devicesList.size() == deviceList.size();
        }

        private void sendDeviceInfo(XPGWifiDevice device) {
            JSONObject json = new JSONObject();
            try {
                json.put("productKey", device.getProductKey());
                json.put("did", device.getDid());
                json.put("macAddress", device.getMacAddress());
                json.put("passcode", device.getPasscode());
            } catch (JSONException e) {
                if (debug)
                    Log.e("====parseJSON====", e.getMessage());
                //异常处理
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, e.getMessage());
                airLinkCallbackContext.sendPluginResult(pr);
            }
            if (debug)
                Log.e("====didDiscovered====", "success:" + device.getDid());
            //成功的返回
            PluginResult pr = new PluginResult(PluginResult.Status.OK, json);
            airLinkCallbackContext.sendPluginResult(pr);
        }

        /**
         * wifi配对的回调,这个回调不保证可以获取到设备的did
         * 所以我们拿到这个设备的MacAddress,去didDiscovered 等待设备详细的信息反馈,
         * @param error
         * @param device
         */
        @Override
        public void didSetDeviceWifi(int error, XPGWifiDevice device) {
            if (error == XPGWifiErrorCode.XPGWifiError_NONE && device.getMacAddress().length() > 0) {
                logDevice("\n======didsetDeviceWifi======\n", device);
                switch (GwsdkStateCode.getCurrentState()) {
                    case GwsdkStateCode.SetWifiCode:
                        //如果存在did那么就直接返回成功,现在测试只会返回一次
                        if (_currentDeviceMac == null && device.getDid().length() > 0) {
                            sendDeviceInfo(device);
                        } else {//否则获取配对到的设备地址,去didDiscovered 等待设备did的信息
                            _currentDeviceMac = device.getMacAddress();
                        }
                        break;
                    case GwsdkStateCode.SetDeviceWifiBindDevice:
                        //如果存在did那么就直接返回成功,现在测试只会返回一次
                        if (_currentDeviceMac == null && device.getDid().length() > 0) {
                            XPGWifiSDK.sharedInstance().bindDevice(_uid, _token, device.getDid(), null, null);
                        } else {//否则获取配对到的设备地址,去didDiscovered 等待设备did的信息
                            _currentDeviceMac = device.getMacAddress();
                        }
                        break;
                }
            } else if (error == XPGWifiErrorCode.XPGWifiError_CONNECT_TIMEOUT) {
                //超时的回调
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, error);
                airLinkCallbackContext.sendPluginResult(pr);
            } else {
                //设备配对有可能返回多次,这里不做处理.
            }
        }


        @Override
        public void didDiscovered(int result, List<XPGWifiDevice> devicesList) {
            if (result == XPGWifiErrorCode.XPGWifiError_NONE && devicesList.size() > 0) {
                switch (GwsdkStateCode.getCurrentState()) {
                    case GwsdkStateCode.SetWifiCode:
                        //如果当前配对的DeviceMac 存在.
                        if (_currentDeviceMac != null) {
                            for (int i = 0; i < devicesList.size(); i++) {
                                if (debug) {
                                    Log.e("didDiscovered", devicesList.get(i).getMacAddress());
                                    Log.e("didDiscovered", devicesList.get(i).getDid());
                                    Log.e("didDiscovered", devicesList.get(i).getIPAddress());
                                    Log.e("didDiscovered", devicesList.get(i).getProductKey());
                                }
                                //判断did 是否为空
                                if (devicesList.get(i).getDid().length() > 0) {
                                    //判断当前设备是否为正在配对的设备(*Mac地址判断),
                                    if ((devicesList.get(i).getMacAddress().indexOf(_currentDeviceMac) > -1)) {
                                        //清空内存中的Mac
                                        _currentDeviceMac = null;
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
                                    if (debug)
                                        Log.e("====didDiscovered====", "did is null:" + devicesList.get(i).getMacAddress());
                                }
                            }
                        }
                        break;
                    case GwsdkStateCode.GetDevcieListCode:
                        if (hasDone(devicesList)) {
                            JSONArray cdvResult = new JSONArray();
                            for (int i = 0; i < devicesList.size(); i++) {
                                cdvResult.put(toJSONObjfrom(devicesList.get(i)));
                            }
                            _devicesList = null;
                            airLinkCallbackContext.success(cdvResult);

                        } else {
                            _devicesList = devicesList;
                        }
                        break;
                    case GwsdkStateCode.ControlCode:
                        _devicesList = devicesList;
                        deviceLogin(_uid, _token, _currentDeviceMac);
                        Log.d(TAG, "deviceLoing()");
                        break;
                    case GwsdkStateCode.SetDeviceWifiBindDevice:
                        //如果当前配对的DeviceMac 存在.
                        if (_currentDeviceMac != null) {
                            for (int i = 0; i < devicesList.size(); i++) {
                                logDevice("\n=====SetDeviceWifiBindDevic=====\n", devicesList.get(i));
                                //判断did 是否为空
                                if (devicesList.get(i).getDid().length() > 0) {
                                    //判断当前设备是否为正在配对的设备(*Mac地址判断),
                                    if ((devicesList.get(i).getMacAddress().indexOf(_currentDeviceMac) > -1)) {
                                        _currentDevice = devicesList.get(i);
                                        if (_controlState == true) {
                                            _controlState = false;
                                            XPGWifiSDK.sharedInstance().bindDevice(_uid, _token, devicesList.get(i).getDid(), null, null);
                                        }
                                    }
                                }
                            }
                        }
                        break;
                    default:

                }
            }
        }

        @Override
        public void didBindDevice(int result, String errorMessage, String did) {
            if (result == XPGWifiErrorCode.XPGWifiError_NONE) {
                Log.e("\n===binding success===\n", errorMessage + did);

                //绑定设备成功，登录设备进行控制
                PluginResult pr = new PluginResult(PluginResult.Status.OK, deviceToJsonObject(_currentDevice));
                airLinkCallbackContext.sendPluginResult(pr);
                //清空内存中的Mac
                _currentDeviceMac = null;
                _currentDevice = null;
            } else {
                Log.e("\n===binding error===\n", errorMessage);
                if (attempts > 0) {
                    _controlState = true;
                    --attempts;
                } else {
                    //清空内存中的Mac
                    _currentDeviceMac = null;
                    _currentDevice = null;
                    //绑定设备失败，弹出错误信息
                    PluginResult pr = new PluginResult(PluginResult.Status.ERROR, errorMessage);
                    airLinkCallbackContext.sendPluginResult(pr);
                }
            }

        }
    };


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
        if (_appId == null||XPGWifiSDK.sharedInstance() == null) {
            // set listener
            XPGWifiSDK.sharedInstance().setListener(wifiSDKListener);
        }
        if(_appId==null||!args.getString(0).equals(_appId)){
            _appId = args.getString(0);
            XPGWifiSDK.sharedInstance().startWithAppID(context, _appId);
        }

        attempts = 2;
        _controlState = true;
        this._productKey = args.getString(1);
        this.airLinkCallbackContext = callbackContext;

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
            this.setDeviceWifi(args.getString(2), args.getString(3), callbackContext);
            return true;
        }
        if (action.equals("setDeviceWifiBindDevice")) {
            GwsdkStateCode.setCurrentState(GwsdkStateCode.SetDeviceWifiBindDevice);
            _uid = args.getString(4);
            _token = args.getString(5);
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
            this._uid = args.getString(2);
            this._token = args.getString(3);
            List<String> products = new ArrayList<String>();
            for (int i = 0; i < args.getJSONArray(1).length(); i++) {
                products.add(args.getJSONArray(1).get(i).toString());
            }
            this.getDeviceList(args.getString(2), args.getString(3), products);
            return true;
        }
        if (action.equals("deviceControl")) {
            GwsdkStateCode.setCurrentState(GwsdkStateCode.ControlCode);
            this._currentDeviceMac = args.getString(4);
            this._controlObject = args.getString(5);
            List<String> products = new ArrayList<String>();
            for (int i = 0; i < args.getJSONArray(1).length(); i++) {
                products.add(args.getJSONArray(1).get(i).toString());
            }
            Log.w("tag", products.toString());
            this.getDeviceList(args.getString(2), args.getString(3), products);
            return true;
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
    private void setDeviceWifi(String wifiSSID, String wifiKey, CallbackContext callbackContext) {
        if (wifiSSID != null && wifiSSID.length() > 0 && wifiKey != null && wifiKey.length() > 0) {
            airLinkCallbackContext = callbackContext;
            //15.11.24 切换成新接口
            XPGWifiSDK.sharedInstance().setDeviceWifi(wifiSSID, wifiKey, XPGWifiConfigureMode.XPGWifiConfigureModeAirLink, null, 18000, null);
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

    /**
     * 如果device没有登录那么登录，发送控制命令到cWrite 第二步
     *
     * @param uid
     * @param token
     * @param mac
     */
    private void deviceLogin(String uid, String token, String mac) {

        XPGWifiDevice d = null;
        for (int i = 0; i < _devicesList.size(); i++) {
            XPGWifiDevice device = _devicesList.get(i);
            if (device != null) {
                if (debug)
                    Log.w(TAG, device.getMacAddress());
                if (device != null && device.getMacAddress().equals(mac.toUpperCase())) {
                    d = device;
                    break;
                }
            }
        }

        if (d != null && _controlState == true) {
            _controlState = false;
            //判断这个设备的状态,
            if (!d.isConnected()) {
                (d).login(uid, token);

                d.setListener(new XPGWifiDeviceListener() {
                    @Override
                    public void didLogin(XPGWifiDevice device, int result) {
                        cWrite(device, _controlObject);
                    }

                    @Override
                    public void didDeviceOnline(XPGWifiDevice device, boolean isOnline) {
                    }

                    @Override
                    public void didDisconnected(XPGWifiDevice device, int result) {
                        if (debug)
                            Log.d(TAG, "did disconnected...");
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
                cWrite(d, _controlObject);
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
                jsonparam.put(jsonKey, getData(jsonValue));
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
            airLinkCallbackContext.success("success");
        } catch (JSONException e) {
            if (debug)
                e.printStackTrace();
            airLinkCallbackContext.error("error");
        }
    }

    /**
     * string 转换成base64
     *
     * @param str
     * @return
     */
    public static String getData(String str) {
        return new String(Base64.encode(StringToBytes(str), Base64.NO_WRAP));
    }

    /**
     * 字符串转换成byte[]
     *
     * @param paramString
     * @return
     */
    public static byte[] StringToBytes(String paramString) {
        byte[] arrayOfByte = new byte[paramString.length() / 2];
        for (int i = 0; ; i += 2) {
            if (i >= paramString.length())
                return arrayOfByte;
            String str = paramString.substring(i, i + 2);
            arrayOfByte[(i / 2)] = ((byte) Integer.valueOf(str, 16).intValue());
        }
    }


    private void dealloc() {
        XPGWifiSDK.sharedInstance().setListener(null);
        XPGWifiSDK.sharedInstance().setListener(wifiSDKListener);
        _currentDeviceMac = null;
    }

    public JSONObject deviceToJsonObject(XPGWifiDevice device) {
        JSONObject json = new JSONObject();
        try {
            json.put("productKey", device.getProductKey());
            json.put("did", device.getDid());
            json.put("macAddress", device.getMacAddress());
            json.put("passcode", device.getPasscode());
        } catch (JSONException e) {

        }
        return json;
    }

    public void logDevice(String map, XPGWifiDevice device) {
        if (debug) {
            Log.e(map, device.getMacAddress());
            Log.e(map, device.getDid());
            Log.e(map, device.getIPAddress());
            Log.e(map, device.getProductKey());
        }
    }
}

final class GwsdkStateCode {
    private static int CurrentState;
    public static final int SetWifiCode = 0;            //只配对设备
    public static final int GetDevcieListCode = 1;      //发现列表
    public static final int ControlCode = 2;            //控制设备
    public static final int SetDeviceWifiBindDevice = 3;   //配对设备并且绑定设备

    public static void setCurrentState(int currentState) {
        CurrentState = currentState;
    }

    public static int getCurrentState() {
        return CurrentState;
    }
}