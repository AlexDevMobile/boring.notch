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
    
    /// The battery state containing all information about the battery
    let batteryState: BatteryState
    
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

    /// The normalized battery level, clamped between 0 and 100.
    private var normalizedBatteryLevel: Float {
        return batteryState.normalizedLevel
    }

    /// Formats the battery percentage as a string.
    private var formattedBatteryPercentage: String {
        return "\(batteryState.percentage)%"
    }

    var body: some View {
        HStack {
            if Defaults[.showBatteryPercentage] {
                Text(formattedBatteryPercentage)
                    .font(.callout)
                    .foregroundStyle(.white)
            }
            BatteryIconView(
                batteryState: batteryState,
                batteryWidth: batteryWidth,
                isForNotification: isForNotification
            )
        }
        .scaleEffect(isPressed ? AnimationConstants.pressedScale : AnimationConstants.normalScale)
        .animation(.spring(duration: AnimationConstants.animationDuration), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation {
                        isPressed = false
                        showPopupMenu.toggle()
                    }
                }
        )
        .popover(
            isPresented: $showPopupMenu,
            arrowEdge: .bottom) {
            BatteryDetailPopoverView(
                batteryState: batteryState,
                onDismiss: { showPopupMenu = false }
            )
            .onDisappear{
                onHoverMenuChange(false)
            }
            .onHover { hovering in
                onHoverMenuChange(hovering)
            }
        }
        .accessibilityLabel("Battery Status")
        .accessibilityValue(batteryState.accessibilityStatus)
        .accessibilityAction {
            showPopupMenu.toggle()
        }
    }
}


#Preview("Normal Battery - 75%") {
    BatteryIndicatorControl(
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
    )
    .frame(width: 200, height: 50)
    .background(Color.black)
}

#Preview("Low Battery - 15%") {
    BatteryIndicatorControl(
        batteryState: BatteryState(
            level: 15,
            isPluggedIn: false,
            isCharging: false,
            isInLowPowerMode: true,
            maxCapacity: 90,
            timeToFullCharge: 0
        ),
        batteryWidth: 30,
        isForNotification: false
    )
    .frame(width: 200, height: 50)
    .background(Color.black)
}

#Preview("Charging - 45%") {
    BatteryIndicatorControl(
        batteryState: BatteryState(
            level: 45,
            isPluggedIn: true,
            isCharging: true,
            isInLowPowerMode: false,
            maxCapacity: 95,
            timeToFullCharge: 35
        ),
        batteryWidth: 30,
        isForNotification: false
    )
    .frame(width: 200, height: 50)
    .background(Color.black)
}

#Preview("Full Battery - 100%") {
    BatteryIndicatorControl(
        batteryState: BatteryState(
            level: 100,
            isPluggedIn: true,
            isCharging: false,
            isInLowPowerMode: false,
            maxCapacity: 100,
            timeToFullCharge: 0
        ),
        batteryWidth: 30,
        isForNotification: false
    )
    .frame(width: 200, height: 50)
    .background(Color.black)
}

#Preview("Notification View") {
    BatteryIndicatorControl(
        batteryState: BatteryState(
            level: 65,
            isPluggedIn: true,
            isCharging: true,
            isInLowPowerMode: false,
            maxCapacity: 99,
            timeToFullCharge: 35
        ),
        batteryWidth: 20,
        isForNotification: true
    )
    .frame(width: 100, height: 50)
    .background(Color.black)
}
