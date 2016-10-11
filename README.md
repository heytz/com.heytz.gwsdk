这是机智云SDK接口文档



接口列表:
- [cordova.plugins.gwsdk.getHardwareInfo](#getHardwareInfo)


###getHardwareInfo
获取设备硬件信息

    cordova.plugins.gwsdk.getHardwareInfo(did,success,error)

###Parameters

    did:设备的did
    success:成功的回调
    error:失败的回调

### Description

    success {
        // 字符串类型，GAgent模组硬件版本号
        XPGWifiDeviceHardwareWifiHardVer:"",
        // 字符串类型，GAgent模组软件版本号
        XPGWifiDeviceHardwareWifiSoftVer:"",
        // 字符串类型，设备硬件版本号
        XPGWifiDeviceHardwareMCUHardVer:"",
        //MCU软件版本
        XPGWifiDeviceHardwareMCUSoftVer:"",
        // 字符串类型，固件Id
        XPGWifiDeviceHardwareFirmwareId:"",
        // 字符串类型，固件版本号
        XPGWifiDeviceHardwareFirmwareVer:"",
        // 字符串类型，设备的Productkey
        XPGWifiDeviceHardwareProductKey:"",
        //字符串类型,设备的did
        did:"",
        //字符串类型,设备的macAddress
        macAdress:""
    }
    error:
      //错误码,错误码对比参见机智云.