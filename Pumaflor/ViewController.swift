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

    }

    @discardableResult
    override func presentError(_ error: Error) -> Bool {
        return DispatchQueue.main.sync {
            return super.presentError(error)
        }
    }

    override func viewDidAppear() {

        let request = URLRequest(url: URL(string: "http://www.apple.com")!)

        let queue = DispatchQueue.main
        let task = URLSession.shared.dataTask(with: request) { (_, _, error) in
            defer { queue.sync { self.view.window?.toolbar?.removeItem(at: 4) } }

            let _items = queue.sync { self.view.window?.toolbar?.items }
            guard error == nil, let items = _items else { self.presentError(error!); return }

            for item in items where item.itemIdentifier == .websocketConnection {
                queue.sync {
                    item.image = NSImage(default: .statusAvailable)
                }
            }

            let customer = Customer(id: UUID(), name: "Aurélien Géron")
            let newSale = Sale(id: UUID(), customer: customer, reference: "066681")
            self.sales.append(newSale)
        }

        task.resume()
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
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

