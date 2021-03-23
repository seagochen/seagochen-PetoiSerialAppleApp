//
//  BluetoothLowEnergyHandler.swift
//  PetoiSerialSwift
//
//  Created by Orlando Chen on 2021/3/23.
//

import Foundation
import CoreBluetooth

// 传出蓝牙当前连接的设备发送过来的信息
typealias BleDataBlock = (_ data: Data) -> Void

// 传出蓝牙当前搜索到的设备信息
typealias BlePeripheralsBlock = (_ pArray: [CBPeripheral]) -> Void

// 当设备连接成功时，记录该设备，用于请求设备版本号
typealias BleConnectedBlock = (_ peripheral: CBPeripheral, _ characteristic:CBCharacteristic) -> Void


class BluetoothLowEnergy: NSObject {
    
    // 提供给其他类进行调用
    // static let shared = BluetoothLowEnergy()
    
    private let BLE_WRITE_UUID = "xxxx"
    private let BLE_NOTIFY_UUID = "xxxx"
    
    // 中心对象
    var central : CBCentralManager!
    
    // 把中心设备扫描的外置设备保存起来
    var deviceList: [CBPeripheral] = []
    
    // 当前连接的设备
    var peripheral: CBPeripheral!
        
    // 发送数据特征: 连接到设备之后可以把需要用到的特征保存起来，方便使用
    var writeChar: CBCharacteristic?
    
    // 消息数据特征：连接到设备之后可以把需要用到的特征保存起来，方便使用
    var notifyChar: CBCharacteristic?
    
    // 传出扫描到的设备
    var backPeripheralsBlock: BlePeripheralsBlock?
    
    // 传出当前连接成功的设备
    var backConnectedBlock: BleConnectedBlock?
    
    //传出数据
    var backDataBlock: BleDataBlock?
    
    
    // 0. 初始化
    override init() {
        super.init()
        
        // 初始化中心设备管理器
        // 它的delegate函数为centralManagerDidUpdateState
        // 其回调消息处理函数为：centralManager
        self.central = CBCentralManager.init(delegate:self, queue:nil, options:[CBCentralManagerOptionShowPowerAlertKey:false])
        
        // 初始化设备列表
        self.deviceList = []
    }

    // 1. 扫描设备
    func startScanPeripheral(serviceUUIDS: [CBUUID]?,
                             options: [String: AnyObject]?) {
        // 清空列表
        deviceList = []
        
        // 开始进行扫描
        self.central?.scanForPeripherals(withServices: serviceUUIDS, options: options)
    }
     
    // 2. 停止扫描
    func stopScanPeripheral() {
        self.central?.stopScan()
    }
    
    // 3.1. 获取搜索到的外接设备
    func getPeripheralList()-> [CBPeripheral] {
        return deviceList
    }
    
    // 3.2. 选择保存当前选择的设备
    func selectPeripheral(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    // 4. 连结设备
    // 连接设备之前要先设置代理，正常情况，当第一次获取外设peripheral的时候就会同时设置代理
    func connect() {
        if (peripheral.state != CBPeripheralState.connected) {
            central?.connect(peripheral , options: nil)
            
            // 将外接设备的回掉函数连结到self
            // 回掉消息处理函数为：peripheral
            peripheral.delegate = self
        }
    }
    
    // 5. 发送数据
    func sendData(data: Data, peripheral:CBPeripheral, characteristic:CBCharacteristic, type: CBCharacteristicWriteType = CBCharacteristicWriteType.withResponse) {
        
        let step = 20
        for index in stride(from: 0, to: data.count, by: step) {
            var len = data.count - index
            if len > step {
                len = step
            }
            let pData: Data = (data as NSData).subdata(with: NSRange(location: index, length: len))
            peripheral.writeValue(pData, for: characteristic, type: type)
        }
    }
    
    // 6. 断开连结
    func disconnect() {
        central?.cancelPeripheralConnection(peripheral)
    }
}

extension BluetoothLowEnergy: CBCentralManagerDelegate {
    
