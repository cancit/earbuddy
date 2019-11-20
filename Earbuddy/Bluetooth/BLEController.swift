//
//  BLEController.swift
//  Pamu Controller
//
//  Created by Can Citoglu on 16.11.2019.
//  Copyright © 2019 Can Citoglu. All rights reserved.
//

import Foundation
import CoreBluetooth
import IOBluetooth

class BLEController: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {

    static var shared = BLEController()
    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!


    func start() {
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }
    func readData() {
        if(peripheral == nil) {
            print("noConnection")
            return
        }
        peripheral.discoverCharacteristics(nil, for: peripheral.services![0])
        peripheral.discoverCharacteristics(nil, for: peripheral.services![1])
    }
    func disconnect() {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    func reconnect() {
        print(peripheral)
        centralManager.connect(peripheral, options: nil)
        centralManager.stopScan()
    }



    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", "A0-10-00-00-A7-99");
            centralManager.scanForPeripherals(withServices: nil,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("discovered!")
        print(peripheral.name)
        print(peripheral.identifier)
        //        print(advertisementData)
        //        print(RSSI)
        if(peripheral.name == "PaMu Slide") {
            self.peripheral = peripheral;
            peripheral.delegate = self
            print(peripheral)
            print(peripheral.identifier)
            print(advertisementData)
            //  peripheral.discoverServices(nil)
            central.delegate = self
            if(peripheral.state == .disconnected) {
                central.connect(peripheral, options: nil)
                central.stopScan()
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("peripheral connected")
        print(peripheral)
        peripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices")
        print(peripheral.services)
        peripheral.discoverCharacteristics(nil, for: peripheral.services![0])
        peripheral.discoverCharacteristics(nil, for: peripheral.services![1])
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor")

        print(service.characteristics)
        for c in service.characteristics! {
            peripheral.readValue(for: c)
            peripheral.setNotifyValue(true, for: c)
        }
        //        peripheral.readValue(for: service.characteristics![0])
        //        peripheral.readValue(for: service.characteristics![1])
        //        peripheral.readValue(for: service.characteristics![2])

    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor")
        if(characteristic.value == nil) {
            print("nil")
            return
        }
        let str = String(decoding: characteristic.value!, as: UTF8.self)
        print(characteristic.value)
        let intValue: Int = characteristic.value!.withUnsafeBytes { $0.pointee }
        print(intValue)
        print(str)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("peripheral disconnected")
        centralManager.scanForPeripherals(withServices: nil)
    }



    func test() {
        print("test")
    }
}
