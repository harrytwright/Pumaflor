//
//  ViewController.swift
//  Pumaflor
//
//  Created by Harry Wright on 15/06/2018.
//  Copyright © 2018 Resdev. All rights reserved.
//

import Cocoa

struct Customer {
    var id: UUID
    var name: String
}

struct Sale {
    var id: UUID
    var customer: Customer
    var reference: String
}

class ViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!

    var sales: [Sale] = [] {
        didSet {
            DispatchQueue.main.sync {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.usesAlternatingRowBackgroundColors.toggle()
    }

    override func viewDidAppear() {
        
        ConnectionHandler.shared.onConnectionChange = {
            let queue = DispatchQueue.main
            
            let toolbar = Thread.isMainThread ? self.view.window?.toolbar : queue.sync {
                return self.view.window?.toolbar
            }
            
            guard let item = toolbar?.items.filter ({ $0.itemIdentifier == .websocketConnection }).first else { return }
            
            switch $0.status {
            case .unknown:
                self.setImage(NSImage.DefaultName.statusNone, in: item)
            case .connecting:
                self.setImage(.statusPartiallyAvailable, in: item)
            case .disconnected:
                self.setImage(.statusUnavailable, in: item)
            case .connected:
                self.setImage(.statusAvailable, in: item)
            }
            
            self.adjustToolbar(toolbar, for: $0.status)
        }
        
        ConnectionHandler.shared.connect()
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}

extension ViewController {
    
    func setImage(_ image: NSImage.DefaultName, in toolbarItem: NSToolbarItem) {
        if Thread.isMainThread {
            toolbarItem.image = NSImage(default: image)
        } else {
            DispatchQueue.main.sync {
                toolbarItem.image = NSImage(default: image)
            }
        }
    }
    
    func adjustToolbar(_ toolbar: NSToolbar?, for status: ConnectionHandler.Status) {
        if status == .connected || status == .disconnected {
            if Thread.isMainThread { toolbar?.removeItem(at: 4) } else { DispatchQueue.main.sync { toolbar?.removeItem(at: 4) }  }
        }
    }
    
}

extension ViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return sales.count
    }

}

extension ViewController: NSTableViewDelegate {

    fileprivate enum CellIdentifiers {
        static let kIDCell = "IDCellIdentifier"
        static let kCustomerCell = "CustomerCellIdentifier"
        static let kReferenceCell = "ReferenceCellIdentifier"
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = sales[row]

        var value: String
        var cellIdentifier: String

        if tableColumn == tableView.tableColumns[0] {
            value = item.id.uuidString
            cellIdentifier = CellIdentifiers.kIDCell
        } else if tableColumn == tableView.tableColumns[1] {
            value = item.customer.name
            cellIdentifier = CellIdentifiers.kCustomerCell
        } else {
            value = item.reference
            cellIdentifier = CellIdentifiers.kReferenceCell
        }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = value
            return cell
        }

        return nil
    }
}

