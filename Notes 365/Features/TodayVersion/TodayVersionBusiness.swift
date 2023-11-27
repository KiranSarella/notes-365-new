//
//  TimelineBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/11/22.
//

import Foundation
import SwiftData

class TodayVersionBusiness {
    
    static let baseVersionFolderName = Constants.todayBaseVersionFolderName
    
    static var folderDatePath: String {
        return Date().string(format: "yyyy-MM-dd")
    }
    
    var modelContext: ModelContext?
    
    init() {
        registerNotebookLoadedNotification()
    }
    
    deinit {
        removeNotebookLoadedNotification()
    }
    
    func registerNotebookLoadedNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookLoadedNotification(_:)), name: Notification.Name.notebookContentLoaded, object: nil)
    }
    
    func removeNotebookLoadedNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentLoaded, object: nil)
    }
    
    @objc func handleNotebookLoadedNotification(_ notification: Notification) {
        // get filename from userInfo
        guard 
            let uuid = notification.userInfo?["id"] as? UUID,
            let modelContext = self.modelContext
        else { return }
        
        // ask NotebookBusiness object for content
        let notebookContent = NotebookContent(notebookID: uuid, content: "dummy")
        
//        NotebookContentBusiness.fetchNotebookContent(for: uuid, in: modelContext)
        // create base version
        TodayVersionBusiness.createBaseVersionIfNotExists(for: uuid, with: notebookContent.content, modelContext)
    }
    
    static func cleanBaseVersionIfNeeded(modelContext: ModelContext) {
        let date = Date.yesterday
        let predicate = #Predicate<TodayVersion> {
            $0.date <= date
        }
        do {
            try modelContext.delete(model: TodayVersion.self, where: predicate)
        } catch let error {
            print(error)
        }
    }
    
    
    static func createBaseVersionIfNotExists(for id: UUID, with content: String, _ modelContext: ModelContext) {
        
        // if file already exits, then skip creation steps
        if Self.isBaseVersionExists(id, modelContext) {
            return
        }
        
        let todayVersion = TodayVersion(notebookID: id, content: content)
        modelContext.insert(todayVersion)
        
        do {
            try modelContext.save()
        } catch let error {
            print(error)
        }
    }
    
    static func isBaseVersionExists(_ id: UUID, _ modelContext: ModelContext) -> Bool {
        
        let predicate = #Predicate<TodayVersion> {
            $0.notebookID == id
        }
        
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let results = try modelContext.fetch(descriptor)
            if results.count > 0 {
                return true
            }
        } catch let err {
            print(err)
        }
        
        return false
    }
    
    // get base content from todaysVersion/<date>/uuid.md
    static func getBaseVersion(for id: UUID, modelContext: ModelContext) -> String? {
        
        let predicate = #Predicate<TodayVersion> {
            $0.notebookID == id
        }
        
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let results = try modelContext.fetch(descriptor)
            return results.first?.content
        } catch let err {
            print(err)
        }
        
        return nil
    }
    

    static func removeBaseVersion(for id: UUID, modelContext: ModelContext) {
        let predicate = #Predicate<TodayVersion> {
            $0.notebookID == id
        }
        do {
            try modelContext.delete(model: TodayVersion.self, where: predicate)
        } catch let error {
            print(error)
        }
    }
}


extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
    var monthName: String {
        Calendar.current.standaloneMonthSymbols[month]
    }
    
    var monthBefore: Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: noon)!
    }
}
