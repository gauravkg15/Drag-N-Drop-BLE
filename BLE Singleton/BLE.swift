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
    
    // MARK: - Properties
    
    //CoreBluetooth properties
    var centralManager:CBCentralManager!
    var activeDevice:CBPeripheral?
    var activeCharacteristic:CBCharacteristic?
    
    //Alert properties
    public var UIAlert:UIAlertController?
    public var deviceSheet:UIAlertController?
    
    struct myDevice {
        static let ServiceUUID:CBUUID = CBUUID(string: "* Insert Service UUID here *")
        static let CharactersticUUID:CBUUID = CBUUID(string: "* Insert Characteristic UUID here *")
    }
    
    // MARK: - Init method
    
    override init() {
        super.init()
        let centralManagerQueue = DispatchQueue(label: "BLE queue", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
    }
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
        centralManager.scanForPeripherals(withServices: [myDevice.ServiceUUID], options: nil)
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
        UIAlert = UIAlertController(title: "Error: failed to connect.",
                                    message: "Please try again.", preferredStyle: .alert)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == activeDevice {  self.reset() }
    }
}

// MARK: - CBPeripheralDelegate protocal conformance

extension BLE: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        UIAlert = UIAlertController(title: "Error:", message: "Please try again.", preferredStyle: .alert)
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
        UIAlert = UIAlertController(title: "Error:", message: "Please try again.", preferredStyle: .alert)
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
        UIAlert = UIAlertController(title: "Error:", message: "Please try again.", preferredStyle: .alert)
        if error != nil {
            // post notification
            return
        }
        
        guard let data = characteristic.value else {
            //post notification
            return
        }
        
        if characteristic.uuid == myDevice.CharactersticUUID {
            // do something...
            //post notification
            print(data)
        }
        
        // else if characteristic.uuid == myDevice.SecondCharacteristicUUID
        // do something...
    }
}

// MARK: - Helper methods

extension BLE {
    func disconnect() {
        if let activeDevice = activeDevice {
            centralManager.cancelPeripheralConnection(activeDevice)
        }
    }
    
    func reset() {
        activeDevice = nil
    }
    
}
