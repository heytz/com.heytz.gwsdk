package com.heytz.gwsdk;

import com.gizwits.gizwifisdk.enumration.GizWifiGAgentType;

/**
 * Created by chendongdong on 16/9/1.
 */
public enum HeytzGizWifiGAgentType {
    GizGAgentMXCHIP(0, GizWifiGAgentType.GizGAgentMXCHIP),
    GizGAgentHF(1, GizWifiGAgentType.GizGAgentHF),
    GizGAgentRTK(2, GizWifiGAgentType.GizGAgentRTK),
    GizGAgentWM(3, GizWifiGAgentType.GizGAgentWM),
    GizGAgentESP(4, GizWifiGAgentType.GizGAgentESP),
    GizGAgentQCA(5, GizWifiGAgentType.GizGAgentQCA),
    GizGAgentTI(6, GizWifiGAgentType.GizGAgentTI),
    GizGAgentFSK(7, GizWifiGAgentType.GizGAgentFSK),
    GizGAgentMXCHIP3(8, GizWifiGAgentType.GizGAgentMXCHIP3),
    GizGAgentBL(9, GizWifiGAgentType.GizGAgentBL),
    GizGAgentAtmelEE(10,GizWifiGAgentType.GizGAgentAtmelEE);

    private int key;

    private GizWifiGAgentType value;

    private HeytzGizWifiGAgentType(int key, GizWifiGAgentType xpgWifiGAgentType) {
        this.key = key;
        this.value = xpgWifiGAgentType;
    }


    public static GizWifiGAgentType getHeytzGizWifiGAgentType(int i) {
        for (HeytzGizWifiGAgentType o : HeytzGizWifiGAgentType.values()) {
            if (o.key == i) {
                return o.value;
            }
        }
        return null;
    }
}
