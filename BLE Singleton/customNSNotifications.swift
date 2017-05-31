//
//  customNSNotifications.swift
//  BLE Singleton
//
//  Created by Gaurav Gupta on 5/31/17.
//  Copyright © 2017 GauravGupta. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let BLE_State_Notification = Notification.Name(rawValue: "BLE_State_Notification")
    static let BLE_Data_Notification = Notification.Name(rawValue: "BLE_Data_Notification")
}
