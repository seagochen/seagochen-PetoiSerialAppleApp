//
//  ViewController.swift
//  PetoiSerialSwift
//
//  Created by Orlando Chen on 2021/3/23.
//

import UIKit
import CoreBluetooth
import HexColors
import RMessage
import ActionSheetPicker_3_0

class MainViewController: UIViewController  {
    
    var bluetooth: BLEPeripheralHandler!  // 蓝牙设备管理类
    var peripheral: CBPeripheral?  // 蓝牙BLE设备
    var txdChar: CBCharacteristic?  // 发送数据接口
    var rxdChar: CBCharacteristic?  // 接收数据接口
    var bleMsgHandler: BLEMessageDetector?  // 接收和发送蓝牙数据
    var devices: [CBPeripheral]!  // 设置蓝牙搜索的pickerview
    
    // 蓝牙输出文本缓冲
    var outputString: String = ""
    
    // iOS 控件
    @IBOutlet weak var bleSearchBtn: UIButton!
    @IBOutlet weak var calibrationBtn: UIButton!
    @IBOutlet weak var restBtn: UIButton!
    @IBOutlet weak var gyroscopeBtn: UIButton!
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var selectedDeviceLabel: UILabel!
    @IBOutlet weak var connectBtn: UIButton!
    
    
    // MARK: view被创建后，初始化一些基础设置
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 对控件进行调整
        initWidgets()
        
