package com.heytz.gwsdk;

import android.util.Base64;
import android.util.Log;
import com.gizwits.gizwifisdk.api.GizWifiDevice;
import com.xtremeprog.xpgconnect.XPGWifiDevice;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Iterator;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by chendongdong on 16/3/7.
 */
public class HeytzUtil {
    public static JSONObject deviceToJsonObject(XPGWifiDevice device, String uid) {
        JSONObject json = new JSONObject();
        try {
            json.put("macAddress", device.getMacAddress());
            json.put("did", device.getDid());
            json.put("passcode", device.getPasscode());
            json.put("ipAddress", device.getIPAddress());
            json.put("productKey", device.getProductKey());
            json.put("productName", device.getProductName());
            json.put("remark", device.getRemark());
            json.put("isConnected", device.isConnected());
            json.put("isDisabled", device.isDisabled());
            json.put("isLAN", device.isLAN());
            json.put("isOnline", device.isOnline());
            if (uid != null) {
                json.put("isBind", device.isBind(uid));
            } else {
                json.put("isBind", null);
            }
        } catch (JSONException e) {
        } finally {
            return json;
        }
    }

    public static JSONObject gizDeviceToJsonObject(GizWifiDevice device) {
        JSONObject json = new JSONObject();
        try {
            json.put("macAddress", device.getMacAddress());
            json.put("did", device.getDid());
            json.put("ipAddress", device.getIPAddress());
            json.put("productKey", device.getProductKey());
            json.put("productName", device.getProductName());
            json.put("remark", device.getRemark());
            json.put("isDisabled", device.isDisabled());
            json.put("isLAN", device.isLAN());
            json.put("isBind", device.isBind());
        } catch (JSONException e) {
        } finally {
            return json;
        }
    }

    public static void logDevice(String map, XPGWifiDevice device) {
        if (HeytzApp.DEBUG) {
            Log.e(map, device.getMacAddress());
            Log.e(map, device.getDid());
            Log.e(map, device.getIPAddress());
            Log.e(map, device.getProductKey());
        }
    }

    public static void logDevice(String map, GizWifiDevice device) {
        if (HeytzApp.DEBUG) {
            Log.e(map, device.getMacAddress());
            Log.e(map, device.getDid());
            Log.e(map, device.getIPAddress());
            Log.e(map, device.getProductKey());
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

    /**
     * 方法 发送控制命令的方法  第三步
     *
     * @param xpgWifiDevice
     * @param value
     */
    private void cWrite(XPGWifiDevice xpgWifiDevice, Object value, CallbackContext callbackContext) {
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
                jsonparam.put(jsonKey, HeytzUtil.getData(jsonValue));
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
            callbackContext.success("success");
        } catch (JSONException e) {
            if (HeytzApp.DEBUG)
                e.printStackTrace();
            callbackContext.error("error");
        }
    }

    public static void sendAndRemoveCallback(HeytzApp app, String operation, PluginResult pr) {
        if (app.getCallbackContext(operation) != null) {
            app.getCallbackContext(operation).sendPluginResult(pr);
            app.removeCallbackContext(operation);
        }
    }

    public static ConcurrentHashMap<String, Object> jsonToMap(JSONObject jsonObject) throws JSONException {
        ConcurrentHashMap<String, Object> command = new ConcurrentHashMap<String, Object>();
        Iterator keyIter = jsonObject.keys();
        String key;
        Object value;
        while (keyIter.hasNext()) {
            key = (String) keyIter.next();
            value = jsonObject.get(key);
            command.put(key, value);
        }
        return command;
    }
}
