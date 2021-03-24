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
    
    @IBAction func startBluetoothScanPressed(_ sender: Any) {
        
        NSLog("startBluetoothScanPressed")
        
        // 搜索蓝牙
        bluetooth.startScanPeripheral(serviceUUIDS: nil, options: nil)
    }
    
    @IBAction func connectToDevicePressed(_ sender: Any) {
        
        // 获取已经连结的蓝牙设备
        let deviceList = bluetooth.getPeripheralList()
        if !deviceList.isEmpty {
            for device in deviceList {
                if device.name == "DeOrlandoiPhone11" {
//                if device.name == "JDY-23A-BLE" {
                    
                    // connect to device
                    bluetooth.connect(peripheral: device)
                    break
                }
            }
        }
    }
    
    @IBAction func sendCmdPressed(_ sender: Any) {
        if bluetooth.isConnected() {
//            NSLog("\(bluetooth.writeChar?.description) \(bluetooth.peripheral.description)")
            bluetooth.disconnect()
        }
    }
    
    
}
