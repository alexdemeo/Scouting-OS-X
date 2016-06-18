



import CoreBluetooth
import Cocoa

//private var theData = NSMutableData()
private var fileCount = 0
var periphToData = [String : NSMutableData]()
extension AppDelegate: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service: CBService in peripheral.services as [CBService]! {
            LOG("Found service \(service)")
            if service.uuid.uuidString == UUID_SERVICE.uuidString {
                LOG("\tFinding characteristics of this service...")
                peripheral.discoverCharacteristics([UUID_CHARACTERISTIC_ROBOT, UUID_CHARACTERISTIC_DB], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: NSError?) {
        for char in service.characteristics! {
            let characteristic: CBCharacteristic = char as CBCharacteristic;
            if characteristic.uuid.uuidString == UUID_CHARACTERISTIC_ROBOT.uuidString {
                LOG("\t\tSetting peripheral \(peripheral.name) to notify for characteristic \(characteristic.uuid.uuidString)- This is the send data characteristic")
            } else if characteristic.uuid.uuidString == UUID_CHARACTERISTIC_DB.uuidString {
                LOG("\t\tSetting peripheral \(peripheral.name) to notify for characteristic \(characteristic.uuid.uuidString)- This is the request data characteristic")
            }
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.uuid == UUID_CHARACTERISTIC_ROBOT {
            DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosUserInitiated).sync(execute: {
                let data = characteristic.value
                LOG("Received \(data!.count) bytes of data")
                let error: NSError? = nil
                if error != nil {
                    LOG("error discovering characteristic: \(error)")
                    return
                }
                
                let stringFromData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                let id = peripheral.identifier.uuidString
                if periphToData[id] == nil {
                    periphToData[id] = NSMutableData()
                }

                if let str = stringFromData {
                    if str.isEqual(to: "EOM") {
                        LOG("DONE- Data size = \(periphToData[id]!.length)")
                        let finalData = periphToData[id]! as Data
                        do {
                            let filesDirectory = self.currentDirectory.stringValue
                            let name = UUID().uuidString
                            let everything = NSString(data: finalData, encoding: String.Encoding.utf8.rawValue)
                            try everything!.write(toFile: "\(filesDirectory)/\(name).plist", atomically: true, encoding: String.Encoding.utf8.rawValue)
                            LOG("Writing value")
                            fileCount += 1
                            self.lblReceivedFiles.stringValue = "\(fileCount)"
                        } catch {
                            LOG("problem turning data back into dictionary:: \(error)")
                        }
                        periphToData[id] = NSMutableData()
                    }  else {
                        periphToData[id]!.append(data!)
                    }
                }
            })
        } else if characteristic.uuid == UUID_CHARACTERISTIC_DB {
            let number = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)
            if let req = number {
                LOG("Got request– \(req)")
                let parts = req.components(separatedBy: "::")
                if parts[0].hasPrefix("n") {
                    self.database.retrieveTeamOnPeripheral(peripheral, withCharacteristic: characteristic, teamNum: "\(parts[1])")
                } else if parts[0].hasPrefix("i") {
                    self.database.retrieveInfoOnPeripheral(peripheral, withCharacteristic: characteristic, withInfo: parts[1].components(separatedBy: ";;"))
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.isNotifying {
            LOG("IS NOTIFYING- \(peripheral.name), characteristic: \(characteristic.uuid.uuidString)")
        } else {
            LOG("NOT NOTIFYING- \(peripheral.name), disconnecting")
            self.manager.cancelPeripheralConnection(peripheral)
            peripheral.setNotifyValue(false, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: NSError?) {
        
    }
}
