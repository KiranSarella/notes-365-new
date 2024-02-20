//
//  ContentView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import SwiftUI

public enum SidebarItem: String, CaseIterable, Identifiable {
    public var id: String { self.rawValue }
    case timeline
    case notebooks
    case recents
    case search
    case recentlyDeleted
}

struct LaunchView: View {
    var body: some View {
        ContentView()
            .onAppear {
                
            }
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @State var settingsExpanded = true
    @State private var showThemes = false
    @State private var showFormattingSymbols = false
    @State private var showPurchases = false
    @State private var showFeedback = false
    @State private var sidebarItemSelected: SidebarItem.ID?// = SidebarItem.timeline.id
    @State private var selectedNotebookM: Notebook?
    @State var navigationSplitViewVisibility = NavigationSplitViewVisibility.all
    var todayVersionBusiness = BusinessFactory.dayVersionInteractor()
    @State private var timelineDetailState = TimelineBaseViewState(timelineBusiness: BusinessFactory.timelineInteractor())
    @State private var path = NavigationPath()
    @State private var horizontalCalendarViewState = HorizontalCalendarViewState()
    let cloudKitSync = CloudKitSync()
    
    @State var state = ContentViewState()
    
    let iconWidth: CGFloat = 18
    
    @State var isFirstTimeAppeared = false
    @State var isFirstTimePurchasesUpdated = false
    
    var body: some View {
        VStack {
            NavigationSplitView(columnVisibility: $navigationSplitViewVisibility) {
                VStack {
                    List(selection: $sidebarItemSelected) {
                        Label {
                            Text("Timeline")
                        } icon: {
                            Image(systemName: "calendar")
                                .circularIconStyle(background: Color("icon_purple", bundle: nil))
                        }
                        .tag(SidebarItem.timeline.id)
                            
                        Label {
                            Text("Notebooks")
                        } icon: {
                            Image(systemName: "books.vertical.fill")
                                .circularIconStyle(background: Color("icon_red", bundle: nil))
                        }
                        .tag(SidebarItem.notebooks.id)
                        
                        Label {
                            Text("Recents")
                        } icon: {
                            Image(systemName: "clock.fill")
                                .circularIconStyle(background: Color("icon_orange", bundle: nil))
                        }
                        .tag(SidebarItem.recents.id)
                        
                        Label {
                            Text("Search")
                        } icon: {
                            Image(systemName: "magnifyingglass")
                                .circularIconStyle(background: .indigo)
                        }
                        .tag(SidebarItem.search.id)
                        
                        Label {
                            Text("Recently Deleted")
                        } icon: {
                            Image(systemName: "trash.fill")
                                .circularIconStyle(background: .gray)
                        }
                        .tag(SidebarItem.recentlyDeleted.id)
                        
                        Section("Settings", isExpanded: $settingsExpanded) {
                            Button {
                                showThemes = true
                            } label: {
                                Label {
                                    Text("Themes")
                                } icon: {
                                    Image(systemName: "paintbrush.fill")
                                        .circularIconStyle(background: Color("icon_green", bundle: nil))
                                }
                            }
                            Button {
                                showFormattingSymbols = true
                            } label: {
                                Label {
                                    Text("Symbols Guide")
                                } icon: {
                                    Image(systemName: "textformat")
                                        .circularIconStyle(background: Color("icon_teal", bundle: nil))
                                }
                            }
                            
                            Button {
                                showPurchases = true
                            } label: {
                                Label {
                                    Text("Premium")
                                } icon: {
                                    Image(systemName: "lock.open.fill")
                                        .circularIconStyle(background: Color("icon_amber", bundle: nil))
                                }
                            }
                            
                            Button {
                                showFeedback = true
                            } label: {
                                Label {
                                    Text("Feedback")
                                } icon: {
                                    Image(systemName: "hand.thumbsup.fill")
    //                                    .circularIconStyle(background: .blue)
                                        .circularIconStyle(background: Color("icon_blue", bundle: nil))
                                }
                            }
                        }
                        
    //                    if cloudKitSync.isImportDone == false {
    //                        ProgressView("Syncing..")
    //                    }
                    }
                    .navigationTitle("Notes 365")
//                    .task {
//                        if isFirstTimePurchasesUpdated == false {
//                            isFirstTimePurchasesUpdated = true
//                            state.checkAndObservePurchasesChanges()
//                        } else if await PremiumUserState.shared.isPurchased == false {
//                            state.checkAndObservePurchasesChanges()
//                        }
//                    }
                    .sheet(isPresented: $showThemes) {
                        ThemesBaseView()
                    }
                    .sheet(isPresented: $showFormattingSymbols) {
                        EditorSymbolsView()
                    }
                    .sheet(isPresented: $showPurchases) {
                        PurchaseBaseView()
                    }
                    .sheet(isPresented: $showFeedback) {
                        FeedbackView()
                    }
    //                .onChange(of: colorScheme, { oldValue, newValue in
    //                    ThemeState.shared.updateColorScheme(newValue)
    ////                    if ThemeState.shared.colorScheme != newValue {
    ////
    ////                    }
    //                })
    //                .onChange(of: sidebarItemSelected) { oldValue, newValue in
    //                    if newValue == SidebarItem.timeline.rawValue {
    //                        path = NavigationPath()
    //                    }
    //                }
                }
                
            }
            detail: {
                if let sidebarItemSelected = sidebarItemSelected {
                    let selectedItem = SidebarItem(rawValue: sidebarItemSelected)!
                    switch selectedItem {
                    case .timeline:
                        TimelineBaseView(path: $path, state: $timelineDetailState, horizontalCalendarViewState: $horizontalCalendarViewState)
                    case .notebooks:
                        NotebooksBaseDetailView(path: $path)
                    case .search:
                        ContentSearchView()
                    case .recents:
                        RecentsBaseDetailView(path: $path)
                    case .recentlyDeleted:
                        RecentlyDeletedBaseDetailView(path: $path)
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .onAppear {
            // on background to foreground also not required again
            if isFirstTimeAppeared == false {
                isFirstTimeAppeared = true
                Task {
                    await NotebooksPathService.shared.startObservingServices()
                }
                
                BusinessFactory.dayVersionInteractor().setupDayVersionCreationProcess()
                BusinessFactory.timelineInteractor().setupTimeineCreationProcess()
                BusinessFactory.recentsInteractor().setupRecentsAddingProcess()
                
                ThemeState.shared.updateColorScheme(colorScheme)
                
                Task {
                    // start service
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    await NotebooksPathService.shared.doRefreshIfNotLoaded()
                    if UIDevice.current.userInterfaceIdiom != .phone {
                        Task { @MainActor in
                            sidebarItemSelected = SidebarItem.timeline.id
                        }
                    }
                }
                
                Task {
                    try? await Task.sleep(nanoseconds: 10_000_000_000)
                    await BusinessFactory.createNotebooksFactory().permanentDeleteExpiredItems()
                }
                
                state.checkAndObservePurchasesChanges()
            }
        }
        .onChange(of: colorScheme, { oldValue, newValue in
            if ThemeState.shared.colorScheme != newValue {
                ThemeState.shared.updateColorScheme(newValue)
            }
        })
        
    }
}

struct CircleIcon: View {
    let systemName: String
    let background: Color
    var body: some View {
        Image(systemName: systemName)
          .resizable()
          .fontWeight(.bold)
          .frame(width: 18, height: 18)
          .foregroundColor(.white)
          .padding(6)
          .background(background)
          .clipShape(Circle())
    }
}


extension Image {
    func circularIconStyle(background: Color) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20, alignment: .center)
            .foregroundColor(.white)
            .padding(6)
            .background(background)
            .clipShape(Circle())
            .fontWeight(.bold)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct ContentDetailView: View {
    
    @Binding var sidebarItemSelected: SidebarItem.ID?
    @Binding var path: NavigationPath
    
    var body: some View {
        
        if let sidebarItemSelected = sidebarItemSelected {
            let selectedItem = SidebarItem(rawValue: sidebarItemSelected)!
            switch selectedItem {
            case .timeline:
    //            TimelineBaseView(path: $path, state: $timelineDetailState, horizontalCalendarViewState: $horizontalCalendarViewState)
                Text("Timeoine")
            case .notebooks:
                NotebooksBaseDetailView(path: $path)
            case .search:
                ContentSearchView()
            case .recents:
                RecentsBaseDetailView(path: $path)
            case .recentlyDeleted:
                RecentlyDeletedBaseDetailView(path: $path)
            }
        } else {
            EmptyView()
        }
        
//        let selectedItem = SidebarItem(rawValue: sidebarItemSelected ?? SidebarItem.timeline.id)!
        
    }
}
