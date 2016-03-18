package com.heytz.gwsdk;

import com.xtremeprog.xpgconnect.XPGWifiSDK;

/**
 * Created by chendongdong on 16/3/8.
 */
public enum HeytzXPGWifiGAgentType {
    XPGWifiGAgentTypeMXCHIP(0, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeMXCHIP),
    XPGWifiGAgentTypeHF(1, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeHF),
    XPGWifiGAgentTypeRTK(2, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeRTK),
    XPGWifiGAgentTypeWM(3, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeWM),
    XPGWifiGAgentTypeESP(4, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeESP),
    XPGWifiGAgentTypeQCA(5, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeQCA),
    XPGWifiGAgentTypeTI(6, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeTI),
    XPGWifiGAgentTypeFSK(7, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeFSK),
    XPGWifiGAgentTypeMXCHIP3(8, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeMXCHIP3),
    XPGWifiGAgentTypeBL(9, XPGWifiSDK.XPGWifiGAgentType.XPGWifiGAgentTypeBL);
    private int key;

    private XPGWifiSDK.XPGWifiGAgentType value;

    private HeytzXPGWifiGAgentType(int key, XPGWifiSDK.XPGWifiGAgentType xpgWifiGAgentType) {
        this.key = key;
        this.value=xpgWifiGAgentType;
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
