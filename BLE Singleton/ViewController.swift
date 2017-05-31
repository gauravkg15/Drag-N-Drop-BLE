//
//  ViewController.swift
//  BLE Singleton
//
//  Created by Gaurav Gupta on 5/28/17.
//  Copyright © 2017 GauravGupta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Private properties
    
    var isBLEConnected = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var bluetoothButton: UIButton!
    @IBOutlet weak var myLabel: UILabel!
    
    // MARK: - UIViewController methods

    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothButton.setImage(UIImage(named: "bluetoothRed"), for: UIControlState())
        myLabel.text = "Disconnected."
        BLE.sharedInstance.startCentralManager()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBluetoothButton),
            name: .BLE_State_Notification, object: BLE.sharedInstance)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUILabel),
            name: .BLE_Data_Notification, object: BLE.sharedInstance)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - IBActions

extension ViewController {
    
    @IBAction func bluetoothButtonTapped(_ sender: UIButton) {
        
        if self.isBLEConnected {
            BLE.sharedInstance.disconnect()
        }
        else {
            BLE.sharedInstance.startScanningForDevicesWith(serviceUUID: constants.myServiceUUID, characteristicUUID: constants.myCharacteristicUUID)
            self.present(BLE.sharedInstance.deviceSheet!, animated: true, completion: nil)
        }
    }
}

// MARK: - Private Methods

extension ViewController {
    @objc fileprivate func updateBluetoothButton(notification: Notification) {
        DispatchQueue.main.async(execute: {
        guard let currentState = notification.userInfo!["currentState"] as! BLEState! else {return}
        
        switch currentState {
        case .connected:
            self.bluetoothButton.setImage(UIImage(named: "bluetoothGreen"), for: UIControlState())
            self.myLabel.text = "Connected! 😁"
            self.isBLEConnected = true
        case .connecting:
            self.bluetoothButton.setImage(UIImage(named: "bluetoothYellow"), for: UIControlState())
            self.myLabel.text = "Connecting..."
        case .disconnected:
            self.bluetoothButton.setImage(UIImage(named: "bluetoothRed"), for: UIControlState())
            self.isBLEConnected = false
            self.myLabel.text = "Disconnected."
        }
        })
        
    }
    
    @objc fileprivate func updateUILabel(notification: Notification) {
        myLabel.text = "Recieved data from device!"
    }
}












