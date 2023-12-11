//
//  CloudKeyValueStore.swift
//  Notes 365
//
//  Created by kiran ipc on 11/12/23.
//

import Foundation

let cloudMigrationKey = "migration_check_status_2"

class CloudKeyValueStore {
    static let shared = CloudKeyValueStore()
    
    private var keyStore = NSUbiquitousKeyValueStore()
    
    init() {
        keyStore.synchronize()
    }
    
    func set(value: Bool, for key: String) {
        keyStore.setValue(value, forKey: key)
        keyStore.synchronize()
    }
    
    func get(key: String) -> Any? {
        keyStore.synchronize()
        return keyStore.bool(forKey: key)
    }
}
