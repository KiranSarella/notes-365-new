//
//  DayVersionsInteractor.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import Foundation

protocol DayVersionInteractor {
    func cleanBaseVersionIfNeeded()
    func createBaseVersionIfNotExists(for notebookId: UUID, with content: String)
    func isBaseVersionExists(notebookId: UUID) -> Bool
    func getTodayVersion(for notebookId: UUID) -> String?
    func removeDayVersion(for notebookId: UUID)
}

extension TodayVersionBusiness: DayVersionInteractor {
    
}
