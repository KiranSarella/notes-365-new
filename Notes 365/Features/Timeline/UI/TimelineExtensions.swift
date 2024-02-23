//
//  Extensions.swift
//  Notes 365
//
//  Created by kiran ipc on 23/02/24.
//

import Foundation

extension Date {
    func getWeekStartEndDates() -> (Date, Date) {
        guard
            let weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: self)
        else { fatalError() }
        
        let startDate = weekInterval.start
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        
        return (startDate, endDate)
    }
    
    func getMonthStartEndDates() -> (Date, Date) {
        guard
            let monthInterval = Calendar.current.dateInterval(of: .month, for: self)
        else { fatalError() }
        
        let startDate = monthInterval.start
        let endDate = monthInterval.end
        
        return (startDate, endDate)
    }
}


extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
    /*
     limitation: more then 2 empty lines are treated as same
     */
    func fixLineBreaks() -> String {
        let pattern = #"\n[^$(?=\S)]+"#
        //    print(content)
        let out1 = self.replacingOccurrences(of: pattern, with: "##-##", options: .regularExpression, range: nil)
        //print(out1)
        let out2 = out1.replacingOccurrences(of: "\n", with: "##*##")
        //print(out2)
        let out3 = out2.replacingOccurrences(of: "##-##", with: "\n\n\n")
        //print(out3)
        let out4 = out3.replacingOccurrences(of: "##*##", with: "\n\n")
        //    print(out4)
        
        return out4
    }
}
