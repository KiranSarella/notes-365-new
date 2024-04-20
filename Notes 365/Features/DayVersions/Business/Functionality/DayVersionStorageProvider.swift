//
//  TodayVersionStorageProvider.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import Foundation

protocol DayVersionStorageProvider {
    func deleteAllVersions(belowDate: Date) throws
    func isBaseVersionExists(for versionId: String) throws -> Bool
    func create(todayVersion: DayVersionData) throws
    func getTodayVersion(for versionId: String) throws -> DayVersionData?
    func removeDayVersion(for versionId: String) throws
}
