//
//  AppDelegate.swift
//  Central Scout
//

import CoreBluetooth
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet var logView: NSTextView!
    @IBOutlet var javaDirectory: NSTextField!
    @IBOutlet var currentDirectory: NSTextField!
    @IBOutlet var configFileLocation: NSTextField!
    @IBOutlet var tableAvailableDevices: NSTableView!
    @IBOutlet var tableConnectedDevices: NSTableView!
    @IBOutlet var panels: NSTabView!
    @IBOutlet var btnExportExcel: NSButton!
    @IBOutlet var lblReceivedFiles: NSTextField!
    @IBOutlet var lblConnectedDevices: NSTextField!
    @IBOutlet var txtPasskey: NSTextField!
    @IBOutlet var btnRefresh: NSButton!
    
    var manager: CBCentralManager!
    
    var timerUpdateDB: Timer!
    var database: DatabaseManager!
    
    var availableDevicesUUIDs = NSMutableArray()
    var connectedDevicesUUIDs = NSMutableArray()
    
    var uuidToDevice_available = NSMutableDictionary()
    var uuidToDevice_connected = NSMutableDictionary()
    var uuidToRSSI = NSMutableDictionary()
    var uuidToName = [String : String]()
    var selectedIndex = -1
    var selectedColumn = -1
    
    var selectedDeviceAvailable: CBPeripheral?
    var selectedDeviceConnected: CBPeripheral?
    
    var passkey: String!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        LOG("Starting Bluetooth...")
        srandom(UInt32(time(nil)))
        self.manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
        logView.isEditable = false
        currentDirectory.delegate = self
        javaDirectory.delegate = self
        configFileLocation.delegate = self
        txtPasskey.delegate = self
        panels.delegate = self
        tableAvailableDevices.delegate = self
        tableAvailableDevices.dataSource = self
        tableConnectedDevices.delegate = self
        tableConnectedDevices.dataSource = self
        currentDirectory.stringValue = "\(applicationDesktopDirectory()!)/Scout"
        javaDirectory.stringValue = jarLoc()
        configFileLocation.stringValue = configLog()
        self.initSaveDirectory()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: {
            () -> Void in
            self.reloadTableData()
            self.lblConnectedDevices.stringValue = "\(self.connectedDevicesUUIDs.count)"
        })
        self.database = DatabaseManager()
        self.timerUpdateDB = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: {
            self.updateDB()
        })
    }
    
    /**
     Called to disconnect device from selected available device
     */
    @IBAction func connect(_ sender: AnyObject?) {
        if selectedIndex != -1 {
            if selectedColumn == 0 {
                if let device = selectedDeviceAvailable {
                    LOG("attempting to connect to \(device.name)")
                    self.manager.connect(device, options: [CBAdvertisementDataServiceUUIDsKey : [UUID_SERVICE]])
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {
                        () -> Void in
                        if device.state != CBPeripheralState.connected {
                            alert("Could not connected to \(device.name == nil ? device.identifier.uuidString : device.name!), maybe they passkeys don't match up")
                        }
                    })
                }
            } else {
                alert("Device already connected")
            }
        } else {
            alert("No device selected")
        }
    }
    
    /**
     Called to disconnect device from selected connected device
     */
    @IBAction func disconnect(_ sender: AnyObject?) {
        if selectedIndex != -1  {
            if selectedColumn == 1 {
                if let device = selectedDeviceConnected {
                    selectedDeviceConnected = nil
                    self.manager.cancelPeripheralConnection(device)
                }
            } else {
                alert("Can't disconnect from a device that isn't connected")
            }
        } else {
            alert("No device selected")
        }
    }
    
    func updateTableConnect(_ peripheral: CBPeripheral) {
        self.availableDevicesUUIDs.remove(peripheral.identifier)
        self.uuidToDevice_available.removeObject(forKey: peripheral.identifier)
        self.connectedDevicesUUIDs.add(peripheral.identifier)
        self.uuidToDevice_connected[peripheral.identifier] = peripheral
        self.reloadTableData()
    }
    
    func updateTableDisconnect(_ peripheral: CBPeripheral) {
        self.connectedDevicesUUIDs.remove(peripheral.identifier)
        self.uuidToDevice_connected.removeObject(forKey: peripheral.identifier)
        self.availableDevicesUUIDs.add(peripheral.identifier)
        self.uuidToDevice_available[peripheral.identifier] = peripheral
        self.reloadTableData()
    }
    
    @IBAction func generateUUID(_ sender: NSButton) {
        self.txtPasskey.stringValue = genID()
        self.passkey = self.txtPasskey.stringValue
        self.controlTextDidEndEditing(Notification(name: "" as NSNotification.Name, object: self.txtPasskey))
    }
    
    func updateDB() {
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosUserInitiated).async(execute: {
            self.database.close()
            let dir = self.javaDirectory.stringValue
            let filesDirectory = self.currentDirectory.stringValue
            let configLoc = self.configFileLocation.stringValue
            if !FileManager.default().fileExists(atPath: self.javaDirectory.stringValue) {
                alert("Please specify a location of the Scouting program Java executable file to be able to compile the information into Excel")
                return
            }
            bash("java -jar \(dir.toBashDir()) \(configLoc.toBashDir()) \(filesDirectory.toBashDir()) \(DatabaseManager.getDBDirectory().toBashDir()) false")
            self.database.open()
        })
    }
    
    /**
     Returns the current instance of the app
     */
    class func instance() -> AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        self.database.close()
        LOG("Terminating Scout... Goodbye")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    /**
     Reloads data for both tables
     */
    func reloadTableData() {
        let i = self.selectedIndex
        let col = self.selectedColumn
        self.tableAvailableDevices.reloadData()
        self.tableConnectedDevices.reloadData()
        if i != -1 {
            if col == 0 {
                self.tableAvailableDevices.selectRowIndexes(IndexSet(integer: i), byExtendingSelection: false)
            } else if col == 1 {
                self.tableConnectedDevices.selectRowIndexes(IndexSet(integer: i), byExtendingSelection: false)
            }
        }
    }
}
