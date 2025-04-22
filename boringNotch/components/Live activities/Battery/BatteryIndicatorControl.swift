//
//  BatteryIndicatorControl.swift
//  boringNotch
//
//  Created by Alejandro Lemus Rodriguez on 22/04/25.
//

import SwiftUI
import Defaults

struct BatteryIndicatorControl: View {
    
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
            BatteryIconView(
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
            BatteryDetailPopoverView(
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
    BatteryIndicatorControl(
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
