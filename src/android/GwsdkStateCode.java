package com.heytz.gwsdk;

/**
 * Created by chendongdong on 16/3/7.
 */
public class GwsdkStateCode {
    private static int CurrentState;
    public static final int SetWifiCode = 0;            //只配对设备
    public static final int GetDevcieListCode = 1;      //发现列表
    public static final int ControlCode = 2;            //控制设备
    public static final int SetDeviceWifiBindDevice = 3;   //配对设备并且绑定设备
    public static final int ConnectDevice = 4;   //连接设备
    public static final int DisconnectDevice = 5; //断开设备
    public static final int SendControlMessage = 6; //发送控制指令
    public static final int GetDeviceMesssage = 7; //获取设备信息

    public static void setCurrentState(int currentState) {
        CurrentState = currentState;
    }

    public static int getCurrentState() {
        return CurrentState;
    }

}