        // 对信道蓝牙相关通信做准备
        loadBleInformation()
    }
    
    // MARK: view即将被销毁前，把蓝牙设备信息存放回delegate，其实不用存放bluetooth，不过为了工整
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // save ble information to appdelegate
        saveBleInformation()
    }
    

    // MARK: 对蓝牙等设备初始化
    func loadBleInformation() {
        
        // 从AppDelegate获取存放在全局的蓝牙等外设信息
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        bluetooth = delegate.bluetooth
        peripheral = delegate.peripheral
        txdChar = delegate.txdChar
        rxdChar = delegate.rxdChar
        bleMsgHandler = delegate.bleMsgHandler
        devices = delegate.devices
        
        // 是否有在处理蓝牙消息
        if let handler = bleMsgHandler {
            if !handler.isRunning() { // 没有运行
                handler.startListen(target: self, selector: #selector(self.recv))
            }
        }
    }
    
    // MARK: 存储蓝牙设备信息
    func saveBleInformation() {
        
        // 准备把蓝牙外设的信息存入到AppDelegate里
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.bluetooth = bluetooth
        delegate.peripheral = peripheral
        delegate.txdChar = txdChar
        delegate.rxdChar = rxdChar
        delegate.bleMsgHandler = bleMsgHandler
        delegate.devices = devices
        
        if let handler = bleMsgHandler {
            if handler.isRunning() { // 暂停对蓝牙消息的处理
                bleMsgHandler?.stopListen()
            }
        }
    }
    
    
    // MARK: 对面板控件进行初始化的函数
    func initWidgets() {
        /**
         * 标签风格
         */
        // 下划线的形式
        WidgetTools.underline(label: selectedDeviceLabel)
        // 修改标签内容
        selectedDeviceLabel.text = "Device: None"
       
      
        /**
         * 按钮
         */
        // 给按钮设置为圆角矩形
        WidgetTools.roundCorner(button: bleSearchBtn)
        WidgetTools.roundCorner(button: calibrationBtn)
        WidgetTools.roundCorner(button: restBtn)
        WidgetTools.roundCorner(button: gyroscopeBtn)
        WidgetTools.roundCorner(button: connectBtn)

        WidgetTools.disable(button: connectBtn)
        disableAllFuncBtns()
        
        
        /**
         * 输出文本框
         */
        outputTextView.text = "Output:\n\t"
        WidgetTools.roundCorner(textView: outputTextView, boardColor: bleSearchBtn.backgroundColor!)
    }


    func disableAllFuncBtns() {
        WidgetTools.disable(button: calibrationBtn)
        WidgetTools.disable(button: restBtn)
        WidgetTools.disable(button: gyroscopeBtn)
    }
    

    func enableAllFuncBtns() {
        WidgetTools.enable(button: calibrationBtn)
        WidgetTools.enable(button: restBtn)
        WidgetTools.enable(button: gyroscopeBtn)
    }
    
    
    // MARK: 搜索设备按钮，事件反馈
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        
        // 开始搜索可用设备
        bluetooth.startScanPeripheral(serviceUUIDS: nil, options: nil)
    
        // 清空列表，避免出现异常
        devices = []

        // 把按钮设置为不可用
        WidgetTools.disable(button: bleSearchBtn)

        // 创建一个子线程，去检查可用的蓝牙设备
        Thread(target: self, selector: #selector(searchBLEDevices), object: nil).start()
    }
    

    // MARK: 连结设备按钮，事件反馈
    @IBAction func connectBtnPressed(_ sender: UIButton) {

        switch sender.currentTitle {
        case "Connect":
            // 对设备进行连结
            bluetooth.connect(peripheral: self.peripheral!)
                
            // 创建一个子线程，去检查蓝牙消息管道是否连通
            Thread(target: self, selector: #selector(setupBLETunnels), object: nil).start()
                
            // 在信道创建完成之前，不允许用户再点击按钮
            WidgetTools.disable(button: connectBtn)

        case "Disconnect":
            // 停止alarm
            bleMsgHandler?.stopListen()
            
            // 断开蓝牙连结
            bluetooth.disconnect(peripheral: peripheral!)
            
            // 修改按钮文字
            connectBtn.setTitle("Connect", for: .normal)

            // 关闭功能按钮
            disableAllFuncBtns()
            
            // 打开连结按钮
            WidgetTools.enable(button: connectBtn)

        default:
            break
        }
    }
    
    // MARK: 休息
    @IBAction func restPressed(_ sender: UIButton) {
        outputString = ""
        
        bluetooth.sendData(data: Converter.cvtString(toData: "d"), peripheral: peripheral!, characteristic: txdChar!)
    }
    
    // MARK: 陀螺仪
    @IBAction func gyrosocopePressed(_ sender: UIButton) {
        outputString = ""
        
        bluetooth.sendData(data: Converter.cvtString(toData: "g"), peripheral: peripheral!, characteristic: txdChar!)
    }
    
    // MARK: 校准
    @IBAction func calibrationBtnPressed(_ sender: Any) {
        // 先发送一个c
        bluetooth.sendData(data: Converter.cvtString(toData: "c"), peripheral: peripheral!, characteristic: txdChar!)

        // 把蓝牙设备信息存储一下
        saveBleInformation()

        // 跳转到 CalibrationVC
        let vc = self.storyboard?.instantiateViewController(identifier: "CalibrationVC") as! CalibrationViewController
        self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true, completion: nil)
    }

    // MARK: 蓝牙连结处理函数
    func connectBLEDevice(index: Int) -> Bool {
        
        // 测试是否已有连结建立
        if let _peripheral = self.peripheral {
            // 蓝牙正在与远程设备连结
            if bluetooth.isConnected(peripheral: _peripheral) {
                bluetooth.disconnect(peripheral: _peripheral) // 断开连结
            }
        }
        
        // 记录当前被用户选定的蓝牙设备
        self.peripheral = devices[index]
        
        // 设置选定的蓝牙设备
        guard self.peripheral != nil else {
            
            // 连结失败，弹出错误信息
            RMessage.showNotification(withTitle: "蓝牙设备连结失败", subtitle: "未能连结到蓝牙设备，请重新尝试!", type: .error, customTypeName: nil, duration: 3, callback: nil)
            
            // 错误中断
            return false
        }

        // 建立连结中
        return true
    }
}


