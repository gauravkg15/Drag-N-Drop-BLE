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
    let myServiceUUID = "*** insert service UUID here ***"
    let myCharacteristicUUID = "*** insert characteristic UUID here ***"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var bluetoothButton: UIButton!
    
    // MARK: - UIViewController methods

    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothButton.setImage(UIImage(named: "bluetoothRed"), for: UIControlState())
        BLE.sharedInstance.startCentralManager()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBluetoothButton), name: BLE_NOTIFICATION, object: BLE.sharedInstance)
    }
}

// MARK: - IBActions

extension ViewController {
    
    @IBAction func bluetoothButtonTapped(_ sender: UIButton) {
        
        // DispatchQueue.main.async {
        if self.isBLEConnected {
            BLE.sharedInstance.disconnect()
            isBLEConnected = false
        }
        else {
            BLE.sharedInstance.startScanningForDevicesWith(serviceUUID: myServiceUUID, characteristicUUID: myCharacteristicUUID)
            self.present(BLE.sharedInstance.deviceSheet!, animated: true, completion: nil)
            isBLEConnected = true
        }
        //  }
        
    }
}

// MARK: - Private Methods

extension ViewController {
    @objc fileprivate func updateBluetoothButton(notification: Notification) {

        guard let connectionState = notification.userInfo!["currentConnection"] as! String! else {return}
        
        switch connectionState {
        case "CONNECTED":
            bluetoothButton.setImage(UIImage(named: "bluetoothGreen"), for: UIControlState())
        case "CONNECTING":
            bluetoothButton.setImage(UIImage(named: "bluetoothYellow"), for: UIControlState())
        case "DISCONNECTED":
            bluetoothButton.setImage(UIImage(named: "bluetoothRed"), for: UIControlState())
        default: ()
        }
    }
}












