//
//  Extension
//  Central Scout
//

import Cocoa
import CoreBluetooth

extension NSTextView {
    func appendText(text: String) {
        DispatchQueue.main.async(execute: {
            let attr = AttributedString(string: text)
            self.textStorage?.append(attr)
            self.scrollRangeToVisible(NSMakeRange(self.string!.lengthOfBytes(using: String.Encoding.utf8), 0))
        })
    }
}

extension CBPeripheral {
    func isNotifyingCharacteristic() -> Bool {
        var n: [Bool] = [Bool]()
        if self.services == nil {
            LOG("Peripheral has no services")
            return false
        } else if self.services!.isEmpty {
            LOG("Peripheral services are empty")
            return false
        }
        for service in self.services! {
            if service.characteristics == nil {
                LOG("Peripheral has no characteristics")
                return false
            } else if service.characteristics!.isEmpty {
                LOG("Peripheral characteristics are empty")
                return false
            }
            for char in service.characteristics! {
                n.append(char.isNotifying)
            }
        }
        if !n.contains(true) {
            LOG("Peripheral is NOT notifying")
            return false
        } else {
            LOG("Peripheral IS notifying")
            return true
        }
    }
}

extension String {
    func toBashDir() -> String {
        var start = ""
        for p in self.components(separatedBy: " ") {
            start += "\(p)\\ "
        }
        
        start.remove(at: start.index(start.endIndex, offsetBy: -2))
        LOG("TO BASH DIR::: \(start)")
        return start
    }
}

extension NSImage {
    func rotateByDegrees(degrees: CGFloat) -> NSImage {
        let rotatedSize = NSSize(width: self.size.width, height: self.size.height)
        let rotatedImage = NSImage(size: rotatedSize)
        let transform = NSAffineTransform()
        transform.translateX(by: self.size.width / 2, yBy: self.size.height / 2)
        transform.rotate(byDegrees: degrees)
        transform.translateX(by: -rotatedSize.width / 2, yBy: -rotatedSize.height / 2)
        rotatedImage.lockFocus()
        transform.concat()
        self.draw(at: NSPoint(x: 0, y: 0), from: NSZeroRect, operation: NSCompositingOperation.copy, fraction: 1.0)
        rotatedImage.unlockFocus()
        return rotatedImage
    }
}
