package com.heytz.gwsdk;

/**
 * Created by chendongdong on 16/3/7.
 */
public enum Operation {
    SET_DEVICE_WIFI("setDeviceWifi"),                       //只配对设备
    SET_DEVICE_WIFI_AND_BIND("setDeviceWifiBindDevice"),    //配对设备并且绑定设备
    GET_DEVICE_LIST("getDeviceList"),                       //发现列表
    START_GET_DEVICE_LIST("startGetDeviceList"),            //开始发现列表
    STOP_GET_DEVICE_LIST("stopGetDeviceList"),              //结束发现列表
    DEVICE_BINDING("deviceBinding"),                        //绑定设备
    UNBIND_DEVICE("unbindDevice"),                          //解绑设备
    CONTROL_DEVICE("deviceControl"),                        //控制设备
    GET_WIFI_SSID_LIST("getWifiSSIDList"),                  //获取wifi列表
    START_DEVICE_LISTENER("startDeviceListener"),           //监听设备信息
    STOP_DEVICE_LISTENER("stopDeviceListener"),             //停止监听设备信息
    CONNECT("connect"),                                     //连接
    DISCONNECT("disconnect"),                               //断开连接
    GET_HARDWARE_INFO("getHardwareInfo"),                     //获取设备硬件信息
    WRITE("write"),                                         //发送消息
    DEALLOC("dealloc"),
    UPDATE_DEVICE_FROM_SERVER("updateDeviceFromServer");//下载产品配置

    private String method;

    private Operation(String method) {
        this.method = method;
    }

    public Operation getOpervation(String method) {
        for (Operation o : Operation.values()) {
            if (o.method.equals(method)) {
                return o;
            }
        }
        return null;
    }

    public String getMethod() {
        return this.method;
    }
}
