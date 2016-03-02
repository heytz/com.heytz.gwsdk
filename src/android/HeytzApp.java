package com.heytz.gwsdk;

import com.xtremeprog.xpgconnect.XPGWifiDevice;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Alben on 16-3-2.
 */
public class HeytzApp {

    public final static boolean DEBUG = true;

    public final static String TAG = "\n===gwsdkwrapper====\n";

    private String appID;

    //private List productKey = new ArrayList();

    private String productKey;

    private String uid; //当前用户的uid

    private String token;

    private String mac;

    private Operation operation;

    private XPGWifiDevice currentDevice;

    private List<XPGWifiDevice> deviceList = new ArrayList<XPGWifiDevice>();//筛选出来的设备列表

    /*
     *  setter getter
     */
    public String getAppID() {
        return appID;
    }
    public void setAppID(String appID) {
        this.appID = appID;
    }

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

    public String getProductKey(){
        return this.productKey;
    }
    public void setProductKey(String productKey){
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

    public Operation getOperation() {
        return operation;
    }

    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public void setCurrentDevice(XPGWifiDevice currentDevice) {
        this.currentDevice = currentDevice;
    }

    public XPGWifiDevice getCurrentDevice() {
        return currentDevice;
    }

    public void setDeviceList(List<XPGWifiDevice> deviceList){
        if(deviceList == null){
            deviceList.clear();
        }
        this.deviceList = deviceList;
    }

    public List<XPGWifiDevice> getDeviceList() {
        return deviceList;
    }

}
