//
//  BatteryIconView.swift
//  boringNotch
//
//  Created by Alejandro Lemus Rodriguez on 22/04/25.
//

import SwiftUI
import Defaults

/// A SwiftUI view that represents the battery status or related information.
/// This view can be used to display battery-related data in a live activity or other UI components.
struct BatteryIconView: View {
    /// The battery state containing all information about the battery
    let batteryState: BatteryState
    
    /// Represents the width of the battery indicator as a CGFloat.
    let batteryWidth: CGFloat
    
    /// Specifies whether the battery view is used in a notification.
    /// - Important: This affects layout and animation behavior.
    let isForNotification: Bool
    
    /// Constants for battery visual dimensions
    /// - `horizontalPadding`: Padding inside the battery outline.
    /// - `heightAdjustment`: Height ratio relative to width.
    /// - `heightOffset`: Additional height reduction.
    /// - `iconSize`: Standard size for status icons.
    private struct BatteryDimensions {
        static let horizontalPadding: CGFloat = 6
        static let heightAdjustment: CGFloat = 2.75
        static let heightOffset: CGFloat = 18
        static let iconSize: CGFloat = 17
    }
    
    /// The width of the battery fill area, calculated based on the battery level.
    /// - Returns: A `CGFloat` representing the width of the fill area.
    private var batteryFillWidth: CGFloat {
        return (CGFloat(batteryState.normalizedLevel) / 100) * (batteryWidth - BatteryDimensions.horizontalPadding)
    }
    
    /// The height of the battery indicator
    /// - Returns: A `CGFloat` representing the height of the battery.
    private var batteryHeight: CGFloat {
        return (batteryWidth - BatteryDimensions.heightAdjustment) - BatteryDimensions.heightOffset
    }
    
    /// The name of the battery status icon asset, based on the charging state.
    ///
    /// - Returns: A string representing the asset name, such as:
    ///   - `"boringBatteryStatus.bolt"` ⚡ if charging
    ///   - `"boringBatteryStatus.plug"` 🔌 if plugged in
    ///   - `""` if none
    private var powerStatusIconAssetName: String {
        if batteryState.isCharging {
            return "boringBatteryStatus.bolt"
        }
        else if batteryState.isPluggedIn {
            return "boringBatteryStatus.plug"
        }
        else {
            return ""
        }
    }
    
    /// A view representing the battery status icon.
    /// - Note: This view is displayed only if the icon asset name is not empty and the user has enabled power status icons.
    /// - Returns: A `View` representing the battery status icon.
    /// - Important: The icon is displayed only if `isForNotification` is `true` or the user has enabled power status icons in settings.
    @ViewBuilder
    private var batteryStatusIcon: some View {
        Group {
            if !powerStatusIconAssetName.isEmpty && (isForNotification || Defaults[.showPowerStatusIcons]) {
                ZStack {
                    Image(powerStatusIconAssetName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(
                            width: BatteryDimensions.iconSize,
                            height: BatteryDimensions.iconSize
                        )
                }
                .frame(width: batteryWidth, height: batteryWidth)
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "battery.0")
                .resizable()
                .fontWeight(.thin)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.primary.opacity(0.5))
                .frame(
                    width: batteryWidth + 1
                )
                
            RoundedRectangle(cornerRadius: 2.5)
                .fill(batteryState.statusColor)
                .frame(
                    width: batteryFillWidth,
                    height: batteryHeight
                )
                .padding(.leading, 2)
                
            batteryStatusIcon
        }
        .accessibilityLabel("Battery")
        .accessibilityValue(batteryState.accessibilityStatus)
    }
}

#Preview("Normal Battery - 75%") {
    BatteryIconView(
        batteryState: BatteryState(
            level: 75,
            isPluggedIn: false,
            isCharging: false,
            isInLowPowerMode: false,
            maxCapacity: 98,
            timeToFullCharge: 0
        ),
        batteryWidth: 30,
        isForNotification: false
    ).background(Color.black)
}

#Preview("Low Battery - 15%") {
    BatteryIconView(
        batteryState: BatteryState(
            level: 15,
            isPluggedIn: false,
            isCharging: false,
            isInLowPowerMode: false,
            maxCapacity: 96,
            timeToFullCharge: 0
        ),
        batteryWidth: 30,
        isForNotification: false
    ).background(Color.black)
}

#Preview("Charging - 45%") {
    BatteryIconView(
        batteryState: BatteryState(
            level: 45,
            isPluggedIn: true,
            isCharging: true,
            isInLowPowerMode: false,
            maxCapacity: 97,
            timeToFullCharge: 55
        ),
        batteryWidth: 30,
        isForNotification: false
    ).background(Color.black)
}

#Preview("Low Power Mode - 30%") {
    BatteryIconView(
        batteryState: BatteryState(
            level: 30,
            isPluggedIn: false,
            isCharging: false,
            isInLowPowerMode: true,
            maxCapacity: 95,
            timeToFullCharge: 0
        ),
        batteryWidth: 30,
        isForNotification: false
    ).background(Color.black)
}

#Preview("Multiple Sizes") {
    VStack(spacing: 20) {
        ForEach([20, 30, 40], id: \.self) { width in
            BatteryIconView(
                batteryState: BatteryState(
                    level: 60,
                    isPluggedIn: false,
                    isCharging: false,
                    isInLowPowerMode: false,
                    maxCapacity: 98,
                    timeToFullCharge: 0
                ),
                batteryWidth: CGFloat(width),
                isForNotification: false
            )
        }
    }
    .background(Color.black)
    .padding()
}

#Preview("Notification View") {
    BatteryIconView(
        batteryState: BatteryState(
            level: 65,
            isPluggedIn: true,
            isCharging: true,
            isInLowPowerMode: false,
            maxCapacity: 99,
            timeToFullCharge: 35
        ),
        batteryWidth: 25,
        isForNotification: true
    ).background(Color.black)
}