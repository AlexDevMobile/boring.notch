import Foundation
import Cocoa
import SwiftUI
import IOKit.ps
import Defaults

/// A view model that manages and monitors the battery status of the device
class BatteryStatusViewModel: ObservableObject {
    
    static let shared = BatteryStatusViewModel()

    @ObservedObject var coordinator = BoringViewCoordinator.shared

    @Published private(set) var levelBattery: Float = 0.0
    @Published private(set) var maxCapacity: Float = 0.0
    @Published private(set) var isPluggedIn: Bool = false
    @Published private(set) var isCharging: Bool = false
    @Published private(set) var isInLowPowerMode: Bool = false
    @Published private(set) var isInitial: Bool = false
    @Published private(set) var timeToFullCharge: Int = 0
    @Published private(set) var statusText: String = ""
    @Published var isHoveringMenu: Bool = false

    /// The battery state object that contains all relevant battery information
    var batteryState: BatteryState {
        return BatteryState(
            level: levelBattery,
            isPluggedIn: isPluggedIn,
            isCharging: isCharging,
            isInLowPowerMode: isInLowPowerMode,
            maxCapacity: maxCapacity,
            timeToFullCharge: timeToFullCharge
        )
    }
    
    /// The battery activity manager instance to monitor battery events
    private let managerBattery = BatteryActivityManager.shared
    /// The ID of the battery activity manager observer
    private var managerBatteryId: Int?

    /// Initializes the view model with a given BoringViewModel instance
    /// - Parameter vm: The BoringViewModel instance
    private init() {
        setupPowerStatus()
        setupMonitor()
    }

    /// Sets up the initial power status by fetching battery information
    private func setupPowerStatus() {
        let batteryInfo = managerBattery.initializeBatteryInfo()
        updateBatteryInfo(batteryInfo)
    }

    /// Sets up the monitor to observe battery events
    private func setupMonitor() {
        managerBatteryId = managerBattery.addObserver { [weak self] event in
            guard let self = self else { return }
            self.handleBatteryEvent(event)
        }
    }
    
    /// Handles battery events and updates the corresponding properties
    /// - Parameter event: The battery event to handle
    private func handleBatteryEvent(_ event: BatteryActivityManager.BatteryEvent)  {
        switch event {
                case .powerSourceChanged(let isPluggedIn):
                    print("🔌 Power source: \(isPluggedIn ? "Connected" : "Disconnected")")
                    animateStatusChange(
                        property: { self.isPluggedIn = isPluggedIn },
                        statusText: isPluggedIn ? "Plugged In" : "Unplugged", 
                    )
                
                case .batteryLevelChanged(let level):
                    print("🔋 Battery level: \(Int(level))%")
                    let isCritical = level <= 10 && !isCharging && !isPluggedIn
                    if isCritical {
                        animateStatusChange(
                            property: { self.levelBattery = level },
                            statusText: "Battery Critical: \(Int(level))%",
                        )
                    }
                    else {
                        animatePropertyChange { self.levelBattery = level }
                    }
                    
                case .lowPowerModeChanged(let isEnabled):
                    print("⚡ Low power mode: \(isEnabled ? "Enabled" : "Disabled")")
                    animateStatusChange(
                        property: { self.isInLowPowerMode = isEnabled },
                        statusText: "Low Power: \(isEnabled ? "On" : "Off")"
                    )
                
                case .isChargingChanged(let isCharging):
                    print("🔌 Charging: \(isCharging ? "Yes" : "No")")
                    print("maxCapacity: \(self.maxCapacity)")
                    print("levelBattery: \(self.levelBattery)")
                    animateStatusChange(
                        property: { self.isCharging = isCharging },
                        statusText: isCharging ? "Charging battery" : (self.levelBattery < self.maxCapacity ? "Not charging" : "Full charge"),
                    )
                
                case .timeToFullChargeChanged(let time):
                    print("🕒 Time to full charge: \(time) minutes")
                    animatePropertyChange { self.timeToFullCharge = time }
                
                case .maxCapacityChanged(let capacity):
                    print("🔋 Max capacity: \(capacity)")
                    animatePropertyChange { self.maxCapacity = capacity }
                
                case .error(let description):
                    print("⚠️ Error: \(description)")
            }
    }

    /// Updates the battery information with the given BatteryInfo instance
    /// - Parameter batteryInfo: The BatteryInfo instance containing the battery data
    private func updateBatteryInfo(_ batteryInfo: BatteryInfo) {
        withAnimation {
            self.levelBattery = batteryInfo.currentCapacity
            self.isPluggedIn = batteryInfo.isPluggedIn
            self.isCharging = batteryInfo.isCharging
            self.isInLowPowerMode = batteryInfo.isInLowPowerMode
            self.timeToFullCharge = batteryInfo.timeToFullCharge
            self.maxCapacity = batteryInfo.maxCapacity
            self.statusText = batteryInfo.isPluggedIn ? "Plugged In" : "Unplugged"
        }
        notifyImportantChangeStatus(delay: coordinator.firstLaunch ? 6 : 0.0)
        withAnimation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                if self.isCharging {
                    self.statusText = "Charging: Yes"
                } else if self.isInLowPowerMode {
                    self.statusText = "Low Power: On"
                }
            }
        }
    }
    
    /// Notifies important changes in the battery status with an optional delay
    /// - Parameter delay: The delay before notifying the change, default is 0.0
    private func notifyImportantChangeStatus(delay: Double = 0.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self: BatteryStatusViewModel else { return }
            self.coordinator.toggleExpandingView(status: true, type: .battery)
            NSAccessibility.post(
                element: NSApp.mainWindow as Any,
                notification: .announcementRequested,
                userInfo: [.announcement: self.statusText]
            )
        }
    }

    deinit {
        print("🔌 Cleaning up battery monitoring...")
        if let managerBatteryId: Int = managerBatteryId {
            managerBattery.removeObserver(byId: managerBatteryId)
        }
    }
    
}

private extension BatteryStatusViewModel {
    /// Animates a state change with status text update and optional notification
    func animateStatusChange(
        property: () -> Void,
        statusText: String
    ) {
        withAnimation {
            property()
            self.statusText = statusText
        }
        notifyImportantChangeStatus()
    }
    
    /// Animates a simple property change
    func animatePropertyChange(_ changes: () -> Void) {
        withAnimation {
            changes()
        }
    }
}
