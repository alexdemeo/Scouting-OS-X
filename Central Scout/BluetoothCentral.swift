//
//  Bluetooth.swift
//  Central Scout
//

import CoreBluetooth
import Cocoa

public var UUID_SERVICE: CBUUID = CBUUID(string: "444B")
public let UUID_CHARACTERISTIC_ROBOT: CBUUID = CBUUID(string: "20D0C428-B763-4016-8AC6-4B4B3A6865D9")
public let UUID_CHARACTERISTIC_DB: CBUUID = CBUUID(string: "80A37B7F-0563-409B-B320-8C1768CE6A58")

private var deviceExists = [String : Bool]()
extension AppDelegate : CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber) {
        let uuid = peripheral.identifier.uuidString
        self.uuidToName[uuid] = peripheral.name
        self.uuidToRSSI[uuid] = RSSI
        if !availableDevicesUUIDs.contains(peripheral.identifier) {
            availableDevicesUUIDs.add(peripheral.identifier)
        }
        uuidToDevice_available[peripheral.identifier] = peripheral
        LOG("advertisement with identifier: \(uuid),\n\tstate: \(peripheral.state),\n\tname: \(peripheral.name),\n\tservices: \(peripheral.services),\n\tdescription: \(advertisementData.description),\n\tRSSI: \(RSSI)")
        self.reloadTableData()
        deviceExists[uuid] = true
        if advertisementData[CBAdvertisementDataServiceUUIDsKey] == nil {
//            return
        }
        self.manager.connect(peripheral, options: nil)
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: {
            self.availableDevicesUUIDs.remove(peripheral.identifier)
            
        })
      
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        LOG("Connected to \(peripheral.name)")
        selectedDeviceAvailable = nil
        if connectedDevicesUUIDs.contains(peripheral.identifier) {
            return
        }
        self.updateTableConnect(peripheral)
        peripheral.delegate = self
        peripheral.discoverServices([UUID_SERVICE])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        LOG("Disconnected from \(peripheral.name)")
        self.updateTableDisconnect(peripheral)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            LOG("Central manager state POWERED ON")
            self.refresh()
        case .poweredOff:
            LOG("Bluetooth is OFF")
            alert("Bluetooth is appears to be off, please turn it on", pullsDown: NSApp.mainWindow != nil, onCompletion: {})
        case .unsupported:
            LOG("Ble not supported on device")
            alert("Bluetooth Low Energy (BLE) is not supported on this device\tPlease use this app on a device that supports BLE\nThe program will now exit", pullsDown: NSApp.mainWindow != nil, onCompletion: {
                _ -> () in
                exit(0)
            })
        default:
            LOG("Changed state to \(central.state)")
        }
    }
}
