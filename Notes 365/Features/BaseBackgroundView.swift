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
            Color.init(hex: 027148)
//            Image("bg1")
//                .resizable()
                .edgesIgnoringSafeArea(.all)
//                .aspectRatio(contentMode: .fill)
//                .clipped()
            
            BaseContentView()
        }
    }
}

#Preview {
    BaseBackgroundView()
}

struct BaseContentView: View {
    
    @State private var sidebarItemSelected: SidebarItem.ID = SidebarItem.timeline.id
    
    var body: some View {
        HStack {
            SidebarView(sidebarItemSelected: $sidebarItemSelected)
                .frame(width: 400)
                .padding()
            
            DetailView(sidebarItemSelected: $sidebarItemSelected)
                .padding()
            Spacer()
        }
    }
}

struct SidebarView: View {
    
    @Binding var sidebarItemSelected: SidebarItem.ID
    @State private var showThemes = false
    @State private var showFormattingSymbols = false
    @State private var showFeedback = false
    
    
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
                            sidebarItemSelected = SidebarItem.timeline.id
                        } label: {
                            Label("Timeline", systemImage: "rectangle.stack")
                        }
                        Spacer()
                    }.padding()
                    
                    HStack {
                        Button {
                            sidebarItemSelected = SidebarItem.notebooks.id
                        } label: {
                            Label("Notebooks", systemImage: "books.vertical")
                        }
                        Spacer()
                    }.padding()
                    
                    HStack {
                        Button {
                            showThemes = true
                        } label: {
                            Label("Themes", systemImage: "paintbrush")
                        }
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        Button {
                            showFormattingSymbols = true
                        } label: {
                            Label("Symbols Guide", systemImage: "textformat")
                        }
                        Spacer()
                    }
                    .padding()
                    
                    
                    HStack {
                        Button {
                            showFeedback = true
                        } label: {
                            Label("Feedback", systemImage: "hand.thumbsup")
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                Spacer()
            }
            .foregroundColor(.white)
            .sheet(isPresented: $showThemes) {
                SettingsView_iPadOS(showModel: $showThemes)
            }
            .sheet(isPresented: $showFormattingSymbols) {
                EditorSymbolsView()
            }
            .sheet(isPresented: $showFeedback) {
                FeedbackView_iPadOS()
            }
           
            
//            .background(.thinMaterial)
        }
        
        
           
        
       
//        List {
//            Text("Timeline")
//            Text("Notebooks")
//        }.scrollContentBackground(.hidden)
    }
    
}

struct DetailView: View {
    
    @Binding var sidebarItemSelected: SidebarItem.ID
    @State private var timelineDetailState = TimelineDetailState()
    
    var body: some View {
        
        if sidebarItemSelected == SidebarItem.timeline.rawValue {
            TimelineDetailView(timelineDetailState: $timelineDetailState)
                .foregroundColor(.white)
    //            .padding()
    //            .background(.ultraThinMaterial)
    //            .blur(radius: 10)

        } else {
            NotebooksBaseDetailView()
                .foregroundColor(.white)
        }
        
       
        
     
        
        
//        VStack {
//            Text("Detail")
//                .font(.system(size: 150))
//                .foregroundStyle(.white)
//            
//        }
    }
}


struct NotebooksBaseDetailView: View {
    var body: some View {
        Text("notebooks base")
    }
}
