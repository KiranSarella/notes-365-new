//
//  BaseBackgroundView.swift
//  Notes 365
//
//  Created by kiran ipc on 22/11/23.
//

import SwiftUI

struct BaseBackgroundView: View {
    var body: some View {
        ZStack {
            Image("bg1")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            BaseContentView()
        }
    }
}

#Preview {
    BaseBackgroundView()
}

struct BaseContentView: View {
    var body: some View {
        HStack {
            SidebarView()
                .frame(width: 400)
                .padding()
            
            DetailView()
                .padding()
            Spacer()
        }
    }
}

struct SidebarView: View {
    
    @State private var sidebarItemSelected: SidebarItem.ID? = SidebarItem.timeline.id
    
    @State var settingsExpanded = true
    
    var body: some View {
        ScrollView(.vertical) {
            HStack {
                VStack {
                    HStack {
                        Text("Notes 365")
//                            .font(.largeTitle)
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                        Spacer()
                    }.padding()
                    
                    HStack {
                        Button {
                           
                        } label: {
                            Label("Timeline", systemImage: "rectangle.stack")
                        }
                        Spacer()
                    }.padding()
                    
                    HStack {
                        Button {
                            
                        } label: {
                            Label("Notebooks", systemImage: "books.vertical")
                        }
                        Spacer()
                    }.padding()
                    
                    HStack {
                        Button {
                            //                    showThemes = true
                        } label: {
                            Label("Themes", systemImage: "paintbrush")
                        }
                        Spacer()
                    }.padding()
                   
                    HStack {
                        Button {
                            //                    showThemes = true
                        } label: {
                            Label("Themes", systemImage: "paintbrush")
                        }
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        Button {
                            //                    showThemes = true
                        } label: {
                            Label("Symbols Guide", systemImage: "textformat")
                        }
                        Spacer()
                    }
                    .padding()
                    
                    
                    HStack {
                        Button {
                            //                    showFormattingSymbols = true
                        } label: {
                            Label("Feedback", systemImage: "hand.thumbsup")
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                Spacer()
            }
            
//            .background(.thinMaterial)
        }
        .foregroundColor(.white)
            
       
        
           
        
       
//        List {
//            Text("Timeline")
//            Text("Notebooks")
//        }.scrollContentBackground(.hidden)
    }
}

struct DetailView: View {
    
    @State private var timelineDetailState = TimelineDetailState()
    
    var body: some View {
        
        TimelineDetailView(timelineDetailState: $timelineDetailState)
        
        
        
//        VStack {
//            Text("Detail")
//                .font(.system(size: 150))
//                .foregroundStyle(.white)
//            
//        }
    }
}
