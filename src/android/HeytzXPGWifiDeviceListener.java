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
            //cWrite(device, controlObject);
            if (app.getCallbackContext(Operation.CONTROL_DEVICE.getMethod()) != null) {
//                cWrite(d, controlObject);
                JSONObject jsonsend = new JSONObject();
                //写入命令字段（所有产品一致）
                try {
                    JSONObject arr = new JSONObject(app.getControlObject().toString());
                    jsonsend.put("cmd", 1);
                    jsonsend.put("entity0", arr);
                } catch (JSONException e) {

                }
                app.getCurrentDevice().write(jsonsend.toString());
                app.getCallbackContext(Operation.CONTROL_DEVICE.getMethod()).success();
                app.removeCallbackContext(Operation.CONTROL_DEVICE.getMethod());
            }
            if (app.getCallbackContext(Operation.CONNECT.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.OK, HeytzUtil.deviceToJsonObject(device, app.getUid()));
                app.getCallbackContext(Operation.CONNECT.getMethod()).sendPluginResult(pr);
                app.removeCallbackContext(Operation.CONNECT.getMethod());
            }
        } else {
            if (app.getCallbackContext(Operation.CONTROL_DEVICE.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result);
                app.getCallbackContext(Operation.CONTROL_DEVICE.getMethod()).sendPluginResult(pr);
                app.removeCallbackContext(Operation.CONTROL_DEVICE.getMethod());
            }
            if (app.getCallbackContext(Operation.CONNECT.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result);
                app.getCallbackContext(Operation.CONNECT.getMethod()).sendPluginResult(pr);
                app.removeCallbackContext(Operation.CONNECT.getMethod());
            }
        }
    }

    @Override
    public void didDeviceOnline(XPGWifiDevice device, boolean isOnline) {
    }

    @Override
    public void didDisconnected(XPGWifiDevice device, int result) {
        if (HeytzApp.DEBUG)
            Log.d(HeytzApp.TAG, "did disconnected...");

        if (result == XPGWifiErrorCode.XPGWifiError_NONE) {
            if (app.getCallbackContext(Operation.DISCONNECT.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.OK, device.getDid());
                app.getCallbackContext(Operation.DISCONNECT.getMethod()).sendPluginResult(pr);
                app.removeCallbackContext(Operation.DISCONNECT.getMethod());
            }
        } else {
            if (app.getCallbackContext(Operation.DISCONNECT.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result);
                app.getCallbackContext(Operation.DISCONNECT.getMethod()).sendPluginResult(pr);
                app.removeCallbackContext(Operation.DISCONNECT.getMethod());
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
            //设备报警数据点类型，该种数据点只读，设备发生报警后该字段有内容，没有发生报警则没内容
            if (dataMap.get("alerts") != null) {
                Log.i("info", (String) dataMap.get("alerts"));

            }
            //设备错误数据点类型，该种数据点只读，设备发生错误后该字段有内容，没有发生报警则没内容
            if (dataMap.get("faults") != null) {
                Log.i("info", (String) dataMap.get("faults"));

            }
            if (app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()) != null) {
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("data", dataMap.get("data"));
                    jsonObject.put("alerts", dataMap.get("alerts"));
                    jsonObject.put("faults", dataMap.get("faults"));
                    jsonObject.put("did", device.getDid());
                } catch (JSONException e) {
                } finally {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonObject);
                    pluginResult.setKeepCallback(true);
                    app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()).sendPluginResult(pluginResult);
                }
            }
            if (app.getCallbackContext(Operation.WRITE.getMethod()) != null) {
                JSONObject data = (JSONObject) dataMap.get("data");
                if (dataMap.get("data") != null && data.has("cmd") != false) {
                    try {
                        if (data.getInt("cmd") == 1) {
                            app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()).success();
                        }
                    } catch (JSONException e) {
                        PluginResult pr = new PluginResult(PluginResult.Status.OK, result);
                        app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()).sendPluginResult(pr);
                    }
                }
            }
        } else if (result == XPGWifiErrorCode.XPGWifiError_RAW_DATA_TRANSMIT) {
            // 设备上报的数据内容，result为－48时返回透传数据，binary有值；
            //二进制数据点类型，适合开发者自行解析二进制数据
            if (dataMap.get("binary") != null) {
                Log.i("info", "Binary data:");
                //收到后自行解析
            }
            if (app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()) != null) {
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("binary", dataMap.get("binary"));
                } catch (JSONException e) {
                } finally {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonObject);
                    pluginResult.setKeepCallback(true);
                    app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()).sendPluginResult(pluginResult);
                }
            }

        }


    }

    @Override
    public void didQueryHardwareInfo(XPGWifiDevice device, int result, java.util.concurrent.ConcurrentHashMap<String, String> hardwareInfo) {
    }

    public HeytzApp getApp() {
        return app;
    }

    public void setApp(HeytzApp app) {
        this.app = app;
    }
}
