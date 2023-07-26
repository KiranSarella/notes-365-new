//
//  ThemeCardView.swift
//  Notes 365
//
//  Created by kiran ipc on 26/07/23.
//

import SwiftUI

struct ThemeCardView: View {
    
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Themes")
                    .fontWeight(.bold)
                Spacer()
            }.padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<10) {
                        Text("Item \($0)")
                            .foregroundStyle(.white)
                            .font(.largeTitle)
                            .frame(width: 160, height: 80)
                            .background(.green)
                            .cornerRadius(10)
                    }
                }
            }
        }.padding(.vertical)
    }
}

#Preview {
    ThemeCardView()
}
