//
//  BatteryDetailPopoverView.swift
//  boringNotch
//
//  Created by Alejandro Lemus Rodriguez on 22/04/25.
//

import Defaults
import SwiftUI

/// A SwiftUI view that displays detailed information about the battery status.
/// It includes information such as battery level, charging status, and time to full charge.
struct BatteryDetailPopoverView: View {
    
    /// The battery state object containing all battery-related information
    let batteryState: BatteryState
    
    /// A closure that is executed when the popover view is dismissed.
    var onDismiss: () -> Void
    
    /// Used to open system preferences
    @Environment(\.openURL) private var openURL: OpenURLAction

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Battery Status")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(batteryState.percentage)%")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Max Capacity: \(Int(batteryState.maxCapacity))%")
                    .font(.subheadline)
                    .fontWeight(.regular)
                
                if batteryState.isInLowPowerMode {
                    styledInfoLabel(text: "Low Power Mode", icon: "bolt.circle")
                }
                if batteryState.isCharging {
                    styledInfoLabel(text: "Charging", icon: "bolt.fill")
                }
                if batteryState.isPluggedIn {
                    styledInfoLabel(text: "Plugged In", icon: "powerplug.fill")
                }
                if batteryState.timeToFullCharge > 0 {
                    styledInfoLabel(text: "Time to Full Charge: \(batteryState.formattedChargingTime)", icon: "clock")
                }
                if batteryState.isInOptimizedCharging {
                    styledInfoLabel(text: "Charging on Hold: Desktop Mode", icon: "desktopcomputer")
                }
            }
            .padding(.vertical, 8)

            Divider().background(Color(.separatorColor))

            Button(action: openBatteryPreferences) {
                Label("Battery Settings", systemImage: "gearshape")
                    .fontWeight(.regular)
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.plain)
            .padding(.vertical, 8)
        }
        .padding()
        .frame(width: 280)
        .foregroundColor(.white)
    }

    /// Opens the battery preferences in System Preferences.
    /// - Note: This function uses a custom URL scheme to open the battery preferences.
    private func openBatteryPreferences() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.battery") else {
            print("Unable to create battery preferences URL")
            return
        }
        
        openURL(url)
        onDismiss()
    }

    /// A helper function to create a styled label with an icon and text.
    private func styledInfoLabel(text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.subheadline)
            .fontWeight(.regular)
    }
}

#Preview("Charging Battery") {
    BatteryDetailPopoverView(
        batteryState: BatteryState(
            level: 45,
            isPluggedIn: true,
            isCharging: true,
            isInLowPowerMode: false,
            maxCapacity: 92,
            timeToFullCharge: 65
        ),
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Low Battery with Low Power Mode") {
    BatteryDetailPopoverView(
        batteryState: BatteryState(
            level: 15,
            isPluggedIn: false,
            isCharging: false,
            isInLowPowerMode: true,
            maxCapacity: 90,
            timeToFullCharge: 0
        ),
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Full Battery Plugged In") {
    BatteryDetailPopoverView(
        batteryState: BatteryState(
            level: 100,
            isPluggedIn: true,
            isCharging: false,
            isInLowPowerMode: false,
            maxCapacity: 95,
            timeToFullCharge: 0
        ),
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Optimized Charging") {
    BatteryDetailPopoverView(
        batteryState: BatteryState(
            level: 85,
            isPluggedIn: true,
            isCharging: false,
            isInLowPowerMode: false,
            maxCapacity: 96,
            timeToFullCharge: 0
        ),
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}
