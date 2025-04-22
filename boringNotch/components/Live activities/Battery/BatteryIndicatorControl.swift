//
//  BatteryIndicatorControl.swift
//  boringNotch
//
//  Created by Alejandro Lemus Rodriguez on 22/04/25.
//

import SwiftUI
import Defaults


/// A SwiftUI view that represents the battery indicator control.
/// This view can be used to display battery-related data in a live activity or other UI components.
/// - Note: The view includes a popover menu that shows detailed battery information when tapped.
struct BatteryIndicatorControl: View {
    
    /// Indicates whether the device is currently charging.
    let isCharging: Bool

    /// Indicates whether the device is in Low Power Mode.
    let isInLowPowerMode: Bool

    /// Indicates whether the device is plugged into a power source.
    let isPluggedIn: Bool

    /// Represents the current battery level as a percentage (0.0 to 1.0).
    let levelBattery: Float

    /// Represents the maximum battery capacity of the device.
    var maxCapacity: Float = 0

    /// Represents the estimated time (in minutes) until the battery is fully charged.
    var timeToFullCharge: Int = 0
    
    /// The width of the battery indicator.
    /// This value determines the visual width of the battery component.
    var batteryWidth: CGFloat = 26

    /// Indicates whether the control is being used for a notification.
    var isForNotification: Bool = false

    /// A flag to determine whether the popup menu is currently displayed.
    @State private var showPopupMenu: Bool = false

    /// A flag to indicate whether the control is currently being pressed.
    @State private var isPressed: Bool = false
    
    /// Callback invoked when the hover state of the battery menu changes
    /// - Parameter isHovering: Boolean indicating if the menu is being hovered
    var onHoverMenuChange: (Bool) -> Void = { _ in }

    /// Constants related to animation and visual appearance
    private enum AnimationConstants {
        /// Duration of press animation
        static let animationDuration: CGFloat = 0.2
        /// Scale factor when pressed
        static let pressedScale: CGFloat = 0.95
        /// Normal scale
        static let normalScale: CGFloat = 1.0
        /// Delay before releasing press effect
        static let pressReleaseDelay: DispatchTime = .now() + 0.1
    }

    /// Handles the tap gesture on the battery indicator.
    private func handleTap() {
        withAnimation(.spring(duration: AnimationConstants.animationDuration)) {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: AnimationConstants.pressReleaseDelay) {
                withAnimation(.spring(duration: AnimationConstants.animationDuration)) {
                    isPressed = false
                    showPopupMenu.toggle()
                }
            }
        }
    }

    /// The normalized battery level, clamped between 0 and 100.
    private var normalizedBatteryLevel: Float {
        return min(100, max(0, levelBattery))
    }

    /// Formats the battery percentage as a string.
    private var formattedBatteryPercentage: String {
        return "\(Int(normalizedBatteryLevel))%"
    }

    var body: some View {
        HStack {
            if Defaults[.showBatteryPercentage] {
                Text(formattedBatteryPercentage)
                    .font(.callout)
                    .foregroundStyle(.white)
            }
            BatteryIconView(
                levelBattery: levelBattery,
                isPluggedIn: isPluggedIn,
                isCharging: isCharging,
                isInLowPowerMode: isInLowPowerMode,
                batteryWidth: batteryWidth,
                isForNotification: isForNotification
            )
        }
        .scaleEffect(isPressed ? AnimationConstants.pressedScale : AnimationConstants.normalScale)
        .animation(.spring(duration: AnimationConstants.animationDuration), value: isPressed)
        .onTapGesture {
            handleTap()
        }
        .popover(
            isPresented: $showPopupMenu,
            arrowEdge: .bottom) {
            BatteryDetailPopoverView(
                isPluggedIn: isPluggedIn,
                isCharging: isCharging,
                levelBattery: levelBattery,
                maxCapacity: maxCapacity,
                timeToFullCharge: timeToFullCharge,
                isInLowPowerMode: isInLowPowerMode,
                onDismiss: { showPopupMenu = false }
            )
            .onAppear {
                onHoverMenuChange(true)
            }
            .onHover { hovering in
                onHoverMenuChange(hovering)
            }
        }
        .accessibilityLabel("Battery Status")
        .accessibilityValue("\(Int(levelBattery))% \(isCharging ? "charging" : isPluggedIn ? "plugged in" : "")")
        .accessibilityAction {
            showPopupMenu.toggle()
        }
    }
    
}


#Preview("Critical Battery - 5%") {
    BatteryIndicatorControl(
        isCharging: false,
        isInLowPowerMode: true,
        isPluggedIn: false,
        levelBattery: 5,
        maxCapacity: 95,
        timeToFullCharge: 0,
        batteryWidth: 30,
        isForNotification: false,
        onHoverMenuChange: { _ in }
    ).frame(width: 200, height: 200)
    .background(Color.black)
}

#Preview("Fast Charging - 45%") {
    BatteryIndicatorControl(
        isCharging: true,
        isInLowPowerMode: false,
        isPluggedIn: true,
        levelBattery: 45,
        maxCapacity: 100,
        timeToFullCharge: 35,
        batteryWidth: 30,
        isForNotification: false,
        onHoverMenuChange: { _ in }
    ).frame(width: 200, height: 200)
    .background(Color.black)
}

#Preview("Full Battery - 100%") {
    BatteryIndicatorControl(
        isCharging: false,
        isInLowPowerMode: false,
        isPluggedIn: true,
        levelBattery: 100,
        maxCapacity: 100,
        timeToFullCharge: 0,
        batteryWidth: 30,
        isForNotification: false,
        onHoverMenuChange: { _ in }
    ).frame(width: 200, height: 200)
    .background(Color.black)
}
