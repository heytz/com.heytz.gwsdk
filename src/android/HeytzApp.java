package com.heytz.gwsdk;

import com.gizwits.gizwifisdk.api.GizWifiDevice;
import com.xtremeprog.xpgconnect.XPGWifiDevice;
import org.apache.cordova.CallbackContext;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by chendongdong on 16/3/7.
 */
public  class HeytzApp {
    public final static boolean DEBUG = true;

    public final static String TAG = "\n===gwsdkwrapper====\n";

    private List<String> productKeys = new ArrayList();

    private String productKey;
    private String productSecret;

    private Object controlObject;

    private String uid; //当前用户的uid

    private String token;

    private String mac;

    private Operation operation;

    private GizWifiDevice currentDevice;

    private List<GizWifiDevice> deviceList = new ArrayList<GizWifiDevice>();//筛选出来的设备列表

    private Map<String, CallbackContext> callbackContextMap = new HashMap<String, CallbackContext>();
//    public List getProductKey() {
//        return productKey;
//    }
//    public void setProductKey(List productKey) {
//        this.productKey = productKey;
//    }

    public Boolean hasDone(List<XPGWifiDevice> deviceList) {
        if (this.deviceList.isEmpty()) return false;
        return this.deviceList.size() == deviceList.size();
    }

    public String getProductKey() {
        return this.productKey;
    }

    public void setProductKey(String productKey) {
        this.productKey = productKey;
    }

    public String getUid() {
        return uid;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getMac() {
        return mac;
    }

    public void setMac(String mac) {
        this.mac = mac;
    }
    public String getProductSecret() {
        return productSecret;
    }

    public void setProductSecret(String Secret) {
        this.productSecret = Secret;
    }

    public List<String> getProductKeys() {
        return productKeys;
    }

    public void seProductKeys(List<String> list) {
        this.productKeys = list;
    }

    public Operation getOperation() {
        return operation;
    }

    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public void setCurrentDevice(GizWifiDevice currentDevice) {
        this.currentDevice = currentDevice;
    }

    public GizWifiDevice getCurrentDevice() {
        return currentDevice;
    }

    public void setDeviceList(List<GizWifiDevice> deviceList) {
        if (deviceList == null) {
            deviceList.clear();
        }
        this.deviceList = deviceList;
    }

    public List<GizWifiDevice> getDeviceList() {
        return deviceList;
    }

    public void setControlObject(Object object) {
        this.controlObject = object;
    }

    public Object getControlObject() {
        return this.controlObject;
    }

    /**
     * 获取callback,指定某个方法
     *
     * @param key
     * @return
     */
    public CallbackContext getCallbackContext(String key) {
        if (callbackContextMap.containsKey(key))
            return callbackContextMap.get(key);
        else
            return null;
    }

    /**
     * 设置callback,方法名为键
     *
     * @param key             方法名
     * @param callbackContext
     */
    public void setCallbackContext(String key, CallbackContext callbackContext) {
        callbackContextMap.put(key, callbackContext);
    }

    /**
     * 删除指定的callback
     *
     * @param key
     */
    public void removeCallbackContext(String key) {
        callbackContextMap.remove(key);
    }
}
