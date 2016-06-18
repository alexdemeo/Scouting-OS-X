
//
//  Table.swift
//  Central Scout
//

import Cocoa
import CoreBluetooth


extension AppDelegate : NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case self.tableAvailableDevices:
            return self.availableDevicesUUIDs.count
        case self.tableConnectedDevices:
            return self.connectedDevicesUUIDs.count
        default: return 0
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view: CellView?
        switch tableColumn!.identifier {
        case "available":
            let UUID = availableDevicesUUIDs.object(at: row).uuidString
            let name: String? = uuidToName[UUID!]
            view = CellView(name: name, uuid: UUID!, RSSI: uuidToRSSI[UUID!]! as! Int)
        case "connected":
            let UUID = connectedDevicesUUIDs.object(at: row).uuidString
            let name: String? = uuidToName[UUID!]
            view = CellView(name: name, uuid: UUID!, RSSI: uuidToRSSI[UUID!]! as! Int)
        default: break
        }
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView: NSTableView = notification.object! as! NSTableView
        let rowIndex = tableView.selectedRow
        let columnIndex = tableView.selectedColumn
        if rowIndex == -1 {
            self.selectedIndex = -1
            return
        }
        let cellView: CellView? = tableView.view(atColumn: columnIndex, row: rowIndex, makeIfNecessary: true) as? CellView
        if let cell = cellView {
            let nsuuid = UUID(uuidString: cell.UUID)
            selectedIndex = rowIndex
            if selectedIndex != -1 {
                switch tableView as NSObject {
                case self.tableAvailableDevices:
                    selectedColumn = 0
                    let device: CBPeripheral = uuidToDevice_available[nsuuid!] as! CBPeripheral
                    selectedDeviceAvailable = device
                    LOG("Selected from available devices named:: \(device.name), \(device.identifier.uuidString)")
                case self.tableConnectedDevices:
                    selectedColumn = 1
                    let device: CBPeripheral = uuidToDevice_connected[nsuuid!] as! CBPeripheral
                    selectedDeviceConnected = device
                    LOG("Selected from connected devices named:: \(device.name), \(device.identifier.uuidString)")
                default:
                    selectedColumn = -1
                    break
                }
            }
        }
    }
}
