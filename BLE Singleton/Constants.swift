//
//  Constants.swift
//  BLE Singleton
//
//  Created by Gaurav Gupta on 5/30/17.
//  Copyright © 2017 GauravGupta. All rights reserved.
//

import Foundation

struct constants {
    static let myServiceUUID = "....."
    static let myCharacteristicUUID = "....."
}

enum BLEState:String {
    case connected
    case disconnected
    case connecting
}
