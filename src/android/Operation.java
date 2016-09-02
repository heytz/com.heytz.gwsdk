package com.heytz.gwsdk;

/**
 * Created by chendongdong on 16/3/7.
 */
public enum Operation {
    SET_DEVICE_ON_BOARDING("setDeviceOnboarding"),           //配对设备
    SET_DEVICE_ON_BOARDING_AND_BIND_DEVICE("setDeviceOnboardingAndBindDevice"),           //配对设备
    GET_BOUND_DEVICES("getBoundDevices"),                   //发现列表
    SET_CUSTOM_INFO("setCustomInfo"),                       //设置remark alias
    BIND_REMOTE_DEVICE("bindRemoteDevice"),                    //远程绑定
    SET_SUBSCRIBE("setSubscribe"),                       //订阅
    UNBIND_DEVICE("unbindDevice"),                          //解绑设备
    GET_WIFI_SSID_LIST("getWifiSSIDList"),                  //获取wifi列表
    START_DEVICE_LISTENER("startDeviceListener"),           //监听设备信息
    STOP_DEVICE_LISTENER("stopDeviceListener"),             //停止监听设备信息
    GET_HARDWARE_INFO("getHardwareInfo"),                     //获取设备硬件信息
    WRITE("write"),                                         //发送消息
    DEALLOC("dealloc");

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
