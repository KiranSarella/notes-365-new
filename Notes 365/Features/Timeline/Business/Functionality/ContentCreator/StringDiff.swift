//
//  StringDiff.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import Foundation
 
class StringDiff {

    // diff
    static func getChanges(old: String, new: String) -> String {
        
        // convert string to arrays
        let oldArr = old.components(separatedBy: ["\n"])
        let newArr = new.components(separatedBy: ["\n"])
        
        let diffArr = newArr.difference(from: oldArr)
        
        var outputStr = ""
        var oldOffset:Int?
        
        if diffArr.insertions.count > 0 {
            
            var counter = 0
            
            repeat {
                
                let item = diffArr.insertions[counter]
                switch item {
                case .insert(offset: let offset, element: let element, associatedWith: _):
                    
                    if let temp = oldOffset, temp + 1 != offset {
                        outputStr += "\n"
                    }
                    // ?
                    outputStr += "\n"
                    outputStr += element
                    
                    oldOffset = offset
                    
                case .remove(offset: _, element:  _, associatedWith:  _):
                    break
                }
                
                counter += 1
                
            } while counter < diffArr.insertions.count
        }
        
        
        return outputStr
    }
    
    
}
