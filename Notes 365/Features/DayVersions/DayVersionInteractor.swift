//
//  DayVersionsInteractor.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import Foundation

protocol DayVersionInteractor {
    func cleanOlderDayVersions()
    func createBaseVersion(for notebookId: UUID) -> DayVersionData?
    func createBaseVersionIfNotExists(for notebookId: UUID, with content: String)
    func isBaseVersionExists(notebookId: UUID) -> Bool
    func getTodayVersion(for notebookId: UUID) -> DayVersionData?
    func removeDayVersion(for notebookId: UUID)
//    func setupDayVersionCreationProcess()
//    func stopDayVersionCreationProcess()
}

extension DayVersionBusiness: DayVersionInteractor {
    
}
