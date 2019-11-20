//
//  BluetoothController.swift
//  Pamu Controller
//
//  Created by Can Citoglu on 16.11.2019.
//  Copyright © 2019 Can Citoglu. All rights reserved.
//

import Foundation
import IOBluetooth

protocol BluetoothConnectionDelegate {
    func onConnected()
    func onDisconnected()
}

class BluetoothController: NSObject, IOBluetoothHandsFreeDeviceDelegate {
    static var shared = BluetoothController()
    var delegate: BluetoothConnectionDelegate?
    var bluetoothDevice: IOBluetoothDevice?
    var deviceList: [BluetoothDeviceInfo] = []
    var fakeDisconnect = 0
    var manualDisconnect = false
    func setDelegate(delegate: BluetoothConnectionDelegate) {
        self.delegate = delegate;
    }

    func refresh(){
        deviceList.removeAll(keepingCapacity: false)
       
    }
    func reinit(address:String){
        
        initilize(address)

    }
    func start() {
        IOBluetoothDevice.register(forConnectNotifications: self, selector: #selector(connected))
        initilize("a0-10-00-00-a7-99")
    }
    func initilize(_ address:String){
    deviceList.removeAll(keepingCapacity: false)
    IOBluetoothDevice.pairedDevices().forEach({ (device) in
                        guard let device = device as? IOBluetoothDevice,
                            let addressString = device.addressString,
                            let deviceName = device.name
                            else { return }
                        print("\(addressString) - \(deviceName)")
                        deviceList.append(BluetoothDeviceInfo(name: deviceName, address: addressString))
                    })
     
      guard let bluetoothDevice = IOBluetoothDevice(addressString: address ) else {
          print("Device not found!")
          // printAndNotify("Device not found", notify: notify)
          // exit(-2)
          return
      }
      self.bluetoothDevice = bluetoothDevice
        bluetoothDevice.register(forDisconnectNotification: self, selector: #selector(disconnected))
     if(bluetoothDevice.isConnected()) {
         self.delegate?.onConnected()
     } else {
         self.delegate?.onDisconnected()
     }
    }
    @objc func connected() {
        print("connected")
//        if(fakeDisconnect == 0) {
//            bluetoothDevice?.closeConnection()
//            fakeDisconnect = 1
//            return
//        }

        if(self.delegate != nil) {
            self.delegate!.onConnected()
        }
    }
    @objc func disconnected() {
        print("disconnected")
//        if(fakeDisconnect == 1) {
//            bluetoothDevice?.openConnection()
//            fakeDisconnect = 2
//        } else
//        if(fakeDisconnect == 2) {
//            fakeDisconnect = 0
//        }
        if(self.delegate != nil) {
            self.delegate!.onDisconnected()
        }
    }
    func readData() {
        // bluetoothDevice?.getLinkType()
        // print(bluetoothDevice)
        
         print(bluetoothDevice?.services)
        bluetoothDevice?.performSDPQuery(bluetoothDevice)
        // BLEController.shared.readData()
        //  bluetoothDevice.getau
        // IOBluetoothHandsFreeDevice.init(device: (bluetoothDevice), delegate: self)
        //  bluetoothDevice?.connectionHandle
    }

    func disconnect() {
        self.bluetoothDevice?.closeConnection()
        manualDisconnect = true
    }
    func reconnect() {
        self.bluetoothDevice?.openConnection()
        manualDisconnect = false
    }
    func disconnectAndConnectAgain() {
        self.bluetoothDevice?.closeConnection()
        self.bluetoothDevice?.openConnection()
    }
    func fixSourceDisableBug() {
           if( self.bluetoothDevice?.isConnected() == true && manualDisconnect == false){
           self.disconnectAndConnectAgain()
           }
       }
}
