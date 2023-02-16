//
//  MainBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/02/23.
//

import Foundation

// like appdelegate for terminal (without UI), for integration tests?
class MainBusiness {
    
    func main() {
            
        // choose environment
        // go with default option, throw if any error while init
        let chooseEnv = ChooseEnvironment()
        
        do {
            try chooseEnv.setEnviromment(with: .cloud)
        } catch let error {
            print(error)
        }
    }
    
}
