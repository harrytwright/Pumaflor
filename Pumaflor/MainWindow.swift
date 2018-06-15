//
//  MainWindow.swift
//  Pumaflor
//
//  Created by Harry Wright on 15/06/2018.
//  Copyright © 2018 Resdev. All rights reserved.
//

import Cocoa

class MainWindow: NSWindow {

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)

        self.titleVisibility = .hidden
    }

}
