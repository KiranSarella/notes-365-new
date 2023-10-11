//
//  CalendarNavigatorView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 06/02/23.
//

import SwiftUI

struct CalendarNavigatorView: View {
    
    var label: String
    var previous:(()->())
    var today:(()->())
    var next:(()->())
    
    var body: some View {
        HStack {
            // current date title
            Text(label)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
            Spacer()
            // previous
            Button {
                previous()
            } label: {
                Label(
                    title: { Text("Previous") },
                    icon: { Image(systemName: "chevron.left") }
                )
                .labelStyle(IconOnlyLabelStyle())
                .frame(maxHeight: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            // today
            Button {
                today()
            } label: {
                Label(
                    title: { Text("Today") },
                    icon: { Image(systemName: "smallcircle.fill.circle") }
                )
                .labelStyle(IconOnlyLabelStyle())
                .frame(maxHeight: .infinity)
                .help("this week")
                .padding([.trailing, .leading], 16)
            }
            .buttonStyle(PlainButtonStyle())
            // next
            Button {
                next()
            } label: {
                Label(
                    title: { Text("Next") },
                    icon: { Image(systemName: "chevron.right") }
                )
                .labelStyle(IconOnlyLabelStyle())
                .frame(maxHeight: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct CalendarNavigatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarNavigatorView(label: "date", previous: {
            
        }, today: {
            
        }, next: {
            
        })
    }
}
