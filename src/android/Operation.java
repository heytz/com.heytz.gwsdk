package com.heytz.gwsdk;

/**
 * Created by Alben on 16-3-2.
 */
public enum Operation {
    SET_WIFI("setDeviceWifi"),                   //只配对设备
    GET_DEVICE_LIST("getDeviceList"),            //发现列表
    CONTROL_DEVICE("deviceControl"),             //控制设备
    SET_DEVICE_WIFI_AND_BIND("setDeviceWifiBindDevice"),   //配对设备并且绑定设备
    CONNECT_DEVICE("connectDevice"),             //连接设备
    DISCONNECT_DEVICE("disconnectDevice"),          //断开设备
    SEND_CONTROL_MESSAGE("getDeviceMessage"),       //发送控制指令
    GET_DEVICE_MESSAGE("getDeviceMessage");         //获取设备信息

    private String method;

    private Operation(String method){
        this.method = method;
    }

    public Operation getOpervation(String method){
        for (Operation o: Operation.values()) {
            if(o.method.equals(method)){
                return o;
            }
        }
        return null;
    }
}
