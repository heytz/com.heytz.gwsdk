package com.heytz.gwsdk;

import android.util.Base64;
import com.gizwits.gizwifisdk.api.GizWifiDevice;
import com.xtremeprog.xpgconnect.XPGWifiDevice;
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
            int netStatus=0;
            switch (device.getNetStatus()){
                case GizDeviceOffline:
                    netStatus=0;
                    break;
                case GizDeviceOnline:
                    netStatus=1;
                    break;
                case GizDeviceControlled:
                    netStatus=2;
                    break;
               default:
                    netStatus=3;
                   break;
            }
            json.put("netStatus",netStatus);
            json.put("alias",device.getAlias());
            json.put("isSubscribed",device.isSubscribed());
            json.put("isProductDefined",device.isProductDefined());
        } catch (JSONException e) {
        } finally {
            return json;
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
