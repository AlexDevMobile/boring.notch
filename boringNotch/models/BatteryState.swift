//
//  BatteryState.swift
//  boringNotch
//
//  Created by Alejandro Lemus Rodriguez on 23/04/25.
//

import SwiftUI

/// Represents all information related to battery status
struct BatteryState {
    /// Current battery level as percentage (0-100)
    let level: Float
    
    /// Whether device is plugged into power source
    let isPluggedIn: Bool
    
    /// Whether battery is actively charging
    let isCharging: Bool
    
    /// Whether low power mode is enabled
    let isInLowPowerMode: Bool
    
    /// Maximum capacity as percentage of design capacity
    let maxCapacity: Float
    
    /// Minutes until battery is fully charged (0 if not charging)
    let timeToFullCharge: Int
    
    /// Constants for battery thresholds
    struct Thresholds {
        static let low: Float = 20
        static let full: Float = 100
        static let optimizedCharging: Float = 80
    }
    
    /// Normalized battery level between 0-100
    var normalizedLevel: Float {
        min(100, max(0, level))
    }
    
    /// Battery level as integer percentage
    var percentage: Int {
        Int(normalizedLevel)
    }
    
    /// Returns formatted time until fully charged
    var formattedChargingTime: String {
        let hours = timeToFullCharge / 60
        let minutes = timeToFullCharge % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
    
    /// Determines the status color based on battery state
    var statusColor: Color {
        if isInLowPowerMode {
            return .yellow
        } else if level <= Thresholds.low && !isCharging && !isPluggedIn {
            return .red
        } else if isCharging || isPluggedIn || level == Thresholds.full {
            return .green
        } else {
            return .white
        }
    }
    
    /// Status description for accessibility
    var accessibilityStatus: String {
        "\(percentage)% \(isCharging ? "charging" : isPluggedIn ? "plugged in" : "")"
    }
    
    /// Returns true if device is in optimized charging mode
    var isInOptimizedCharging: Bool {
        !isCharging && isPluggedIn && level >= Thresholds.optimizedCharging
    }
}