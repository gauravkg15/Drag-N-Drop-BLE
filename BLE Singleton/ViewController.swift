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
        
        // DispatchQueue.main.async {
        if isBLEConnected {
            BLE.sharedInstance.disconnect()
        }
        else {
            BLE.sharedInstance.startScanningForDevicesWith(serviceUUID: myServiceUUID, characteristicUUID: myCharacteristicUUID)
            self.present(BLE.sharedInstance.deviceSheet!, animated: true, completion: nil)
        }
        //  }
        
    }
}

// MARK: - Private Methods

extension ViewController {
    @objc fileprivate func updateBluetoothButton(notification: Notification) {

        guard let currentState = notification.userInfo!["currentState"] as! BLEState! else {return}
        
        switch currentState {
        case .connected:
            bluetoothButton.setImage(UIImage(named: "bluetoothGreen"), for: UIControlState())
            myLabel.text = "Connected! 😁"
            isBLEConnected = true
        case .connecting:
            bluetoothButton.setImage(UIImage(named: "bluetoothYellow"), for: UIControlState())
            myLabel.text = "Connecting..."
        case .disconnected:
            bluetoothButton.setImage(UIImage(named: "bluetoothRed"), for: UIControlState())
            isBLEConnected = false
            myLabel.text = "Disconnected."
        }
    }
    
    @objc fileprivate func updateUILabel(notification: Notification) {
        myLabel.text = "Recieved data from device!"
    }
}












