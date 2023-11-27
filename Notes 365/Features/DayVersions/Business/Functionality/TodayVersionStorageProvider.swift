//
//  TodayVersionStorageProvider.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import Foundation

protocol TodayVersionStorageProvider {
    func deleteAllVersions(belowDate: Date) throws
    func isBaseVersionExists(for notebookId: UUID) throws -> Bool
    func create(todayVersion: TodayVersion) throws
    func getTodayVersion(for notebookId: UUID) throws -> String?
    func removeDayVersion(for notebookId: UUID) throws
}