extension MainViewController {
    // MARK: 线程，查找BEL设备
    @objc func searchBLEDevices() {
        sleep(1)

        // 停止扫描
        bluetooth.stopScanPeripheral()

        // 清空列表，避免出现异常
        devices = []

        // 把可用设备写入列表中
        let peripherals = bluetooth.getPeripheralList()
        if !peripherals.isEmpty {
            for device in peripherals {
                if device.name != nil {
                    devices.append(device)
                }
            }
        }

        // 弹出选择菜单
        DispatchQueue.main.async {

            let sender = self.bleSearchBtn

            if self.devices.count > 0 {
            
                // 获取可用设备的设备名
                var deviceNames:[String] = []
                for dev in self.devices {
                    deviceNames.append(dev.name!)
                }
            
                ActionSheetStringPicker.show(withTitle: "可用蓝牙设备", rows: deviceNames, initialSelection: 0, doneBlock: { [self]
                    picker, indexes, values in

                    // for debug
                    print("values = \(String(describing: values))")
                    print("indexes = \(indexes)")
                    print("picker = \(String(describing: picker))")
                    
                    // 显示选择的内容
                    self.selectedDeviceLabel.text = "Device: " + String(describing: values!)
                    
                    // 设置蓝牙连结
                    if self.connectBLEDevice(index: indexes) {
                        WidgetTools.enable(button: connectBtn)
                    }

                    return
                }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
            } else {  // 没有可用的设备列表，要求用户进行设备搜索
            
                RMessage.showNotification(withTitle: "蓝牙设备列表为空", subtitle: "未能可用的设备列表，请先完成搜索过程后再尝试!", type: .normal, customTypeName: nil, duration: 3, callback: nil)
            }

            // 把按钮重新设置为可用
            WidgetTools.enable(button: self.bleSearchBtn)
        }
    }
    

    // MARK: 线程，蓝牙消息处理函数
    @objc func recv() {
        let data = bluetooth.recvData()
        if data != nil {
            if let feedback = String(data: data!, encoding: .utf8) {
                
                // 将当前的文本粘贴到输出的文本后面
                let trimstr = "Output:\n\t" + feedback.replacingOccurrences(of: "\r\n", with: "\n")
                
                // 更新数据
                DispatchQueue.main.async {
                    self.outputTextView.text = trimstr
                }
            }
        }
    }


    // MARK: 线程，尝试建立管道
    @objc func setupBLETunnels() {
        
        for times in 1...10 {
            
            // 等待连结是否完成，没有完成就休眠等待
            if !bluetooth.isConnected(peripheral: self.peripheral!) {
                
                // 失败：休眠5秒
                sleep(5)
            } else {
                
                // 成功：跳出检查状态，进入到信道检测环节
                break
            }
            
            if times == 10 { // 没有连结成功，失败
                
                // 断开连结
                bluetooth.disconnect(peripheral: self.peripheral!)
    
                // 回到主线程
                DispatchQueue.main.async {
                    
                    // 弹出错误信息
                    RMessage.showNotification(withTitle: "蓝牙设备连结失败", subtitle: "未能连结到设备，请重新尝试!", type: .error, customTypeName: nil, duration: 3, callback: nil)
                    
                    // 允许按钮可用
                    WidgetTools.enable(button: self.connectBtn)
                }
                
                // 任务中断
                return
            }
        }
        
        // 获取可用的消息信道
        let characteristics = bluetooth.getCharacteristic()
        
        rxdChar = characteristics[0] // Petoi默认rxd串口信道
        txdChar = characteristics[1] // Petoi默认txd串口信道
                
        // 启动后台线程，监听RXD信道数据
        if let rxdChar = rxdChar {
                    
            // 设置监听信道
            bluetooth.setNotifyCharacteristic(peripheral: self.peripheral!, notify: rxdChar)
            
            // 回到主线程
            DispatchQueue.main.async {
                
                // 启动后台定时器，开始接收并处理来自蓝牙设备的数据
                self.bleMsgHandler?.startListen(target: self, selector: #selector(self.recv))
                
                // 弹出消息提示框
                RMessage.showNotification(withTitle: "蓝牙连结成功", subtitle: "已连结到设备\(String(describing: self.peripheral!.name!))，开始监听消息中...", type: .success, customTypeName: nil, duration: 3, callback: nil)
                
                // 修改按钮信息
                self.connectBtn.setTitle("Disconnect", for: .normal)
                WidgetTools.enable(button: self.connectBtn)

                // 允许用户使用全部的按钮
                self.enableAllFuncBtns()
            }
            
        } else {
            
            // 回到主线程，修改按钮信息
            DispatchQueue.main.async {
                
                // 弹出错误信息
                RMessage.showNotification(withTitle: "蓝牙设备连结失败", subtitle: "未能查找到可用的串口信号，请重新尝试!", type: .error, customTypeName: nil, duration: 3, callback: nil)
                
                // 修改按钮信息
                WidgetTools.enable(button: self.connectBtn)
            }
        }
    }
}


extension MainViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}
