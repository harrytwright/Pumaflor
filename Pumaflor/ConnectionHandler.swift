//
//  ConnectionHandler.swift
//  Pumaflor
//
//  Created by Harry Wright on 15/06/2018.
//  Copyright © 2018 Resdev. All rights reserved.
//

import Foundation

var _handler = ConnectionHandler()

public class ConnectionHandler {
    
    public static var shared: ConnectionHandler {
        return _handler
    }
    
    public private(set) var status: Status = .unknown {
        didSet { self.onConnectionChange?(self) }
    }
    
    public var onConnectionChange: ((ConnectionHandler) -> Void)? = nil
    
    public func connect() {
        assert(self.status != .connected)
        
        self.status = .connecting
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + .seconds(2)) { [weak self] in
            self?.status = .connected
        }
    }
    
    public func disconnect() {
        assert(status != .disconnected)
        
        self.status = .disconnected
    }
}

extension ConnectionHandler {
    
    public enum Status: String, Equatable {
        case unknown = "Unknown connection"
        case connecting = "Connecting to server"
        case disconnected = "Disconnected from the server"
        case connected = "Connected to server"
    }
}
