//
//  CellView.swift
//  Central Scout
//
//  Created by Alex DeMeo on 1/16/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import Cocoa


class CellView: NSView {
    internal var UUID: String!
    internal var name: String?
    internal var RSSI: Int!
    private var height: CGFloat = 15
    
    init(name: String?, uuid: String, RSSI: Int) {
        super.init(frame: NSRect())
        self.name = name
        self.UUID = uuid
        self.RSSI = RSSI
        self.setView(name == nil ? "No name  " : "\(self.name!)  ", RSSI: RSSI)
    }
    
    private func getLength(_ text: String) -> CGFloat {
        return CGFloat(text.characters.count * 8) - (CGFloat(text.characters.count) * 1.5)
    }
    
    private func setView(_ text: String, RSSI: Int) {
        let nameView = NSTextField(frame: NSRect(x: self.frame.minX, y: 4, width: self.getLength(text), height: height))
        nameView.stringValue = text
        nameView.alignment = NSTextAlignment.left
        nameView.isEditable = false
        nameView.isBordered = false
        self.addSubview(nameView)
        let strength = 2 * (RSSI + 100) > 100 ? 100 : 2 * (RSSI + 100)
        let strengthText = "\(strength)%"
        let strengthView = NSTextField(frame: NSRect(x: AppDelegate.instance().tableAvailableDevices.frame.width - self.getLength(strengthText) * 2, y: 4, width: self.getLength(strengthText) * 2, height: height))
        strengthView.stringValue = strengthText
        strengthView.isBordered = false
        strengthView.isEditable = false
        strengthView.alignment = NSTextAlignment.center
        self.addSubview(strengthView)        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
