package com.heytz.gwsdk;

import com.xtremeprog.xpgconnect.XPGWifiSDK;

/**
 * Created by chendongdong on 16/3/8.
 */
public enum HeytzXPGWifiGAgentType {
    XPGWifiGAgentTypeMXCHIP(1, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeMXCHIP),
    XPGWifiGAgentTypeHF(2, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeHF),
    XPGWifiGAgentTypeRTK(3, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeRTK),
    XPGWifiGAgentTypeWM(4, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeWM),
    XPGWifiGAgentTypeESP(5, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeESP),
    XPGWifiGAgentTypeQCA(6, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeQCA),
    XPGWifiGAgentTypeTI(7, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeTI),
    XPGWifiGAgentTypeFSK(8, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeFSK),
    XPGWifiGAgentTypeMXCHIP3(9, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeMXCHIP3),
    XPGWifiGAgentTypeBL(10, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeBL);
    private int key;

    private XPGWifiSDK.XPGWifiGAgentType value;

    private HeytzXPGWifiGAgentType(int key) {
        this.key = key;
    }

    HeytzXPGWifiGAgentType(int i, XPGWifiSDK.XPGWifiGAgentType xpgWifiGAgentTypeBL) {

    }
    public static XPGWifiSDK.XPGWifiGAgentType getHeytzXPGWifiGAgentType(int i) {
        for (HeytzXPGWifiGAgentType o : HeytzXPGWifiGAgentType.values()) {
            if (o.key == i) {
                return o.value;
            }
        }
        return null;
    }
}
