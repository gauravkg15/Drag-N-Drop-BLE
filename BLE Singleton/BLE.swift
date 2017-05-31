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
        static var ServiceUUID:CBUUID?
        static var CharactersticUUID:CBUUID?
    }
    
    // MARK: - Init method
    
    private override init() { }
}

// MARK: - CBCentralManagerDelegte protocal conformance

extension BLE: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn: break
        case .poweredOff: self.clearDevices()
        case .resetting: self.disconnect()
        case .unauthorized: break
        case .unsupported: break
        case .unknown:   break
        }
    }
    
    public func startScanningForDevicesWith(serviceUUID: String, characteristicUUID: String) {
        self.disconnect()
        myDevice.ServiceUUID = CBUUID(string: serviceUUID)
        myDevice.CharactersticUUID = CBUUID(string: characteristicUUID)
        self.createDeviceSheet()
        centralManager.scanForPeripherals(withServices: [myDevice.ServiceUUID!], options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var title = "Unknown Device"
        if (peripheral.name != nil) { title = peripheral.name!}
        let availableDevice = UIAlertAction(title: title , style: .default, handler: {
            action -> Void in
            self.centralManager.connect(peripheral,
                options: [CBConnectPeripheralOptionNotifyOnNotificationKey : true])
        })
        DispatchQueue.main.async(execute: {self.deviceSheet!.addAction(availableDevice)})
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager.stopScan()
        postBLEConnectionStateNotification(.connecting)
        activeDevice = peripheral
        activeDevice?.delegate = self
        activeDevice?.discoverServices([myDevice.ServiceUUID!])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.createErrorAlert()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == activeDevice {
            postBLEConnectionStateNotification(.disconnected)
            clearDevices()
        }
    }
}

// MARK: - CBPeripheralDelegate protocal conformance

extension BLE: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            self.createErrorAlert()
            return
        }
        guard let services = peripheral.services else { return}
        for thisService in services {
            if thisService.uuid == myDevice.ServiceUUID {
                activeDevice?.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            self.createErrorAlert()
            // post notification
            return
        }
        guard let characteristics = service.characteristics else { return }
        postBLEConnectionStateNotification(.connected)
        for thisCharacteristic in characteristics {
            if (thisCharacteristic.uuid == myDevice.CharactersticUUID) {
                activeCharacteristic = thisCharacteristic
                peripheral.setNotifyValue(true, for: activeCharacteristic!)
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        self.createErrorAlert()
        if error != nil {
            // post notification
            return
        }
        
        guard let dataFromDevice = characteristic.value else { return }
        
        if characteristic.uuid == myDevice.CharactersticUUID {
            postRecievedDataFromDeviceNotification()
            print(dataFromDevice)
        }
        
        // else if characteristic.uuid == myDevice.SecondCharacteristicUUID
        // do something...
    }
}

// MARK: - Helper methods

extension BLE {
    
    // MARK: BLE Methods
    
    func startCentralManager() {
        let centralManagerQueue = DispatchQueue(label: "BLE queue", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
    }
    
    func resetCentralManger() {
        self.disconnect()
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
    
    fileprivate func clearDevices() {
        activeDevice = nil
        activeCharacteristic = nil
        myDevice.ServiceUUID = nil
        myDevice.CharactersticUUID = nil
    }
    
    // MARK: UIActionSheet Methods
    
    fileprivate func createDeviceSheet() {
        deviceSheet = UIAlertController(title: "Please choose a device.",
            message: "Connect to:", preferredStyle: .actionSheet)
        deviceSheet!.addAction(UIAlertAction(title: "Cancel", style: .cancel,
            handler: { action -> Void in self.centralManager.stopScan() }))
    }
    
    fileprivate func createErrorAlert() {
        deviceAlert = UIAlertController(title: "Error: failed to connect.",
            message: "Please try again.", preferredStyle: .alert)
    }
    
    // MARK: NSNotificationCenter Methods
    
    fileprivate func postBLEConnectionStateNotification(_ state: BLEState) {
        let connectionDetails = ["currentState" : state]
        NotificationCenter.default.post(name: .BLE_State_Notification, object: self, userInfo: connectionDetails)
    }
    
    fileprivate func postRecievedDataFromDeviceNotification() {
        NotificationCenter.default.post(name: .BLE_Data_Notification, object: self, userInfo: nil)
    }
}







