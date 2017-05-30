//
//  BLE.swift
//  BLE Singleton
//
//  Created by Gaurav Gupta on 5/28/17.
//  Copyright © 2017 GauravGupta. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

class BLE: NSObject {
    
    // MARK: - BLE shared instance 
    static let sharedInstance = BLE()
    
    // MARK: - Properties
    
    //CoreBluetooth properties
    var centralManager:CBCentralManager!
    var activeDevice:CBPeripheral?
    var activeCharacteristic:CBCharacteristic?
    
    //UIAlert properties
    public var deviceAlert:UIAlertController?
    public var deviceSheet:UIAlertController?
    
    //Device UUID properties
    struct myDevice {
        static let ServiceUUID:CBUUID = CBUUID(string: "* Insert Service UUID here *")
        static let CharactersticUUID:CBUUID = CBUUID(string: "* Insert Characteristic UUID here *")
    }
    
    // MARK: - Init method
    
    private override init() { }
}

// MARK: - CBCentralManagerDelegte protocal conformance

extension BLE: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn: break
        case .poweredOff: break
        case .resetting: self.disconnect()
        case .unauthorized: break
        case .unsupported: break
        case .unknown:   break
        }
    }
    
    public func startScanning() {
        activeDevice = nil
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        deviceSheet = UIAlertController(title: "Please choose a device.",
                                        message: "Connect to:", preferredStyle: .actionSheet)
        deviceSheet!.addAction(UIAlertAction(title: "Cancel",
                                             style: .cancel, handler: { action -> Void in self.centralManager.stopScan() }))
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let availableDevice = UIAlertAction(title: peripheral.name, style: .default, handler: {
            action -> Void in
            self.centralManager.connect(peripheral,
                options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : true])
        })
        deviceSheet!.addAction(availableDevice)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager.stopScan()
        activeDevice = peripheral
        activeDevice?.delegate = self
        activeDevice?.discoverServices([myDevice.ServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        deviceAlert = UIAlertController(title: "Error: failed to connect.",
                                        message: "Please try again.", preferredStyle: .alert)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == activeDevice {  self.clearDevices() }
    }
}

// MARK: - CBPeripheralDelegate protocal conformance

extension BLE: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        deviceAlert = UIAlertController(title: "Error:", message: "Please try again.", preferredStyle: .alert)
        if error != nil {
            // post notification
            return
        }
        
        guard let services = peripheral.services else {
            // post notification
            return
        }
        for thisService in services {
            if thisService.uuid == myDevice.ServiceUUID {
                activeDevice?.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        deviceAlert = UIAlertController(title: "Error:", message: "Please try again.",
                                        preferredStyle: .alert)
        if error != nil {
            // post notification
            return
        }
        
        guard let characteristics = service.characteristics else {
            // post notification
            return
        }
        
        for thisCharacteristic in characteristics {
            if (thisCharacteristic.uuid == myDevice.CharactersticUUID) {
                activeCharacteristic = thisCharacteristic
                peripheral.setNotifyValue(true, for: activeCharacteristic!)
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        deviceAlert = UIAlertController(title: "Error:", message: "Please try again.", preferredStyle: .alert)
        if error != nil {
            // post notification
            return
        }
        
        guard let dataFromDevice = characteristic.value else { return }
        
        if characteristic.uuid == myDevice.CharactersticUUID {
            // do something...
            //post notification
            print(dataFromDevice)
        }
        
        // else if characteristic.uuid == myDevice.SecondCharacteristicUUID
        // do something...
    }
}

// MARK: - Helper methods

extension BLE {
    func startCentralManager() {
        let centralManagerQueue = DispatchQueue(label: "BLE queue", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
    }
    
    func resetCentralManger() {
        let centralManagerQueue = DispatchQueue(label: "BLE queue", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
    }
    
    func disconnect() {
        if let activeCharacteristic = activeCharacteristic {
            activeDevice?.setNotifyValue(false, for: activeCharacteristic)
        }
        if let activeDevice = activeDevice {
            centralManager.cancelPeripheralConnection(activeDevice)
        }
    }
    
    func clearDevices() {
        activeDevice = nil
    }
    
}
