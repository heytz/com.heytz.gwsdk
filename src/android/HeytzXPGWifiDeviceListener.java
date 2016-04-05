package com.heytz.gwsdk;

import android.util.Log;
import com.xtremeprog.xpgconnect.XPGWifiDevice;
import com.xtremeprog.xpgconnect.XPGWifiDeviceListener;
import com.xtremeprog.xpgconnect.XPGWifiErrorCode;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by chendongdong on 16/3/7.
 */
public class HeytzXPGWifiDeviceListener extends XPGWifiDeviceListener {
    private HeytzApp app;

    @Override
    public void didLogin(XPGWifiDevice device, int result) {
        if (result == XPGWifiErrorCode.XPGWifiError_NONE) {
            if (app.getCallbackContext(Operation.CONTROL_DEVICE.getMethod()) != null) {
                //写入命令字段（所有产品一致）
                try {
                    JSONObject jsonsend = new JSONObject();
                    JSONObject arr = new JSONObject(app.getControlObject().toString());
                    jsonsend.put("cmd", 1);
                    jsonsend.put("entity0", arr);
                    app.getCurrentDevice().write(jsonsend.toString());
                    app.getCallbackContext(Operation.CONTROL_DEVICE.getMethod()).success();
                    app.removeCallbackContext(Operation.CONTROL_DEVICE.getMethod());
                } catch (JSONException e) {
                    app.getCallbackContext(Operation.CONTROL_DEVICE.getMethod()).error(e.getMessage());
                    app.removeCallbackContext(Operation.CONTROL_DEVICE.getMethod());
                }
            }
            if (app.getCallbackContext(Operation.CONNECT.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.OK, HeytzUtil.deviceToJsonObject(device, app.getUid()));
                HeytzUtil.sendAndRemoveCallback(app, Operation.CONNECT.getMethod(), pr);
            }
        } else {
            if (app.getCallbackContext(Operation.CONTROL_DEVICE.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result);
                HeytzUtil.sendAndRemoveCallback(app, Operation.CONTROL_DEVICE.getMethod(), pr);
            }
            if (app.getCallbackContext(Operation.CONNECT.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result);
                HeytzUtil.sendAndRemoveCallback(app, Operation.CONNECT.getMethod(), pr);
            }
        }
    }

    @Override
    public void didDeviceOnline(XPGWifiDevice device, boolean isOnline) {
        Log.d(HeytzApp.TAG, "didDeviceOnline..." + isOnline);
    }

    @Override
    public void didDisconnected(XPGWifiDevice device, int result) {
        if (HeytzApp.DEBUG)
            Log.d(HeytzApp.TAG, "did disconnected...");

        if (result == XPGWifiErrorCode.XPGWifiError_NONE) {
            if (app.getCallbackContext(Operation.DISCONNECT.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.OK, device.getDid());
                HeytzUtil.sendAndRemoveCallback(app, Operation.DISCONNECT.getMethod(), pr);
            }
        } else {
            if (app.getCallbackContext(Operation.DISCONNECT.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result);
                HeytzUtil.sendAndRemoveCallback(app, Operation.DISCONNECT.getMethod(), pr);
            }
        }
    }

