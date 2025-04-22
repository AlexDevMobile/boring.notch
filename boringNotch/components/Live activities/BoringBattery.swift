import SwiftUI
import Defaults


/// A SwiftUI view that represents the battery status or related information.
/// This view can be used to display battery-related data in a live activity or other UI components.
struct BatteryView: View {

    /// The current battery level.
    /// - Value range: `0` (empty) to `100` (fully charged).
    let levelBattery: Float

    /// Indicates whether the device is plugged into a power source.
    let isPluggedIn: Bool

    /// Indicates whether the device is currently charging.
    let isCharging: Bool

    /// Indicates if the device is in Low Power Mode.
    /// - Note: This can affect battery usage indicators.
    let isInLowPowerMode: Bool

    /// Represents the width of the battery indicator as a CGFloat.
    let batteryWidth: CGFloat

    /// Specifies whether the battery view is used in a notification.
    /// - Important: This affects layout and animation behavior.
    let isForNotification: Bool

    /// Constants for battery visual dimensions
    private struct BatteryDimensions {
        /// Padding inside battery outline
        static let horizontalPadding: CGFloat = 6
        /// Battery height ratio relative to width
        static let heightAdjustment: CGFloat = 2.75
        /// Additional height reduction
        static let heightOffset: CGFloat = 18
        /// Standard size for status icons
        static let iconSize: CGFloat = 17
    }

    /// The width of the battery fill area, calculated based on the battery level.
    /// - Returns: A `CGFloat` representing the width of the fill area.
    private var batteryFillWidth: CGFloat {
        return (CGFloat(levelBattery) / 100) * (batteryWidth - BatteryDimensions.horizontalPadding)
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
        if isCharging {
            return "boringBatteryStatus.bolt"
        }
        else if isPluggedIn {
            return "boringBatteryStatus.plug"
        }
        else {
            return ""
        }
    }

    /// Determines the color representing the battery's current state.
    /// - Returns: A `Color` representing the battery state:
    ///   - Yellow if in Low Power Mode
    ///   - Red if battery level is 20% or lower and not charging
    ///   - Green if charging, plugged in, or fully charged
    ///   - White otherwise
    private var batteryStateColor: Color {
        if isInLowPowerMode {
            return .yellow
        } else if levelBattery <= 20 && !isCharging && !isPluggedIn {
            return .red
        } else if isCharging || isPluggedIn || levelBattery == 100 {
            return .green
        } else {
            return .white
        }
    }
    
    var body: some View {
        ZStack(alignment: .leading) {

            Image(systemName: "battery.0")
                .resizable()
                .fontWeight(.thin)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white.opacity(0.5))
                .frame(
                    width: batteryWidth + 1
                )

            RoundedRectangle(cornerRadius: 2.5)
                .fill(batteryStateColor)
                .frame(
                    width: batteryFillWidth,
                    height: batteryHeight
                )
                .padding(.leading, 2)

            if powerStatusIconAssetName != "" && (isForNotification || Defaults[.showPowerStatusIcons]) {
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
        .accessibilityLabel("Battery")
        .accessibilityValue("\(Int(levelBattery))% \(isCharging ? "charging" : isPluggedIn ? "plugged in" : "")")
    }
    
}

struct BatteryMenuView: View {
    
    var isPluggedIn: Bool
    var isCharging: Bool
    var levelBattery: Float
    var maxCapacity: Float
    var timeToFullCharge: Int
    var isInLowPowerMode: Bool
    var onDismiss: () -> Void

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text("Battery Status")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(Int(levelBattery))%")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Max Capacity: \(Int(maxCapacity))%")
                    .font(.subheadline)
                    .fontWeight(.regular)
                if isInLowPowerMode {
                    Label("Low Power Mode", systemImage: "bolt.circle")
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
                if isCharging {
                    Label("Charging", systemImage: "bolt.fill")
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
                if isPluggedIn {
                    Label("Plugged In", systemImage: "powerplug.fill")
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
                if timeToFullCharge > 0 {
                    Label("Time to Full Charge: \(timeToFullCharge) min", systemImage: "clock")
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
                if !isCharging && isPluggedIn && levelBattery >= 80 {
                    Label("Charging on Hold: Desktop Mode", systemImage: "desktopcomputer")
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
                    
            }
            .padding(.vertical, 8)

            Divider().background(Color.white)

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

    private func openBatteryPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.battery") {
            openURL(url)
            onDismiss()
        }
    }
}


/// A view that displays the battery status and allows interaction to show detailed information.
struct BoringBatteryView: View {
    
    @State var batteryWidth: CGFloat = 26
    var isCharging: Bool = false
    var isInLowPowerMode: Bool = false
    var isPluggedIn: Bool = false
    var levelBattery: Float = 0
    var maxCapacity: Float = 0
    var timeToFullCharge: Int = 0
    @State var isForNotification: Bool = false
    
    @State private var showPopupMenu: Bool = false
    @State private var isPressed: Bool = false
    
    var onHoverMenuChange: (Bool) -> Void = { _ in }

    var body: some View {
        HStack {
            if Defaults[.showBatteryPercentage] {
                Text("\(Int32(levelBattery))%")
                    .font(.callout)
                    .foregroundStyle(.white)
            }
            BatteryView(
                levelBattery: levelBattery,
                isPluggedIn: isPluggedIn,
                isCharging: isCharging,
                isInLowPowerMode: isInLowPowerMode,
                batteryWidth: batteryWidth,
                isForNotification: isForNotification
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(duration: 0.2), value: isPressed)
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
            BatteryMenuView(
                isPluggedIn: isPluggedIn,
                isCharging: isCharging,
                levelBattery: levelBattery,
                maxCapacity: maxCapacity,
                timeToFullCharge: timeToFullCharge,
                isInLowPowerMode: isInLowPowerMode,
                onDismiss: { showPopupMenu = false }
            )
            .onAppear() {
                onHoverMenuChange(true)
            }
            .onHover { hovering in
                onHoverMenuChange(hovering)
            }
        }
    }
}

#Preview {
    BoringBatteryView(
        batteryWidth: 30,
        isCharging: false,
        isInLowPowerMode: false,
        isPluggedIn: true,
        levelBattery: 80,
        maxCapacity: 100,
        timeToFullCharge: 10,
        isForNotification: false
    ).frame(width: 200, height: 200)
}
