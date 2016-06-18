//
//  TextField.swift
//  Central Scout
//

import CoreBluetooth
import Cocoa

private var startText: String!
private var endText: String!

extension AppDelegate : NSControlTextEditingDelegate, NSTextFieldDelegate {
    
    override func controlTextDidBeginEditing(_ obj: Notification) {
        if obj.object! as! NSObject == currentDirectory {
            startText = currentDirectory.stringValue
        } else if obj.object! as! NSObject == javaDirectory {}
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        if obj.object! as! NSObject == currentDirectory {
            if currentDirectory.stringValue.hasSuffix("/") {
                currentDirectory.stringValue.remove(at: currentDirectory.stringValue.index(before: currentDirectory.stringValue.endIndex))
            }
            endText = currentDirectory.stringValue
            if startText != nil {
                do {
                    try FileManager.default().removeItem(atPath: startText)
                } catch {
                    LOG(error)
                }
            }
            if !FileManager.default().fileExists(atPath: endText) {
                do {
                    try FileManager.default().createDirectory(atPath: endText, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    LOG(error)
                }
            }
        } else if obj.object! as! NSObject == javaDirectory {
            self.database.close()
            if javaDirectory.stringValue.hasSuffix("/") {
                javaDirectory.stringValue.remove(at: javaDirectory.stringValue.index(before: javaDirectory.stringValue.endIndex))
            }
            self.database.open()
            if !FileManager.default().fileExists(atPath: obj.object!.stringValue) {
                if self.panels.selectedTabViewItem?.label == "Export Data" {
                    LOG("Checking validity of jar")
                    if isDirectory(obj.object!.stringValue) {
                        alert("Cannot be a directory. Must be a java .jar file")
                    } else {
                        alert("No jar file exists there")
                    }
                }
            }
        } else if obj.object! as! NSObject == txtPasskey {
            self.passkey = self.txtPasskey.stringValue
            if !isValidID(self.passkey) {
                alert("That is not a valid password- it must be 4 characters long, consiting of either numbers or letters A-F")
                return
            }
            UUID_SERVICE = CBUUID(string: "\(self.passkey!)5888-16f1-43f8-aa84-63f1544f2694")
            self.refresh()
            LOG("passkey is \(self.passkey!)")
        } else if obj.object! as! NSObject == configFileLocation {
            if configFileLocation.stringValue.hasSuffix("/") {
                configFileLocation.stringValue.remove(at: configFileLocation.stringValue.index(before: configFileLocation.stringValue.endIndex))
            }
            if !FileManager.default().fileExists(atPath: obj.object!.stringValue) {
                LOG("Checking validity of config")
                if isDirectory(obj.object!.stringValue) {
                    alert("Cannot be a directory. Must be a .txt file")
                } else {
                    alert("No text file exists there")
                }
            }
        }
    }
}
