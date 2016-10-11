package com.heytz.gwsdk;

import com.gizwits.gizwifisdk.api.GizWifiDevice;
import com.gizwits.gizwifisdk.enumration.GizWifiErrorCode;
import com.gizwits.gizwifisdk.listener.GizWifiDeviceListener;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by chendongdong on 16/9/1.
 */
public class HeytzGizWifiDeviceListener extends GizWifiDeviceListener {
    private HeytzApp app;

    /**
     * 发送控制指令
     * 设备订阅变成可控状态后，APP可以发送操作指令。操作指令是字典格式，键值对为数据点名称和值。操作指令的确认回复，通过didReceiveData回调返回。
     * <p>
     * APP下发操作指令时可以指定sn，通过回调参数中的sn能够对应到下发指令是否发送成功了。但回调参数dataMap有可能是空字典，这取决于设备回复时是否携带当前数据点的状态。
     * <p>
     * 如果APP下发指令后只关心是否有设备状态上报，那么下发指令的sn可填0，这时回调参数sn也为0。
     *
     * @param result
     * @param device
     * @param dataMap
     * @param sn
     */
    @Override
    public void didReceiveData(GizWifiErrorCode result, GizWifiDevice device,
                               ConcurrentHashMap<String, Object> dataMap, int sn) {
        // 如果App不使用sn，此处不需要判断sn
        if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
            JSONObject jsonObject = new JSONObject();
            try {
                // 其他命令的ack或者数据上报
                // 已定义的设备数据点，有布尔、数值和枚举型数据
                if (dataMap.get("data") != null) {
                    JSONObject dataJson = new JSONObject(dataMap.get("data").toString());
                    jsonObject.put("data", dataJson);
                    // 扩展数据点，key如果是“BBBB”
                  //  byte[] bytes = (byte[]) dataJson.get("BBBB");
                }
                // 已定义的设备故障数据点，设备发生故障后该字段有内容，没有发生故障则没内容

                if (dataMap.get("alerts") != null) {
                    JSONObject altersJson = new JSONObject(dataMap.get("alerts").toString());
                    jsonObject.put("alerts", altersJson);
                }
                // 已定义的设备报警数据点，设备发生报警后该字段有内容，没有发生报警则没内容

                if (dataMap.get("faults") != null) {
                    JSONObject faultsJson = new JSONObject(dataMap.get("faults").toString());
                    jsonObject.put("faults", faultsJson);
                }
                // 透传数据，无数据点定义，适合开发者自行定义协议自行解析
                if (dataMap.get("binary") != null) {
                    byte[] binary = (byte[]) dataMap.get("binary");
                    jsonObject.put("binary", binary);
                }
                jsonObject.put("did", device.getDid());
                jsonObject.put("device", HeytzUtil.gizDeviceToJsonObject(device));

            } catch (JSONException e) {
            }
            if (sn == 1) {
                // 命令序号相符，开灯指令执行成功
                if (app.getCallbackContext(Operation.WRITE.getMethod()) != null) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonObject);
                    app.getCallbackContext(Operation.WRITE.getMethod()).sendPluginResult(pluginResult);
                }
            } else {
                if (app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()) != null) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonObject);
                    pluginResult.setKeepCallback(true);
                    app.getCallbackContext(Operation.START_DEVICE_LISTENER.getMethod()).sendPluginResult(pluginResult);
                }
            }
        } else {
            // 操作失败
            if (sn == 1) {
                if (app.getCallbackContext(Operation.WRITE.getMethod()) != null) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, result.getResult());
                    app.getCallbackContext(Operation.WRITE.getMethod()).sendPluginResult(pluginResult);
                }
            }
        }
    }

    /**
     * 设备订阅
     * 所有通过SDK得到的设备，都可以订阅，订阅结果通过回调返回。订阅成功的设备，要在其网络状态变为可控时才能查询状态和下发控制指令。
     *
     * @param result
     * @param device
     * @param isSubscribed
     */
    @Override
    public void didSetSubscribe(GizWifiErrorCode result, GizWifiDevice device, boolean isSubscribed) {
        if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
            // 订阅或解除订阅成功
            if (app.getCallbackContext(Operation.SET_SUBSCRIBE.getMethod()) != null) {
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, HeytzUtil.gizDeviceToJsonObject(device));
                HeytzUtil.sendAndRemoveCallback(app, Operation.SET_SUBSCRIBE.getMethod(), pluginResult);
            }
        } else {
            // 失败
            if (app.getCallbackContext(Operation.SET_SUBSCRIBE.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result.getResult());
                HeytzUtil.sendAndRemoveCallback(app, Operation.SET_SUBSCRIBE.getMethod(), pr);
            }
        }
    }

    /**
     * 设置设备的绑定信息
     * 不订阅设备也可以设置设备的绑定信息。在设备列表中找到要修改的设备，如果是已绑定的，可以修改remark和alias信息。
     *
     * @param result
     * @param device
     */
    @Override
    public void didSetCustomInfo(GizWifiErrorCode result, GizWifiDevice device) {
        if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
            // 修改成功
            if (app.getCallbackContext(Operation.SET_CUSTOM_INFO.getMethod()) != null) {
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, HeytzUtil.gizDeviceToJsonObject(device));
                HeytzUtil.sendAndRemoveCallback(app, Operation.SET_CUSTOM_INFO.getMethod(), pluginResult);
            }
        } else {
            // 修改失败
            if (app.getCallbackContext(Operation.SET_CUSTOM_INFO.getMethod()) != null) {
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result.getResult());
                HeytzUtil.sendAndRemoveCallback(app, Operation.SET_CUSTOM_INFO.getMethod(), pr);
            }
        }
    }

    /**
     * 获取设备硬件信息
     * <p>
     * 不订阅设备也可以获取到硬件信息。APP可以获取模块协议版本号，mcu固件版本号等硬件信息，但是只能在小循环下才能获取。
     *
     * @param result
     * @param device
     * @param hardwareInfo
     */
    @Override
    public void didGetHardwareInfo(GizWifiErrorCode result, GizWifiDevice device, ConcurrentHashMap<String, String> hardwareInfo) {
        StringBuilder sb = new StringBuilder();
        if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
            sb.append("Wifi Hardware Version:" + hardwareInfo.get("wifiHardVersion")
                    + "\r\n");
            sb.append("Wifi Software Version:" + hardwareInfo.get("wifiSoftVersion")
                    + "\r\n");
            sb.append("MCU Hardware Version:" + hardwareInfo.get("mcuHardVersion")
                    + "\r\n");
            sb.append("MCU Software Version:" + hardwareInfo.get("mcuSoftVersion")
                    + "\r\n");
            sb.append("Firmware Id:" + hardwareInfo.get("wifiFirmwareId") + "\r\n");
            sb.append("Firmware Version:" + hardwareInfo.get("wifiFirmwareVer")
                    + "\r\n");
            sb.append("Product Key:" + hardwareInfo.get("productKey") + "\r\n");
            sb.append("Device ID:" + device.getDid() + "\r\n");
            sb.append("Device IP:" + device.getIPAddress() + "\r\n");
            sb.append("Device MAC:" + device.getMacAddress() + "\r\n");
            if (app.getCallbackContext(Operation.GET_HARDWARE_INFO.getMethod()) != null) {
                JSONObject jsonObject = new JSONObject();
                try {
                    // 字符串类型，GAgent模组硬件版本号
                    jsonObject.put("XPGWifiDeviceHardwareWifiHardVer", hardwareInfo.get("wifiHardVersion"));
                    // 字符串类型，GAgent模组软件版本号
                    jsonObject.put("XPGWifiDeviceHardwareWifiSoftVer", hardwareInfo.get("wifiSoftVersion"));
                    // 字符串类型，设备硬件版本号
                    jsonObject.put("XPGWifiDeviceHardwareMCUHardVer", hardwareInfo.get("mcuHardVersion"));
                    //MCU软件版本
                    jsonObject.put("XPGWifiDeviceHardwareMCUSoftVer", hardwareInfo.get("mcuSoftVersion"));
                    // 字符串类型，固件Id
                    jsonObject.put("XPGWifiDeviceHardwareFirmwareId", hardwareInfo.get("wifiFirmwareId"));
                    // 字符串类型，固件版本号
                    jsonObject.put("XPGWifiDeviceHardwareFirmwareVer", hardwareInfo.get("wifiFirmwareVer"));
                    // 字符串类型，设备的Productkey
                    jsonObject.put("XPGWifiDeviceHardwareProductKey", hardwareInfo.get("productKey"));
                    jsonObject.put("did", device.getDid());
                    jsonObject.put("macAddress", device.getMacAddress());
                    jsonObject.put("device", HeytzUtil.gizDeviceToJsonObject(device));

                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonObject);
                    HeytzUtil.sendAndRemoveCallback(app, Operation.GET_HARDWARE_INFO.getMethod(), pluginResult);
                } catch (JSONException e) {

                }
            }
        } else {
            sb.append("获取失败，错误号：" + result);
            PluginResult pr = new PluginResult(PluginResult.Status.ERROR, result.getResult());
            HeytzUtil.sendAndRemoveCallback(app, Operation.GET_HARDWARE_INFO.getMethod(), pr);
        }

    }

    public HeytzApp getApp() {
        return app;
    }

    public void setApp(HeytzApp app) {
        this.app = app;
    }
}
