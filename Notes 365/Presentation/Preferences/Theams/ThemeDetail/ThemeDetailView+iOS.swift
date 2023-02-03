//
//  ThemeDetailView+iOS.swift
//  Notes 365
//
//  Created by Kiran Sarella on 01/02/23.
//

import SwiftUI

struct ThemeDetailView_iOS: View {
    
    @State private var bodyColor = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
    @State private var headingColor = Color.blue
    
    var body: some View {
        
        VStack {
            
            List {
                // font name
                HStack {
                    Text("Font")
                    Spacer()
                    Text("helvitica")
                }
                // font size
                Stepper("Font Size") {
                    
                } onDecrement: {
                    
                }
                
                // color pickers
                ColorPicker("Body", selection: $bodyColor)
                ColorPicker("Heading", selection: $headingColor)
                ColorPicker("Bold, Italic, Strikthrough", selection: $headingColor)
                ColorPicker("List", selection: $headingColor)
                ColorPicker("Source Code", selection: $headingColor)
                ColorPicker("Block Quote", selection: $headingColor)
            }
            .navigationTitle("Theme Name")
        }
    }
}

//struct ThemeDetailView_iOS_Previews: PreviewProvider {
//    static var previews: some View {
//        ThemeDetailView_iOS()
//    }
//}
