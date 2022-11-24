//
//  ContentView.swift
//  ListExample
//
//  Created by Kiran Sarella on 23/11/21.
//

import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
//import SwiftUIWindow
#endif

struct UsersSidebarView: View {
    
    @EnvironmentObject var store: Store
    
    var isSubscribed: Bool {
        return store.purchasedSubscriptions.count != 0
    }

    let directoryManager = DirectoryManager.shared
    
    @Binding var selectedMode: Mode
    
    @EnvironmentObject var usersState: NotebooksListState
    
    @Binding var userSelectionState: UserSelectionState?
    
    @Binding var userSelectionStateDB: UserSelectionState?
    
    @Binding var selectedUser: NotebookM?
    
    @State var draggedItem: NotebookM?
    
    @State var pushActive = true
    
    @State var isLoading = true
    
    @State private var isPresentingConfirm: Bool = false
    
    var body: some View {
        
        
        VStack {
            
            List {
                NotesListView(levels: [],
                              users: $usersState.usersDB.notes,
                              selectedUser: $selectedUser,
                              draggedItem: $draggedItem,
                              selectedMode: $selectedMode,
                              userSelectionState: $userSelectionState)
                    .environmentObject(usersState)
            }
            .onAppear {
                
                if usersState.usersDB.notes.isEmpty == false {
                    isLoading = false
                    // restore state
                    userSelectionState = userSelectionStateDB
                    
                    return
                }
                
//                let users = usersState.usersDB.retrieveObject()
//                usersState.usersDB.notes = users ?? []
                
                isLoading = false
                // restore state
                userSelectionState = userSelectionStateDB
                // prepare full paths
                directoryManager.prepareFolderPaths()
            }
            .onDisappear {
                
                // save state
                userSelectionStateDB = userSelectionState
                
                // TODO: -
                usersState.saveSelectionState() // to persiste selection
                
                directoryManager.prepareFolderPaths()
            }
            
//            if let userSelectionState = userSelectionState {
//                NavigationLink(destination:
//                                UserMarkdownView(userSelectionState: userSelectionState, selectedMode: $selectedMode),
//                               tag: userSelectionState,
//                               selection: $userSelectionState)
//                {
//                    
//                    
//                }.buttonStyle(PlainButtonStyle())
//                    .hidden()
//            }
            
            
            // show add notes view if list is empty
            if isLoading == false && usersState.usersDB.notes.isEmpty {
                
                AddNotesView()
                    .padding([.top], -100)
                    .environmentObject(usersState)
            } else {
#if os(macOS)
                getToolbarView()
                
#elseif os(iOS)
                
                if UIDevice.current.userInterfaceIdiom == .pad ||
                    UIDevice.current.userInterfaceIdiom == .mac {
                    
                    getToolbarView()
                }
#endif
            }
        }
        .frame(minWidth: 280, maxWidth: 500)
        
        
//        NavigationView {
//
//        }
//        .listStyle(SidebarListStyle())
        
    }
    
    
    func getToolbarView() -> some View {
        // tool bar
        HStack(spacing: 20) {
            
            Group {
                
                // insert below
                Button(action: {
                    
//                    if isSubscribed == false && usersState.isNotebooksLimitExceeded {
//                        // show purchase window
//                        openMyWindow()
//                        return
//                    }
                   
                    usersState.insertUserBelowSelection()
//                    usersState.usersDB.saveObject()
                }) {
                    //                Image(systemName: "arrow.down")
                    //                    .renderingMode(.original)
                    Text("Add Below")
                }
                
                
                // insert inside
                Button(action: {
                    
//                    if isSubscribed == false && usersState.isNotebooksLimitExceeded {
//                        // show purchase window
//                        openMyWindow()
//                        return
//                    }
                    
                    usersState.insertInsideSelection()
//                    usersState.usersDB.saveObject()
                }) {
                    //                Image(systemName: "arrow.turn.down.right")
                    //                    .renderingMode(.original)
                    Text("Add Inside")
                }
                
            }
            .buttonStyle(.bordered)
            
           
            Spacer()
            // trash
            Button(action: {
                
               isPresentingConfirm = true
                
            }) {
                Image(systemName: "trash")
                    .renderingMode(.original)
            }
            .confirmationDialog("Are you sure?",
                                isPresented: $isPresentingConfirm) {
                Button("Delete", role: .destructive) {
                    DispatchQueue.main.async {
                        usersState.deleteUser()
                        
                        userSelectionState = nil
                        
//                        usersState.usersDB.saveObject()
                    }
                    
                }
            } message: {
                Text("You cannot undo this action")
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
    }
    
    
//    func openMyWindow()
//    {
//        var windowRef:NSWindow
//        windowRef = NSWindow(
//            contentRect: NSRect(x: 100, y: 100, width: 400, height: 800),
////            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//            styleMask: [.titled, .closable, .fullSizeContentView],
//            backing: .buffered, defer: false)
//        windowRef.contentView = NSHostingView(rootView: PurchaseSettingsView())
//        windowRef.makeKeyAndOrderFront(nil)
//    }
    
    
    func openMyWindow()
    {
        
//        #if os(macOS)
//
//        SwiftUIWindow.open { _ in
//            PurchaseSettingsView()
//            .frame(minWidth: 800, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
//            .environmentObject(store)
//        }
////        .style(.borderless)
//        .clickable(true)
//        .mouseMovesWindow(true)
////        .transparentBackground(true)
//        .alwaysOnTop(true)
//        .style([.titled, .closable])
//
//        #endif
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        UsersSidebarView(selectedMode: Binding.constant(.timeline))
//    }
//}


struct AddNotesView: View {
    
    @EnvironmentObject var usersState: NotebooksListState
    
    var body: some View {
        
        VStack(alignment: .center) {
            // show add first notebook button
            Button {
                
                usersState.addFirstNotes()
                
                
//                usersState.usersDB.saveObject()
                
                
                //                if usersState.usersDB.baseObject == nil {
                //                    NotebooksState.shared.createEmptyNotebook()
                //                } else {
                //
                //                }
                
            } label: {
                Text(" + Notebook ")
//                    .foregroundColor(Color.gray)
                
            }.padding()
            
            
            
            Text("add your first notebook")
                .font(Font.subheadline)
//            Spacer()
        }
        
    }
}

struct NotesListView: View {
    
    @EnvironmentObject var usersState: NotebooksListState
    
    let levels: [Int]
    
    var parentUser: NotebookM?
    
    @Binding var users: [NotebookM]
    
    @Binding var selectedUser: NotebookM?
    
    @Binding var draggedItem: NotebookM?
    
    @Binding var selectedMode: Mode
    
    @Binding var userSelectionState: UserSelectionState?
    
    var body: some View {
        
        ForEach(users.indices, id: \.self) { index in
            
            let user = $users[index]
            
            RowView(levels: levels, index: index, selectedMode: $selectedMode, user: user, selectedUser: $selectedUser, draggedItem: $draggedItem, showDisclosure: user.wrappedValue.containChildNotebooks, userSelectionState: $userSelectionState)
                .onDrop(of: [UTType.text.identifier], delegate: TaskDropDelegate(dropInfo: DragInfo(levels: levels, index: index), draggedItem: self.$draggedItem, array: $users))
//                .onDrag {
//                    
//                    self.draggedItem = $user.wrappedValue
//                    
//                    let dragInfo = DragInfo(levels: levels, index: index)
//                    
//                    let itemProvider = convertModelToData(model: dragInfo)!
//                    return itemProvider
//                    
//                    //                            print("ON DRAG", $user.wrappedValue.name)
//                    //                            self.draggedItem = $user.wrappedValue
//                    //                            return NSItemProvider(item: $user, typeIdentifier: $user.wrappedValue.id.uuidString)
//                }
        }
        .onDelete { indexSet in
//            print("onDelete", indexSet)
        }
    }
    
}

struct RowView: View {
    
    let levels: [Int]
    let index: Int
    
    @Binding var selectedMode: Mode
    
    @Binding var user: NotebookM
    
    @Binding var selectedUser: NotebookM?
    
    @Binding var draggedItem: NotebookM?
    
    var showDisclosure: Bool
    
    @Binding var userSelectionState: UserSelectionState?
    
    var body: some View {
        
        if showDisclosure {
            GroupedView(level: levels, index: index, user: $user, selectedMode: $selectedMode, selectedUser: $selectedUser, draggedItem: $draggedItem, userSelectionState: $userSelectionState)
        } else {
            HeadingView(levels: levels, index: index, selectedMode: $selectedMode, user: $user, userSelectionState: $userSelectionState, selectedUser: $selectedUser, draggedItem: $draggedItem)
        }
    }
}




struct HeadingView: View {
    
    let levels: [Int]
    let index: Int
    
    @Binding var selectedMode: Mode
    
    @EnvironmentObject var usersState: NotebooksListState
    
    @Binding var user: NotebookM
    
    @Binding var userSelectionState: UserSelectionState?
    
    @Binding var selectedUser: NotebookM?
    
    @Binding var draggedItem: NotebookM?
    
    @State private var isActionSheetPresented = false
    
    @State private var isEditing = false
    
    @State private var isHover = false
    
    enum Field: Hashable {
        case name
    }
    
    @FocusState private var focusedField: Field?
    
    @State private var editingFileName: String = ""
    
    var isSelected: Bool {
        return selectedUser == user
    }
    
    var showOptions: Bool {
        return isHover && isSelected
    }

    let titleFont: CGFloat = 14
    
    @State private var showFileExistsAlert = false
    @State private var showInvalidCharsAlert = false
    
    var body: some View {
        
        HStack {
            
            if isEditing {
                
                TextField("", text: $editingFileName, onCommit: {
                    DispatchQueue.main.async {
                        isEditing = false
                    }
                })
                .font(Font.system(size: titleFont))
                .focused($focusedField, equals: .name)
                
            } else {
                
                Button {
//                    print(user.name)
                    
                    let userSelectionStateValue = UserSelectionState(selectedUser: user, selectedLevels: levels, selectedIndex: index)
                    
                    userSelectionState = userSelectionStateValue
                    selectedUser = user
                    
                } label: {
                    
                    HStack {
                        
                        Menu {
                            Button(action: {
                                
                            }) {
                                Label("Add", systemImage: "plus.circle")
                            }
                            Divider()
                            Button(action: {
                                
                            }) {
                                Label("Delete", systemImage: "minus.circle")
                            }
                            Button(action: {
                                
                            }) {
                                Label("Edit", systemImage: "pencil.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        
                        Text(user.name + "                                         ")
                            .font(Font.system(size: titleFont))
                            .foregroundColor(isSelected ? Color.blue : Color.primary)
                    }
                    
                    
                }

                
            }
            
            Spacer()
            
            Button {
                
                DispatchQueue.main.async {
                    // assign existing file name to editing variable
                    editingFileName = user.name
                    
                    isEditing = true
                    focusedField = .name
                }
                
            } label: {
                //                    Image(systemName: "ellipsis.circle.fill")
                Image(systemName: "pencil.circle")
                    .foregroundColor(.gray)
                    .frame(width: 20, height: 20)
            }
            .opacity(showOptions ? 1 : 0)
        }
        .onAppear {
            if selectedMode == .timeline {
                return
            }
            self.editingFileName = user.name
        }
        .onHover(perform: { status in
            isHover = status
        })
        .onTapGesture {
            
            let userSelectionStateValue = UserSelectionState(selectedUser: user, selectedLevels: levels, selectedIndex: index)
            
            userSelectionState = userSelectionStateValue
        }
        .buttonStyle(.plain)
        .confirmationDialog("Failed to rename file",
                            isPresented: $showFileExistsAlert) {

        } message: {
            Text("filename already exists")
        }
        .confirmationDialog("Failed to rename file",
                            isPresented: $showInvalidCharsAlert) {
            
        } message: {
            Text("filename contains unsupported characters")
        }
        .onChange(of: isEditing) { newValue in
            if newValue == false {
                
                if selectedMode == .timeline {
                    return
                }
                
                // if file name not modified
                if editingFileName == user.name {
                    return
                }
                

                if editingFileName.contains(":") {
                    showInvalidCharsAlert = true
                    return
                }

                do {
                   try usersState.renameNotebook(editingFileName: editingFileName)
                } catch {
                    // show alert
                    showFileExistsAlert = true

                    return
                }
                
                
                
//                // get folders path
//                let path = UsersList.shared.getFolderNamesPath(levels: levels)
//
//                // check if already same file name exists
//                if FilesHelper.shared.fileExists(atPath: path, fileName: editingFileName) {
//
//                    // show alert
//                    showFileExistsAlert = true
//
//                    return
//                }
//
//                // rename file
//                FilesHelper.shared.renameFile(newFileName: editingFileName, oldFileName: user.name, filePath: path)
//
//                // rename folder if exists
//                if user.containChildNotebooks {
//                    // rename folder
//                    FilesHelper.shared.renameFolder(new: editingFileName, old: user.name, folderPath: path)
//                }
//
//                // store name
//                user.name = editingFileName
//
//                // rename in plist
//                usersState.usersDB.saveObject()
            }
        }
    }
    
}

struct GroupedView: View {
    
    let level: [Int]
    let index: Int
    
    @Binding var user: NotebookM
    
    @Binding var selectedMode: Mode
    
    @Binding var selectedUser: NotebookM?
    
    @Binding var draggedItem: NotebookM?
    
    @Binding var userSelectionState: UserSelectionState?
    
    var body: some View {
        
        DisclosureGroup(isExpanded: $user.isSelected) {

            NotesListView(levels: level + [index], parentUser: user, users: $user.children.unwrap()!, selectedUser: $selectedUser, draggedItem: $draggedItem, selectedMode: $selectedMode, userSelectionState: $userSelectionState)
            
        } label: {
            HeadingView(levels: level, index: index, selectedMode: $selectedMode, user: $user, userSelectionState: $userSelectionState, selectedUser: $selectedUser, draggedItem: $draggedItem)
        }
    }
    
}


struct MyDropDelegate : DropDelegate {
    
    let item : NotebookM
    
    @Binding var items : [NotebookM]
    
    @Binding var draggedItem : NotebookM?
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }
        
        if draggedItem != item {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: item)!
            withAnimation(.default) {
                self.items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
}


struct DragInfo {
    let levels: [Int]
    let index: Int
}

extension DragInfo: Equatable {
    static func == (lhs: DragInfo, rhs: DragInfo) -> Bool {
        return lhs.levels == rhs.levels && lhs.index == rhs.index
    }
}

extension DragInfo: Codable {
    
    enum CodingKeys: String, CodingKey {
        case levels
        case index
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(levels, forKey: .levels)
        try container.encode(index, forKey: .index)
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        levels = try! container.decode([Int].self, forKey: .levels)
        index = try! container.decode(Int.self, forKey: .index)
    }
    
}


// MARK:- Methods
func convertModelToData(model: DragInfo) -> NSItemProvider? {
    do {
        let dataBlob = try PropertyListEncoder().encode(model)
        return NSItemProvider(item: dataBlob as NSData, typeIdentifier: UTType.text.identifier)
    } catch let error {
        print("Error: \(error.localizedDescription)")
    }
    return nil
}



struct TaskDropDelegate: DropDelegate {
    // MARK:- Properties
//    @Binding var selectedIndex: Int
    
    var dropInfo: DragInfo
    
    @Binding var draggedItem: NotebookM?
    
    @Binding var array: [NotebookM]
    
//    var taskType: TaskType
//    var viewModel: HomeVM
    
    // MARK:- Methods
    func performDrop(info: DropInfo) -> Bool {
        print(#function)
        
        print(info)
        
        
        guard info.hasItemsConforming(to: [UTType.text.identifier]) else {
            return false
        }
        let items = info.itemProviders(for: [UTType.text.identifier])
        guard let item = items.first else {
            return false
        }
        item.loadDataRepresentation(forTypeIdentifier: UTType.text.identifier) { (data, error) in
            guard error == nil else {
                print("Error: ", error.debugDescription)
                return
            }
            guard let responseData = data else {
                return
            }
            do {
                let dragInfo = try PropertyListDecoder().decode(DragInfo.self, from: responseData)
//                print(dragInfo, dropInfo)
                
                /*
                 
                 move content (folders and files) to new place
                 update in plist file
                 update in model
                 update in swiftui array
                 
                 */
                
                
                
                DispatchQueue.main.async {
                    withAnimation() {
                        
                        
                        
//                        UsersState.shared.move(from: dragInfo, to: dropInfo)
                        
//                        // remove from drag
//                        UsersState.shared.deleteUser(levels: dragInfo.levels, index: dragInfo.index)
//
//                        // insert at drop
//
//                        array.move(fromOffsets: IndexSet(integer: dragInfo.index), toOffset: dropInfo.index)
                        
//                        switch dataBlob.taskStatus {
//                        case .upcoming:
//                            guard let index = self.viewModel.tasksArray.upcomingArray.map({ $0.id }).firstIndex(of: dataBlob.id) else {
//                                return
//                            }
//                            self.viewModel.tasksArray.upcomingArray.remove(at: index)
//                        case .inProgress:
//                            guard let index = self.viewModel.tasksArray.inProgressArray.map({ $0.id }).firstIndex(of: dataBlob.id) else {
//                                return
//                            }
//                            self.viewModel.tasksArray.inProgressArray.remove(at: index)
//                        case .completed:
//                            guard let index = self.viewModel.tasksArray.completedArray.map({ $0.id }).firstIndex(of: dataBlob.id) else {
//                                return
//                            }
//                            self.viewModel.tasksArray.completedArray.remove(at: index)
//                        }
//                        self.selectedIndex = taskType.rawValue
//                        dataBlob.taskStatus = TaskType(rawValue: taskType.rawValue) ?? .upcoming
//                        self.array.append(dataBlob)
                    }
                }
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
         
         
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
//        print(#function)
        return DropProposal(operation: .move)
    }
    
    func dropEntered(info: DropInfo) {
        print(#function)
    }
    
    func dropExited(info: DropInfo) {
        print(#function)
    }
}
