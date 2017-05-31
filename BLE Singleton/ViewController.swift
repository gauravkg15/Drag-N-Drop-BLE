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
    let myServiceUUID = "..."
    let myCharacteristicUUID = "..."
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var bluetoothButton: UIButton!
    @IBOutlet weak var myLabel: UILabel!
    
    // MARK: - UIViewController methods

    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothButton.setImage(UIImage(named: "bluetoothRed"), for: UIControlState())
        myLabel.text = "Disconnected."
        BLE.sharedInstance.startCentralManager()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBluetoothButton), name: BLE_STATE_NOTIFICATION, object: BLE.sharedInstance)
        NotificationCenter.default.addObserver(self, selector: #selector(recievedDataFromDevice), name: BLE_DATA_NOTIFICATION, object: BLE.sharedInstance)
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

        guard let connectionState = notification.userInfo!["currentState"] as! String! else {return}
        
        switch connectionState {
        case "CONNECTED":
            bluetoothButton.setImage(UIImage(named: "bluetoothGreen"), for: UIControlState())
            myLabel.text = "Connected! 😁"
            isBLEConnected = true
        case "CONNECTING":
            bluetoothButton.setImage(UIImage(named: "bluetoothYellow"), for: UIControlState())
            myLabel.text = "Connecting..."
        case "DISCONNECTED":
            bluetoothButton.setImage(UIImage(named: "bluetoothRed"), for: UIControlState())
            isBLEConnected = false
            myLabel.text = "Disconnected."
        default: ()
        }
    }
    
    @objc fileprivate func recievedDataFromDevice(notification: Notification) {
        myLabel.text = "Recieved data from device!"
    }
}












