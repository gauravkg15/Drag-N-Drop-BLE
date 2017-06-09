//
//  Constants.swift
//  BLE Singleton
//
//  Created by Gaurav Gupta on 5/30/17.
//  Copyright © 2017 GauravGupta. All rights reserved.
//

import Foundation

struct constants {
    static let myServiceUUID = "00001524-2c44-43e6-fbae-644db9ec1443"
    static let myCharacteristicUUID = "00001524-2c44-43e6-fbae-644db9ec9348"
}

enum BLEState:String {
    case connected
    case disconnected
    case connecting
}
