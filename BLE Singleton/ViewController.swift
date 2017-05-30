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
    
    // MARK: - UIViewController methods

    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothButton.setImage(UIImage(named: "bluetoothRed"), for: UIControlState())
        BLE.sharedInstance.startCentralManager()
    }
}

// MARK: - IBActions

extension ViewController {
    
    @IBAction func bluetoothButtonTapped(_ sender: UIButton) {
        if isBLEConnected {
            BLE.sharedInstance.disconnect()
        }
        else {
            BLE.sharedInstance.startScanning()
        }
        
    }
    
}