    // MARK: 检查运行这个App的设备是不是支持BLE。
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            NSLog("powered on")
            
        } else {
            
            switch central.state {
            case .poweredOff:
                NSLog("BLE powered off")
            case .unknown:
                NSLog("BLE unknown")
            case .resetting:
                NSLog("BLE ressetting")
            case .unsupported:
                NSLog("BLE unsupported")
            case .unauthorized:
                NSLog("BLE unauthorized")
            case .poweredOn:
                NSLog("BLE poweredOn")
            @unknown default:
                NSLog("BLE default")
            }
        }
    }
    
    
    // 开始扫描之后会扫描到蓝牙设备，扫描到之后走到这个代理方法
    // MARK: 中心管理器扫描到了设备
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        NSLog("\(#function): 中心管理器扫描到了设备 central:\(central),peripheral:\(peripheral)")
        
        guard !deviceList.contains(peripheral), let deviceName = peripheral.name, deviceName.count > 0 else {
            return
        }
        
        // 把设备加入到列表中
        deviceList.append(peripheral)
        
        // 传出去实时刷新
        if let backPeripheralsBlock = backPeripheralsBlock {
            backPeripheralsBlock(deviceList)
        }
    }
       
    // MARK: 连接外设成功，开始发现服务
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("\(#function): 连接外设成功 central:\(central),peripheral:\(peripheral)")
        
         // 设置代理
         peripheral.delegate = self
         
         // 开始发现服务
         peripheral.discoverServices(nil)
    }

       
    // MARK: 连接外设失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral:
                            CBPeripheral, error: Error?) {
        NSLog("\(#function): 连接外设失败 \(String(describing: peripheral.name)) error：\(String(describing: error))")
        
        // 这里可以发通知出去告诉设备连接界面连接失败
    }
       
    // MARK: 连接丢失
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral:
                            CBPeripheral, error: Error?) {
        
        NSLog("\(#function): 连接丢失，\(String(describing: peripheral.name)) error：\(String(describing: error))")
        
       // 这里可以发通知出去告诉设备连接界面连接丢失
    }
}


// MARK: 外置设备被绑定后的事件响应
extension BluetoothLowEnergy: CBPeripheralDelegate {
    
    // MARK: 匹配对应服务UUID
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error  {
            NSLog("\(#function)搜索到服务-出错\n设备(peripheral)：\(String(describing: peripheral.name)) 搜索服务(Services)失败：\(error)\n")
            return
        } else {
            NSLog("\(#function)搜索到服务\n设备(peripheral)：\(String(describing: peripheral.name))\n")
        }
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
    // MARK: 服务下的特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let _ = error {
            NSLog("\(#function)发现特征\n设备(peripheral)：\(String(describing: peripheral.name))\n服务(service)：\(String(describing: service))\n扫描特征(Characteristics)失败：\(String(describing: error))\n")
            return
        } else {
            NSLog("\(#function)发现特征\n设备(peripheral)：\(String(describing: peripheral.name))\n服务(service)：\(String(describing: service))\n服务下的特征：\(service.characteristics ?? [])\n")
        }
          
        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid.uuidString.lowercased().isEqual(BLE_WRITE_UUID) {
                self.peripheral = peripheral
                self.writeChar = characteristic
                
                if let block = backConnectedBlock {
                    block(peripheral,characteristic)
                }
            } else if characteristic.uuid.uuidString.lowercased().isEqual(BLE_NOTIFY_UUID) {
                
                //该组参数无用
                self.notifyChar = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
              
            //此处代表连接成功
          }
    }

    
    // MARK: 获取外设发来的数据
    // 注意，所有的，不管是 read , notify 的特征的值都是在这里读取
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let _ = error {
            return
        }
        //拿到设备发送过来的值,传出去并进行处理
        if let dataBlock = backDataBlock, let data = characteristic.value {
            dataBlock(data)
        }
    }
    
    //MARK: 检测中心向外设写数据是否成功
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("\(#function)\n发送数据失败！错误信息：\(error)")
        }
    }
}
