//
//  MainWindow.swift
//  Pumaflor
//
//  Created by Harry Wright on 15/06/2018.
//  Copyright © 2018 Resdev. All rights reserved.
//

import Cocoa
import SnapKit

extension NSToolbarItem.Identifier {

    static var mainSidebarController = NSToolbarItem.Identifier(rawValue: "MainWindowSideBarController")

    static var websocketConnection = NSToolbarItem.Identifier(rawValue: "WebsocketConnection")

    static var progressItem = NSToolbarItem.Identifier(rawValue: "ProgressItem")

}

extension NSToolbarItem {

    static var progressIdicator: NSToolbarItem = {
        let indicator = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
        indicator.style = .spinning
        indicator.startAnimation(nil)

        let item = NSToolbarItem(itemIdentifier: .progressItem)
        item.label = "Connecting"
        item.view = indicator

        return item
    }()

}

extension NSImage {

    struct DefaultName: RawRepresentable {

        typealias RawValue = String

        var rawValue: String

        init(rawValue: String) {
            self.rawValue = rawValue
        }

        static var goLeftTemplate: DefaultName = DefaultName(rawValue: NSImage.goLeftTemplateName)

        static var goRightTemplate: DefaultName = DefaultName(rawValue: NSImage.goRightTemplateName)

        static var statusAvailable: DefaultName = DefaultName(rawValue: NSImage.statusAvailableName)

        static var statusPartiallyAvailable: DefaultName = DefaultName(rawValue: NSImage.statusPartiallyAvailableName)

        static var statusUnavailable: DefaultName = DefaultName(rawValue: NSImage.statusUnavailableName)

        static var statusNone: DefaultName = DefaultName(rawValue: NSImage.statusNoneName)

    }

    convenience init(default name: DefaultName) {
        self.init(named: name.rawValue)!
    }

}

class MainWindow: NSWindow, NSToolbarDelegate {

    lazy var toolbarIdentifier: [NSToolbarItem.Identifier] = {
        return [.flexibleSpace, .space, .mainSidebarController, .websocketConnection, .progressItem]
    }()

    override init(
        contentRect: NSRect,
        styleMask style: StyleMask,
        backing backingStoreType: BackingStoreType,
        defer flag: Bool
        )
    {
        super.init(
            contentRect: contentRect,
            styleMask: style,
            backing: backingStoreType,
            defer: flag
        )

        self.titleVisibility = .hidden
        commonInit()
    }

    func commonInit() {
        let toolbar = NSToolbar(identifier: "MainWindowToolBar")
        toolbar.allowsUserCustomization.toggle()
        toolbar.delegate = self

        self.toolbar = toolbar
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let toolbarItem: NSToolbarItem

        if itemIdentifier == .mainSidebarController {
            let group = NSToolbarItemGroup(itemIdentifier: itemIdentifier)

            let itemA = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "LeftSideItem"))
            let itemB = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "RightSideItem"))

            let segmented = NSSegmentedControl(frame: NSRect(x: 0, y: 0, width: 85, height: 40))
            segmented.segmentStyle = .texturedRounded
            segmented.trackingMode = .selectAny
            segmented.segmentCount = 2

            // Don't set a label: these would appear inside the button
            segmented.setImage(NSImage(default: .goLeftTemplate), forSegment: 0)
            segmented.setWidth(40, forSegment: 0)
            segmented.setImage(NSImage(default: .goRightTemplate), forSegment: 1)
            segmented.setWidth(40, forSegment: 1)

            // `group.label` would overwrite segment labels
            group.paletteLabel = "Navigation"
            group.subitems = [itemA, itemB]
            group.view = segmented

            toolbarItem = group
        } else if itemIdentifier == .websocketConnection {
            toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.label = "Connection"
            toolbarItem.toolTip = "Connection status"

            let iconImage = NSImage(default: .statusNone)

            let button = NSButton(frame: NSRect(x: 0, y: 0, width: 40, height: 40))
            button.title = ""
            button.image = iconImage
            button.bezelStyle = .texturedRounded
            button.setButtonType(.momentaryLight)
            button.target = self
            button.action = #selector(onConnectionStatePressed(_:))
            
            toolbarItem.view = button
        } else if itemIdentifier == .progressItem {
            toolbarItem = .progressIdicator
        } else {
            toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        }

        return toolbarItem
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarAllowedItemIdentifiers(toolbar)
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarIdentifier
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }
    
    @objc func onConnectionStatePressed(_ sender: NSButton) {
        let fakeVC = TestVC()
        fakeVC.label.stringValue = ConnectionHandler.shared.status.rawValue
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 150, height: 40)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = fakeVC
        
        let rect = sender.convert(sender.bounds, to: NSApp.mainWindow?.contentView)
        popover.show(relativeTo: rect, of: (NSApp.mainWindow?.contentView)!, preferredEdge: .minY)
    }

}

class TestVC: NSViewController {
    
    lazy var label: NSTextField  = {
        let text = NSTextField(frame: .zero)
        text.isBezeled = false
        text.drawsBackground = false
        text.isEditable = false
        text.isSelectable = false
        return text
    }()
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
    }
}
