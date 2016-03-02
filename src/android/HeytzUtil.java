package com.heytz.gwsdk;

import android.util.Base64;
import android.util.Log;
import com.xtremeprog.xpgconnect.XPGWifiDevice;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by Alben on 16-3-2.
 */
public class HeytzUtil {

    public static JSONObject toJSONObjfrom(XPGWifiDevice device, HeytzApp app) {
        JSONObject json = new JSONObject();
        try {
            json.put("did", device.getDid());
            json.put("macAddress", device.getMacAddress());
            json.put("isLAN", device.isLAN() ? "1" : "0");
            json.put("isOnline", device.isOnline() ? "1" : "0");
            json.put("isConnected", device.isConnected() ? "1" : "0");
            json.put("isDisabled", device.isDisabled() ? "1" : "0");
            json.put("isBind", device.isBind(app.getUid()) ? "1" : "0");//json.put("isBind", device.isBind(_uid) ? "1" : "0");
        } catch (JSONException e) {

        }
        return json;
    }

    public static JSONObject deviceToJsonObject(XPGWifiDevice device) {
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


    public static void logDevice(String map, XPGWifiDevice device) {
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


}
