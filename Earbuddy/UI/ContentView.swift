//
//  ContentView.swift
//  Pamu Controller
//
//  Created by Can Citoglu on 16.11.2019.
//  Copyright © 2019 Can Citoglu. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var totalClicked: Int = 0
    @ObservedObject var devices = BluetoothDeviceInfoStore(devices: BluetoothController.shared.deviceList)
    @State var selectKeeper = Set<String>(arrayLiteral: UserDefaults().string(forKey: "bluetoothAddress") ?? "")

    var body: some View {
        VStack {
            List(devices.devices, id: \.address,selection: $selectKeeper) { deviceInfo in
                DeviceRow(deviceInfo: deviceInfo)
            }
            Button(action: {
                var address = self.selectKeeper.popFirst()
                UserDefaults().set(address,forKey:"bluetoothAddress" )
                BluetoothController.shared.reinit(address: address!)
                AppDelegate.window.close()
            }) {
                Text("OK")
            }
//            Button(action: {
//                BluetoothController.shared.readData()
//            }) {
//                Text("Read Data")
//            }
//            Button(action: { BluetoothController.shared.disconnect()
//            }) {
//                Text("Disconnect")
//            }
//            Button(action: { BluetoothController.shared.reconnect()
//            }) {
//                Text("Reconnect")
//            }
//            Button(action: {
//                BLEController.shared.readData()
//            }) {
//                Text("Read BLE Data")
//            }

        }

    }
}
struct BluetoothDeviceInfo {
    var name: String
    var address: String
}
final class BluetoothDeviceInfoStore: ObservableObject {
    @Published var devices: [BluetoothDeviceInfo]
    
    init(devices: [BluetoothDeviceInfo]) {
        self.devices = devices
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
