//
//  TabView.swift
//  Central Scout
//

import Cocoa

extension AppDelegate : NSTabViewDelegate {
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        switch tabViewItem!.label {
        case "Export Data":
            initSaveDirectory()
            if !FileManager.default().fileExists(atPath: javaDirectory.stringValue) {
                alert("No java jar exists at the selected path\nPlease specify where it is")
            }
            if !FileManager.default().fileExists(atPath: configFileLocation.stringValue) {
                alert("No config exists at that path\nPlease specify where it is")
            }
            self.window.makeFirstResponder(self.btnExportExcel)
        default:
            return
        }
    }
    
    func initSaveDirectory() {
        if !FileManager.default().fileExists(atPath: currentDirectory.stringValue) {
            do {
                try FileManager.default().createDirectory(atPath: self.currentDirectory.stringValue, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
    }
}
