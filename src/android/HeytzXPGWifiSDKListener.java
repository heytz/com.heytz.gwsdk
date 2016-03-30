package com.heytz.gwsdk;

import android.util.Log;
import com.xtremeprog.xpgconnect.*;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

/**
 * Created by chendongdong on 16/3/7.
 */
public class HeytzXPGWifiSDKListener extends XPGWifiSDKListener {
    private HeytzXPGWifiDeviceListener heytzXPGWifiDeviceListener = new HeytzXPGWifiDeviceListener();
    private HeytzApp app;

    //private XPGWifiDevice _currentDevice;
    private int attempts;

    private Object controlObject;           //用户控制的值.

    private boolean controlState;


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
            if (app.getCallbackContext(Operation.SET_DEVICE_WIFI.getMethod()) != null) {
                //如果存在did那么就直接返回成功,现在测试只会返回一次
                if (currentDeviceMac == null && device.getDid().length() > 0) {
                    PluginResult pr = new PluginResult(PluginResult.Status.OK, HeytzUtil.deviceToJsonObject(device, app.getUid()));
                    HeytzUtil.sendAndRemoveCallback(app, Operation.SET_DEVICE_WIFI.getMethod(), pr);
                } else {//否则获取配对到的设备地址,去didDiscovered 等待设备did的信息
                    app.setMac(device.getMacAddress());
                }
            }
            if (app.getCallbackContext(Operation.SET_DEVICE_WIFI_AND_BIND.getMethod()) != null) {
                //如果存在did那么就直接返回成功,现在测试只会返回一次
                if (currentDeviceMac == null && device.getDid().length() > 0) {
                    app.setCurrentDevice(device);
                    XPGWifiSDK.sharedInstance().bindDevice(app.getUid(), app.getToken(), device.getDid(), null, null);
                } else {//否则获取配对到的设备地址,去didDiscovered 等待设备did的信息
                    app.setMac(device.getMacAddress()); //_currentDeviceMac = device.getMacAddress();
                }
            }
        } else {
            //  error:-21 超时
            PluginResult pr = new PluginResult(PluginResult.Status.ERROR, error);
            HeytzUtil.sendAndRemoveCallback(app, Operation.SET_DEVICE_WIFI.getMethod(), pr);
            HeytzUtil.sendAndRemoveCallback(app, Operation.SET_DEVICE_WIFI_AND_BIND.getMethod(), pr);
        }
    }

    @Override
    public void didDiscovered(int result, List<XPGWifiDevice> devicesList) {
        if (result == XPGWifiErrorCode.XPGWifiError_NONE && devicesList.size() > 0) {
            app.setDeviceList(devicesList);
            String currentDeviceMac = app.getMac();
            if (currentDeviceMac != null && app.getCallbackContext(Operation.SET_DEVICE_WIFI.getMethod()) != null) {
                for (int i = 0; i < devicesList.size(); i++) {
                    if (HeytzApp.DEBUG == true) {
                        Log.e("didDiscovered", devicesList.get(i).getMacAddress());
                        Log.e("didDiscovered", devicesList.get(i).getDid());
                        Log.e("didDiscovered", devicesList.get(i).getIPAddress());
                        Log.e("didDiscovered", devicesList.get(i).getProductKey());
                    }
                    //判断did 是否为空
                    if (devicesList.get(i).getDid().length() > 0) {
                        //判断当前设备是否为正在配对的设备(*Mac地址判断),
                        if ((devicesList.get(i).getMacAddress().indexOf(currentDeviceMac) > -1)) {
                            //清空内存中的Mac
                            app.setMac(null);
                            PluginResult pr = new PluginResult(PluginResult.Status.OK, HeytzUtil.deviceToJsonObject(devicesList.get(i), app.getUid()));
                            HeytzUtil.sendAndRemoveCallback(app, Operation.SET_DEVICE_WIFI.getMethod(), pr);
                        }
                    } else {
                        if (HeytzApp.DEBUG)
                            Log.e("====didDiscovered====", "did is null:" + devicesList.get(i).getMacAddress());
                    }
                }
            }
            if (currentDeviceMac != null && app.getCallbackContext(Operation.SET_DEVICE_WIFI_AND_BIND.getMethod()) != null) {
                for (int i = 0; i < devicesList.size(); i++) {
                    HeytzUtil.logDevice("\n=====SetDeviceWifiBindDevic=====\n", devicesList.get(i));
                    //判断did 是否为空
                    if (devicesList.get(i).getDid().length() > 0) {
                        //判断当前设备是否为正在配对的设备(*Mac地址判断),
                        if ((devicesList.get(i).getMacAddress().indexOf(currentDeviceMac) > -1)) {
                            app.setCurrentDevice(devicesList.get(i));
                            if (controlState == true) {
                                controlState = false;
                                XPGWifiSDK.sharedInstance().bindDevice(app.getUid(), app.getToken(), devicesList.get(i).getDid(), null, null);
                            }
                        }
                    }
                }
            }
            if (app.getCallbackContext(Operation.GET_DEVICE_LIST.getMethod()) != null) {
                if (devicesList.size() > 0) {
                    JSONArray cdvResult = new JSONArray();
                    for (int i = 0; i < devicesList.size(); i++) {
                        cdvResult.put(HeytzUtil.deviceToJsonObject(devicesList.get(i), app.getUid()));
                    }
                    PluginResult pr = new PluginResult(PluginResult.Status.OK, cdvResult);
                    pr.setKeepCallback(true);
                    app.getCallbackContext(Operation.GET_DEVICE_LIST.getMethod()).sendPluginResult(pr);
                }
            }
            if (app.getCallbackContext(Operation.START_GET_DEVICE_LIST.getMethod()) != null) {
                if (devicesList.size() > 0) {
                    JSONArray cdvResult = new JSONArray();
                    for (int i = 0; i < devicesList.size(); i++) {
                        cdvResult.put(HeytzUtil.deviceToJsonObject(devicesList.get(i), app.getUid()));
                    }
                    PluginResult pr = new PluginResult(PluginResult.Status.OK, cdvResult);
                    pr.setKeepCallback(true);
                    app.getCallbackContext(Operation.START_GET_DEVICE_LIST.getMethod()).sendPluginResult(pr);
                }
            }
            if (app.getCallbackContext(Operation.CONTROL_DEVICE.getMethod()) != null) {
                Log.d(HeytzApp.TAG, "deviceLoing()");
                deviceLogin(app.getUid(), app.getToken(), currentDeviceMac);
            }
        }
    }

    /**
     * 回调 设备跟用户的绑定
     *
     * @param result
     * @param errorMessage
     * @param did
     */
    @Override
    public void didBindDevice(int result, String errorMessage, String did) {
        if (result == XPGWifiErrorCode.XPGWifiError_NONE) {
            Log.e("\n===binding success===\n", errorMessage + did);
            if (app.getCallbackContext(Operation.SET_DEVICE_WIFI_AND_BIND.getMethod()) != null) {
                //绑定设备成功，登录设备进行控制
                PluginResult pr = new PluginResult(PluginResult.Status.OK, HeytzUtil.deviceToJsonObject(app.getCurrentDevice(), app.getUid()));
                HeytzUtil.sendAndRemoveCallback(app, Operation.SET_DEVICE_WIFI_AND_BIND.getMethod(), pr);

                //清空内存中的Mac
                app.setMac(null);
                app.setCurrentDevice(null);
            }
            if (app.getCallbackContext(Operation.DEVICE_BINDING.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.OK, did);
                HeytzUtil.sendAndRemoveCallback(app, Operation.DEVICE_BINDING.getMethod(), pr);
            }
        } else {
            Log.e("\n===binding error===\n", errorMessage);
            if (app.getCallbackContext(Operation.SET_DEVICE_WIFI_AND_BIND.getMethod()) != null) {
                if (attempts > 0) {
                    controlState = true;
                    attempts -= 1;
                } else {
                    //清空内存中的Mac
                    app.setMac(null); //t_currentDeviceMac = null;
                    app.setCurrentDevice(null);
                    //绑定设备失败，弹出错误信息
                    PluginResult pr = new PluginResult(PluginResult.Status.ERROR, errorMessage);
                    HeytzUtil.sendAndRemoveCallback(app, Operation.SET_DEVICE_WIFI_AND_BIND.getMethod(), pr);
                }
            }
            if (app.getCallbackContext(Operation.DEVICE_BINDING.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, errorMessage);
                HeytzUtil.sendAndRemoveCallback(app, Operation.DEVICE_BINDING.getMethod(), pr);
            }
        }

    }

    /**
     * 回调  解绑设备
     *
     * @param error
     * @param errorMessage
     * @param did
     */
    @Override
    public void didUnbindDevice(int error, String errorMessage, String did) {
        if (error == XPGWifiErrorCode.XPGWifiError_NONE) {
            if (app.getCallbackContext(Operation.UNBIND_DEVICE.getMethod()) != null) {
                //解除绑定设备成功，返回设备列表
                PluginResult pr = new PluginResult(PluginResult.Status.OK, did);
                HeytzUtil.sendAndRemoveCallback(app, Operation.UNBIND_DEVICE.getMethod(), pr);
            }
        } else {
            if (app.getCallbackContext(Operation.UNBIND_DEVICE.getMethod()) != null) {
                //解除绑定设备失败，弹出错误信息
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, errorMessage);
                HeytzUtil.sendAndRemoveCallback(app, Operation.UNBIND_DEVICE.getMethod(), pr);
            }
        }
    }

    /**
     * 获取wifi列表
     *
     * @param error
     * @param ssidInfoList
     */
    @Override
    public void didGetSSIDList(int error, List<XPGWifiSSID> ssidInfoList) {
        if (error == XPGWifiErrorCode.XPGWifiError_NONE) {
            if (app.getCallbackContext(Operation.GET_WIFI_SSID_LIST.getMethod()) != null) {
                JSONArray jsonArray = new JSONArray();
                for (int i = 0; i < ssidInfoList.size(); i++) {
                    jsonArray.put(ssidInfoList.get(i));
                }
                PluginResult pr = new PluginResult(PluginResult.Status.OK, jsonArray);
                HeytzUtil.sendAndRemoveCallback(app, Operation.GET_WIFI_SSID_LIST.getMethod(), pr);
            }
        } else {
            if (app.getCallbackContext(Operation.GET_WIFI_SSID_LIST.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, error);
                HeytzUtil.sendAndRemoveCallback(app, Operation.GET_WIFI_SSID_LIST.getMethod(), pr);
            }
        }

    }

    /**
     * 回调 下载配置文件结果
     *
     * @param error
     * @param productKey
     */
    @Override
    public void didUpdateProduct(int error, String productKey) {
        if (error == XPGWifiErrorCode.XPGWifiError_NONE) {
            PluginResult pr = new PluginResult(PluginResult.Status.OK, productKey);
            app.getCallbackContext(Operation.UPDATE_DEVICE_FROM_SERVER.getMethod()).sendPluginResult(pr);
        } else {
            PluginResult pr = new PluginResult(PluginResult.Status.ERROR, error);
            app.getCallbackContext(Operation.UPDATE_DEVICE_FROM_SERVER.getMethod()).sendPluginResult(pr);
        }
    }

    /**
     * 方法 如果device没有登录那么登录，发送控制命令到cWrite 第二步
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
            app.setCurrentDevice(d);
            heytzXPGWifiDeviceListener.setApp(app);
            d.setListener(heytzXPGWifiDeviceListener);
            //判断这个设备的状态,
            if (!d.isConnected()) {
                (d).login(uid, token);
            } else {//如果设备已经登陆,直接控制.
                JSONObject jsonsend = new JSONObject();
                //写入命令字段（所有产品一致）
                try {
                    JSONObject arr = new JSONObject(app.getControlObject().toString());
                    jsonsend.put("cmd", 1);
                    jsonsend.put("entity0", arr);
                } catch (JSONException e) {

                } finally {
                    d.write(jsonsend.toString());
                    app.getCallbackContext(Operation.CONTROL_DEVICE.getMethod()).success();
                    app.removeCallbackContext(Operation.CONTROL_DEVICE.getMethod());
                }
            }
        }

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
