//
//  Extensions.swift
//  MyNotes (iOS)
//
//  Created by Kiran Sarella on 12/10/21.
//

import Foundation
import SwiftUI

extension Date {
    
    public var removeTimeStamp : Date? {
        
        let onlyDateStr = self.string(format: "yyyy-MM-dd")
        return onlyDateStr.toUTCDate(withFormat: "yyyy-MM-dd")
    }
    
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}
        
        return localDate
    }
    
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension String {
    
    func toUTCDate(withFormat format:String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }
    
    
    func toLocalDate(withFormat format:String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        
        return date
    }
}


//extension Note: RandomAccessCollection {
//    
//    
//}



extension Binding {
    func unwrap<Wrapped>() -> Binding<Wrapped>? where Optional<Wrapped> == Value {
        guard let value = self.wrappedValue else { return nil }
        return Binding<Wrapped>(
            get: {
                return value
            },
            set: { value in
                self.wrappedValue = value
            }
        )
    }
}



public extension Date {
    
    func string(withFormat dateFormat: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.string(from: self)
    }
    
    //    func localDate() -> Date {
    //
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.defaultDate = Date()
    //
    //        return dateFormatter.defaultDate!
    //    }
    
    func getDay() -> Int {
        return Calendar.current.component(.day, from: self)
    }
    
    func getMonth() -> Int {
        return Calendar.current.component(.month, from: self)
    }
    
    func getYear() -> Int {
        return Calendar.current.component(.year, from: self)
    }
    
    func isSameDayAs(_ date2: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date2)
    }
    
    func getWeekNumber() -> Int {
        return Calendar.current.component(.weekOfYear, from: self)
    }
    
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    static func isCurrentMonth(_ date: Date) -> Bool {
        // check same year
        // check same month
        let today = Date()
        
        if date.getYear() == today.getYear() && date.getMonth() == today.getMonth() {
            return true
        }
        
        return false
    }
}


extension String {
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
}



extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}


extension NSMutableAttributedString {
    
    public func fullRange() -> NSRange {
        return self.mutableString.range(of: self.string)
    }
}


import UIKit

extension Color {
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        typealias NativeColor = UIColor
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }
        return (r, g, b, o)
    }
    
}

extension UIDocument.State: CustomStringConvertible {
    public var description: String {
        return [
            UIDocument.State.normal.rawValue:".normal",
            UIDocument.State.closed.rawValue:".closed",
            UIDocument.State.inConflict.rawValue:".inConflict",
            UIDocument.State.savingError.rawValue:".savingError",
            UIDocument.State.editingDisabled.rawValue:".editingDisabled",
            UIDocument.State.progressAvailable.rawValue:".progressAvailable"
        ][rawValue] ?? String(rawValue)
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension FileManager {
    
    func removeAllItems(at path: URL) throws {
        // get all item names
        let items = try FileManager.default.contentsOfDirectory(atPath: path.path(percentEncoded:false))
        for item in items {
            // prepare path for each item
            let itemPath = path.appendingPathComponent(item, conformingTo: .item)
            // remove item
            try FileManager.default.removeItem(at: itemPath)
        }
    }
}
