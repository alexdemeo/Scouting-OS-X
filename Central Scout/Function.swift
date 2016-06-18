//
//  Function.swift
//  Central Scout
//

import Cocoa

func bash(_ args: String...) {
    var a = args
    LOG("Executing bash:")
    let task = Task()
    task.launchPath = "/bin/bash"
    a.insert("-c", at: 0)
    task.arguments = a
//    for s in args {
//        string += "\(s) ;"
//    }
    for arg in args[0].components(separatedBy: " ") {
        print("\t\(arg)")
    }
    task.launch()
//    system(string)
}

private var count = 0
func LOG<T>(_ obj: T) {
    count += 1
    let sayWhat = "\(count) –> \t\(obj)"
    AppDelegate.instance().logView.appendText(text: "\(sayWhat)\n")
    print(sayWhat)
}

public func applicationDocumentsDirectory() -> String! {
    let paths = FileManager.default().urlsForDirectory(FileManager.SearchPathDirectory.documentDirectory, inDomains: FileManager.SearchPathDomainMask.userDomainMask)
    let documentsURL = paths[0] as URL
    return documentsURL.relativePath!
}

public func applicationDesktopDirectory() -> String! {
    let paths = FileManager.default().urlsForDirectory(FileManager.SearchPathDirectory.desktopDirectory, inDomains: FileManager.SearchPathDomainMask.userDomainMask)
    let documentsURL = paths[0] as URL
    return documentsURL.relativePath!
}

public func jarLoc() -> String {
    let loc = Bundle.main().pathForResource("Scout", ofType: "jar")!
    LOG("Jar is in:: \(loc)")
    return loc
}

public func configLog() -> String {
    let loc = Bundle.main().pathForResource("config", ofType: "txt")!
    LOG("config is in:: \(loc)")
    return loc
}

func alert(_ message: String, pullsDown: Bool, onCompletion: () -> ()) {
    LOG(message)
    let alert = NSAlert()
    alert.addButton(withTitle: "OK")
    alert.messageText = message
    if !pullsDown {
        if alert.runModal() == NSAlertFirstButtonReturn {
            onCompletion()
        }
    } else {
        alert.beginSheetModal(for: NSApp.mainWindow!, completionHandler: {
            response -> () in
            if response == NSAlertFirstButtonReturn {
                onCompletion()
            }
        })
    }
    
}
func alert(_ message: String) {
    alert(message, pullsDown: NSApp.mainWindow != nil, onCompletion: {
        _ -> () in
    })
}

func isDirectory(_ path: String) -> Bool {
    var isDir: ObjCBool = false
    if FileManager.default().fileExists(atPath: path, isDirectory: &isDir) {
        return isDir.boolValue
    } else {
        return false
    }
}

func removeDuplicates(_ array: inout NSMutableArray) {
    let temp: NSMutableArray = NSMutableArray()
    for obj in array {
        if !temp.contains(obj) {
            temp.add(obj)
        }
    }
    array = temp
}

func isValidID(_ id: String) -> Bool {
    let lwr = id.lowercased()
    func isInt(_ char: Character) -> Bool {
        for i in 0...9 {
            if String(char) == "\(i)" {
                return true
            }
        }
        return false
    }
    if lwr.characters.count != 4 {
        return false
    } else {
        for char: Character in lwr.characters {
            if !isInt(char) {
                if  char != "a" &&
                    char != "b" &&
                    char != "c" &&
                    char != "d" &&
                    char != "e" &&
                    char != "f" {
                        return false
                }
            }
        }
    }
    return true;
}

func genID() -> String {
    var id: String! = ""
    for _ in 0..<4 {
        let r = arc4random() % 16
        if r <= 9 {
            id.append("\(r)")
        } else {
            switch r {
            case 10: id.append("a")
            case 11: id.append("b")
            case 12: id.append("c")
            case 13: id.append("d")
            case 14: id.append("e")
            case 15: id.append("f")
            default: break
            }
        }
    }
    return id
}

infix operator += {}

func +=(start: inout String, append: String) {
    start.append(append)
}

func +=(start: inout NSString, append: NSString) {
    start = "\(start)\(append)"
}

func +=(start: inout String, append: NSString) {
    start.append("\(append)")
}

func +=(start: inout NSString, append: String) {
    start = "\(start)\(append)"
}
