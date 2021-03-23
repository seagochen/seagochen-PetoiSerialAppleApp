//
//  ViewController.swift
//  PetoiSerialSwift
//
//  Created by Orlando Chen on 2021/3/23.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController {
    var bluetooth: BluetoothLowEnergy!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 初始化蓝牙
        bluetooth = BluetoothLowEnergy()
        
        // 搜索蓝牙
        bluetooth.startScanPeripheral(serviceUUIDS: nil, options: nil)
    }
    
    @IBAction func stopBluetoothScanPressed(_ sender: Any) {
        NSLog("stopBluetoothScanPressed")
        
        // 停止搜索蓝牙
        bluetooth.stopScanPeripheral()
        
        // 获取已经连结的蓝牙设备
        let deviceList = bluetooth.getPeripheralList()
        if !deviceList.isEmpty {
            for device in deviceList {
                NSLog(device.name ?? "")
            }
        }
    }
    
    
}