    @Override
    public void didReceiveData(XPGWifiDevice device, java.util.concurrent.ConcurrentHashMap<String, Object> dataMap, int result) {

        if (result == XPGWifiErrorCode.XPGWifiError_NONE) {
            //普通数据点类型，有布尔型、整形和枚举型数据，该种类型一般为可读写
            if (dataMap.get("data") != null) {
                Log.i("info", (String) dataMap.get("data"));
            }
            /**
             *  设备报警数据点类型，该种数据点只读，设备发生报警后该字段有内容，没有发生报警则没内容
             *  todo 在ios 中 alerts  在android 中 alters
             */
            if (dataMap.get("alters") != null) {
                Log.i("info", (String) dataMap.get("alters"));
            }
            //设备错误数据点类型，该种数据点只读，设备发生错误后该字段有内容，没有发生报警则没内容
            if (dataMap.get("faults") != null) {
                Log.i("info", (String) dataMap.get("faults"));
            }
            if (app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()) != null) {
                try {
                    JSONObject jsonObject = new JSONObject();
                    if (dataMap.get("data") != null) {
                        JSONObject dataJson = new JSONObject(dataMap.get("data").toString());
                        jsonObject.put("data", dataJson);
                    }
                    if (dataMap.get("alters") != null) {
                        JSONObject altersJson = new JSONObject(dataMap.get("alters").toString());
                        jsonObject.put("alerts", altersJson);
                    }
                    if (dataMap.get("faults") != null) {
                        JSONObject faultsJson = new JSONObject(dataMap.get("alters").toString());
                        jsonObject.put("faults", faultsJson);
                    }
                    jsonObject.put("did", device.getDid());
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonObject);
                    pluginResult.setKeepCallback(true);
                    app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()).sendPluginResult(pluginResult);
                } catch (JSONException e) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, e.getMessage());
                    pluginResult.setKeepCallback(true);
                    app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()).sendPluginResult(pluginResult);
                }
            }
        } else if (result == XPGWifiErrorCode.XPGWifiError_RAW_DATA_TRANSMIT) { // 设备上报的数据内容，result为－48时返回透传数据，binary有值；
            //二进制数据点类型，适合开发者自行解析二进制数据
            if (dataMap.get("binary") != null) {
                Log.i("info", "Binary data:");
            }
            if (app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()) != null) {
                try {
                    JSONObject jsonObject = new JSONObject();
                    if (dataMap.get("binary") != null) {
                        JSONObject faultsJson = new JSONObject(dataMap.get("binary").toString());
                        jsonObject.put("binary", faultsJson);
                    }
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonObject);
                    pluginResult.setKeepCallback(true);
                    app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()).sendPluginResult(pluginResult);
                } catch (JSONException e) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, e.getMessage());
                    pluginResult.setKeepCallback(true);
                    app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()).sendPluginResult(pluginResult);
                }
            }
        } else {

        }
    }

    @Override
    public void didQueryHardwareInfo(XPGWifiDevice device, int result, java.util.concurrent.ConcurrentHashMap<String, String> hardwareInfo) {
        if (app.getCallbackContext(Operation.GET_HARDWARE_INFO.getMethod()) != null) {
            if (result == XPGWifiErrorCode.XPGWifiError_NONE) {
                JSONObject jsonObject = new JSONObject();
                try {
                    // 字符串类型，GAgent模组硬件版本号
                    jsonObject.put("XPGWifiDeviceHardwareWifiHardVerKey", hardwareInfo.get("XPGWifiDeviceHardwareWifiHardVerKey"));
                    // 字符串类型，GAgent模组软件版本号
                    jsonObject.put("XPGWifiDeviceHardwareWifiSoftVerKey", hardwareInfo.get("XPGWifiDeviceHardwareWifiSoftVerKey"));
                    // 字符串类型，设备硬件版本号
                    jsonObject.put("XPGWifiDeviceHardwareMCUHardVerKey", hardwareInfo.get("XPGWifiDeviceHardwareMCUHardVerKey"));
                    // 字符串类型，固件Id
                    jsonObject.put("XPGWifiDeviceHardwareFirmwareIdKey", hardwareInfo.get("XPGWifiDeviceHardwareFirmwareIdKey"));
                    // 字符串类型，固件版本号
                    jsonObject.put("XPGWifiDeviceHardwareFirmwareVerKey", hardwareInfo.get("XPGWifiDeviceHardwareFirmwareVerKey"));
                    // 字符串类型，设备的Productkey
                    jsonObject.put("XPGWifiDeviceHardwareProductKey", hardwareInfo.get("XPGWifiDeviceHardwareProductKey"));
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonObject);
                    HeytzUtil.sendAndRemoveCallback(app, Operation.GET_HARDWARE_INFO.getMethod(), pluginResult);
                } catch (JSONException e) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, e.getMessage());
                    HeytzUtil.sendAndRemoveCallback(app, Operation.GET_HARDWARE_INFO.getMethod(), pluginResult);
                }
            } else {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result);
                HeytzUtil.sendAndRemoveCallback(app, Operation.GET_HARDWARE_INFO.getMethod(), pr);

            }
        }

    }

    public HeytzApp getApp() {
        return app;
    }

    public void setApp(HeytzApp app) {
        this.app = app;
    }
}
