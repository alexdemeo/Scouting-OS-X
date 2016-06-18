//
//  Button.swift
//  Central Scout
//

import Cocoa
import CoreBluetooth

extension AppDelegate {
    
    private func getSelectionDirectory(_ filetype: String, executable: (String?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Java Scouting jar"
        openPanel.showsResizeIndicator = false
        openPanel.showsHiddenFiles = false
        openPanel.allowsMultipleSelection = false
        if filetype != "directory" {
            openPanel.allowedFileTypes = [filetype]
            openPanel.canChooseDirectories = false
            openPanel.canCreateDirectories = false
        } else {
            openPanel.canChooseDirectories = true
            openPanel.canCreateDirectories = true
        }
        openPanel.beginSheetModal(for: AppDelegate.instance().window, completionHandler: {
            result in
            if result == NSModalResponseOK {
                executable(openPanel.urls[0].path)
            }
        })
    }
    
    @IBAction func getJavaExecutableDirectory(_ sender: NSButton) {
        self.database.close()
        self.getSelectionDirectory("jar", executable: {
            path in
            self.javaDirectory.stringValue = path == nil ? "None" : path!
            self.database.open()
        })
    }
    
    @IBAction func getCurrentScoutingDirectory(_ sender: NSButton) {
        self.getSelectionDirectory("directory", executable: {
            path in
            self.currentDirectory.stringValue = path == nil ? "None" : path!
        })
    }
    
    @IBAction func compile(_ sender: NSButton) {
        let dir = javaDirectory.stringValue
        let filesDirectory = currentDirectory.stringValue
        let configLoc = configFileLocation.stringValue
        if !FileManager.default().fileExists(atPath: javaDirectory.stringValue) {
            alert("Please specify a location of the Scouting program Java executable file to be able to compile the information into Excel")
            return
        }
        LOG("Compiling to excel by executing java in directory: \(dir)")
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosUserInitiated).async(execute: {
            let newDir = filesDirectory.substring(to: (filesDirectory.range(of: "/", options: NSString.CompareOptions.backwardsSearch, range: nil, locale: nil)?.lowerBound)!)
            LOG("results.xlsx will be located at: \(newDir)")
            bash("java -jar \(dir.toBashDir()) \(configLoc.toBashDir()) \(filesDirectory.toBashDir()) \(DatabaseManager.getDBDirectory().toBashDir()) true \(newDir.toBashDir())")
        })
    }
    
    @IBAction func btnUpdateDB(_ sender: NSButton) {
        self.timerUpdateDB.fire()
    }
    
    /**
     Save the LOG, because why not
     */
    @IBAction func saveLogToFile(_ sender: AnyObject) {
        let allText = self.logView.textStorage?.string
        self.getSelectionDirectory("directory", executable: {
            path in
            do {
                if path == nil {
                    return
                }
                try allText?.write(toFile: "\(path!)/LOG.txt", atomically: true, encoding: String.Encoding.utf8)
            } catch {
                LOG(error)
            }
        })
    }
    
    
    /**
     Refresh scanning
     */
    @IBAction func btnRefresh(_ sender: NSButton) {
        self.refresh()
    }
    
    @IBAction func getConfigLocation(_ sender: NSButton) {
        self.getSelectionDirectory("txt", executable: {
            path in
            self.configFileLocation.stringValue = path == nil ? "None" : path!
        })
    }
    
    func refresh() {
        LOG("Refreshing...")
        self.btnRefresh.isEnabled = false
        manager.stopScan()
        manager.scanForPeripherals(withServices: [UUID_SERVICE], options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
        manager.retrievePeripherals(withIdentifiers: self.availableDevicesUUIDs as AnyObject as! [UUID])
        self.reloadTableData()
        var cnt = 0;
        var t: Timer!
        t = Timer.scheduledTimer(withTimeInterval: 0.0055555556, repeats: true, block: {
            _ in
            cnt += 1
            if cnt >= 180 {
                self.btnRefresh.isEnabled = true
                t.invalidate()
            } else {
                self.btnRefresh.image = self.btnRefresh.image?.rotateByDegrees(degrees: 4)
            }
        })
    }
    
    @IBAction func resetDB(_ sender: NSButton) {
        LOG("Reset database")
        do {
            try FileManager.default().removeItem(atPath: DatabaseManager.getDBLocation())
        } catch {
            alert("Couldn't remove database\nIt probably doesn't exist")
        }
    }
}
