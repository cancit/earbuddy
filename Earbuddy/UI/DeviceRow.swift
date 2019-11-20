
//
//  DeviceRow.swift
//  Pamu Controller
//
//  Created by Can Citoglu on 20.11.2019.
//  Copyright © 2019 Can Citoglu. All rights reserved.
//

import SwiftUI

struct DeviceRow: View {
    var deviceInfo: BluetoothDeviceInfo
    var body: some View {
        VStack(alignment: .leading){
            Text(deviceInfo.name).font(.body)
            Text(deviceInfo.address).font(.caption).opacity(0.75)
                .padding(.top,2)
            Divider()
        }
    }
}

struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow(deviceInfo: BluetoothDeviceInfo(name: "Ticpods", address: "111-11-111"))
    }
}
