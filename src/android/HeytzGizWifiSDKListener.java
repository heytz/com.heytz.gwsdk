package com.heytz.gwsdk;

import android.util.Log;
import com.gizwits.gizwifisdk.api.GizWifiDevice;
import com.gizwits.gizwifisdk.api.GizWifiSDK;
import com.gizwits.gizwifisdk.api.GizWifiSSID;
import com.gizwits.gizwifisdk.enumration.GizWifiErrorCode;
import com.gizwits.gizwifisdk.listener.GizWifiSDKListener;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

/**
 * Created by chendongdong on 16/9/1.
 */
public class HeytzGizWifiSDKListener extends GizWifiSDKListener {
    private HeytzGizWifiDeviceListener heytzGizWifiDeviceListener = new HeytzGizWifiDeviceListener();
    private HeytzApp app;

    @Override
    public void didSetDeviceOnboarding(GizWifiErrorCode result, String mac, String did, String productKey) {
        super.didSetDeviceOnboarding(result, mac, did, productKey);
        if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
            app.setMac(mac);
            app.setProductKey(productKey);
            // 配置成功
            if (app.getCallbackContext(Operation.SET_DEVICE_ON_BOARDING.getMethod()) != null) {
                JSONObject json = new JSONObject();
                try {
                    json.put("macAddress", mac);
                    json.put("did", did);
                    json.put("productKey", productKey);
                } catch (JSONException e) {
                }
                PluginResult pr = new PluginResult(PluginResult.Status.OK, json);
                HeytzUtil.sendAndRemoveCallback(app, Operation.SET_DEVICE_ON_BOARDING.getMethod(), pr);
            }
            if (app.getCallbackContext(Operation.SET_DEVICE_ON_BOARDING_AND_BIND_DEVICE.getMethod()) != null) {
                GizWifiSDK.sharedInstance().bindRemoteDevice(app.getUid(),
                        app.getToken(), mac,
                        productKey,
                        app.getProductSecret());
            }
        } else {
            // 配置失败
            PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result == null ? 0 : result.getResult());
            if (app.getCallbackContext(Operation.SET_DEVICE_ON_BOARDING.getMethod()) != null) {
                HeytzUtil.sendAndRemoveCallback(app, Operation.SET_DEVICE_ON_BOARDING.getMethod(), pr);
            }
            if (app.getCallbackContext(Operation.SET_DEVICE_ON_BOARDING_AND_BIND_DEVICE.getMethod()) != null) {
                HeytzUtil.sendAndRemoveCallback(app, Operation.SET_DEVICE_ON_BOARDING_AND_BIND_DEVICE.getMethod(), pr);
            }
        }
    }

    /**
     * 非局域网设备绑定
     * APP可以通过设备的mac、productKey、productSecret完成非局域网设备的绑定,可以用上述信息生成二维码，
     * APP通过扫码方式绑定。GPRS设备、蓝牙设备等都是无法通过Wifi局域网发现的设备，都属于非局域网设备。
     *
     * @param result
     * @param did
     */
    @Override
    public void didBindDevice(GizWifiErrorCode result, String did) {
        super.didBindDevice(result, did);
        PluginResult pr;
        if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
            // 绑定成功
            JSONObject json = new JSONObject();
            try {
                json.put("macAddress", app.getMac());
                json.put("did", did);
                json.put("productKey", app.getProductKey());
            } catch (JSONException e) {
            }
            pr = new PluginResult(PluginResult.Status.OK, json);
        } else {
            // 绑定失败
            pr = new PluginResult(PluginResult.Status.ERROR, result == null ? 0 : result.getResult());
        }
        if (app.getCallbackContext(Operation.SET_DEVICE_ON_BOARDING_AND_BIND_DEVICE.getMethod()) != null) {
            HeytzUtil.sendAndRemoveCallback(app, Operation.SET_DEVICE_ON_BOARDING_AND_BIND_DEVICE.getMethod(), pr);
        }
        if (app.getCallbackContext(Operation.BIND_REMOTE_DEVICE.getMethod()) != null) {
            HeytzUtil.sendAndRemoveCallback(app, Operation.BIND_REMOTE_DEVICE.getMethod(), pr);
        }
    }

    /**
     * 设备解绑
     * <p>
     * 已绑定的设备可以解绑，解绑需要APP调用接口完成操作，SDK不支持自动解绑。对于已订阅的设备，解绑成功时会被解除订阅，同时断开设备连接，
     * 设备状态也不会再主动上报了。设备解绑后，APP刷新绑定设备列表时就得不到该设备了。
     *
     * @param result
     * @param did
     */
    @Override
    public void didUnbindDevice(GizWifiErrorCode result, String did) {
        super.didUnbindDevice(result, did);
        if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
            // 解绑成功
            if (app.getCallbackContext(Operation.UNBIND_DEVICE.getMethod()) != null) {
                //解除绑定设备成功，返回设备列表
                PluginResult pr = new PluginResult(PluginResult.Status.OK, did);
                HeytzUtil.sendAndRemoveCallback(app, Operation.UNBIND_DEVICE.getMethod(), pr);
            }
        } else {
            // 解绑失败
            if (app.getCallbackContext(Operation.UNBIND_DEVICE.getMethod()) != null) {
                //解除绑定设备失败，弹出错误信息
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result == null ? 0 : result.getResult());
                HeytzUtil.sendAndRemoveCallback(app, Operation.UNBIND_DEVICE.getMethod(), pr);
            }
        }
    }

    /**
     * APP设置好监听，启动SDK后，就可以收到SDK的设备列表推送。每次局域网设备或者用户绑定设备发生变化时，SDK都会主动上报最新的设备列表。设备断电再上电、有新设备上线等都会触发设备列表发生变化。用户登录后，SDK会主动把用户已绑定的设备列表上报给APP，绑定设备在不同的手机上登录帐号都可获取到。
     * <p>
     * 如果APP想要刷新绑定设备列表，可以调用绑定设备列表接口，同时可以指定自己关心的产品类型标识，SDK会把筛选后的设备列表返回给APP。
     * <p>
     * SDK提供设备列表缓存，设备列表中的设备对象在整个APP生命周期中一直有效。缓存的设备列表会与当前最新的已发现设备同步更新。
     *
     * @param result
     * @param deviceList
     */
    @Override
    public void didDiscovered(GizWifiErrorCode result, List<GizWifiDevice> deviceList) {
        super.didDiscovered(result, deviceList);
        // 提示错误原因
        if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
            if (app.getCallbackContext(Operation.GET_BOUND_DEVICES.getMethod()) != null) {
                JSONArray cdvResult = new JSONArray();
                for (int i = 0; i < deviceList.size(); i++) {
                    cdvResult.put(HeytzUtil.gizDeviceToJsonObject(deviceList.get(i)));
                }
                PluginResult pr = new PluginResult(PluginResult.Status.OK, cdvResult);
                pr.setKeepCallback(true);
                app.getCallbackContext(Operation.GET_BOUND_DEVICES.getMethod()).sendPluginResult(pr);
            }
        } else {
            Log.d("", "result: " + result.name());
        }
        // 显示变化后的设备列表
        Log.d("", "discovered deviceList: " + deviceList);
        app.setDeviceList(deviceList);
    }


    /**
     * @param result
     * @param ssidInfoList
     */
    @Override
    public void didGetSSIDList(GizWifiErrorCode result, List<GizWifiSSID> ssidInfoList) {
        super.didGetSSIDList(result, ssidInfoList);
        if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
            if (app.getCallbackContext(Operation.GET_WIFI_SSID_LIST.getMethod()) != null) {
                JSONArray jsonArray = new JSONArray();
                for (GizWifiSSID aSsidInfoList : ssidInfoList) {
                    jsonArray.put(aSsidInfoList);
                }
                PluginResult pr = new PluginResult(PluginResult.Status.OK, jsonArray);
                HeytzUtil.sendAndRemoveCallback(app, Operation.GET_WIFI_SSID_LIST.getMethod(), pr);
            }
        } else {
            if (app.getCallbackContext(Operation.GET_WIFI_SSID_LIST.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result == null ? 0 : result.getResult());
                HeytzUtil.sendAndRemoveCallback(app, Operation.GET_WIFI_SSID_LIST.getMethod(), pr);
            }
        }
    }

    /**
     * @param result
     * @param productKey
     * @param productUI
     */
    @Override
    public void didUpdateProduct(GizWifiErrorCode result, String productKey, String productUI) {
        super.didUpdateProduct(result, productKey, productUI);
        if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {

        } else {

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
}
