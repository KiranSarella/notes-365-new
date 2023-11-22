//
//  NotebooksLevelView.swift
//  Notes 365
//
//  Created by kiran ipc on 22/11/23.
//

import SwiftUI

struct Item: Identifiable {
    let id: UUID
    var name: String
    var createdDate: Date = Date()
}

struct NotebookDetailBaseView: View {
    
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            NotebooksLevelView(path: $path)
        }
//        .onDisappear {
//            path = NavigationPath()
//        }
    }
}

struct NotebooksLevelView: View {
    
    let folders = [Item(id: UUID(), name: "sorting algorithms"),
                   Item(id: UUID(), name: "searcing algorithms"),
                   Item(id: UUID(), name: "string algorithms")]
    
    let files = [Item(id: UUID(), name: "double linked list"),
                Item(id: UUID(), name: "queue"),
                Item(id: UUID(), name: "b+ tree")]
    
    let fruits: [Fruit] = [
        Fruit(name: "apple", color: .green),
        Fruit(name: "orange", color: .orange),
        Fruit(name: "teal", color: .teal),
        Fruit(name: "grape", color: .purple),
        Fruit(name: "papaya", color: .yellow),
        Fruit(name: "pineapple", color: .green),
        Fruit(name: "apple", color: .red)
    ]
    
    var items: [GridItem] {
      Array(repeating: .init(.adaptive(minimum: 120)), count: 10)
    }
    
    var columns = Array(repeating: GridItem(), count: 3)
    
    var navigationTitle: String = "Algorithms"
    
    let rows = [
           GridItem(.fixed(30), spacing: 1),
           GridItem(.fixed(60), spacing: 10),
           GridItem(.fixed(90), spacing: 20),
           GridItem(.fixed(10), spacing: 50)
       ]
    
    @Binding var path: NavigationPath
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack {
                LazyVGrid(columns: columns) {
                    ForEach(fruits) { fruit in
                        NavigationLink(value: fruit) {
                            FruitCellView(fruit: fruit)
                                .border(.yellow, width: 2)
//                                .clipShape(.capsule)
                                .padding()
                        }
                        
//                            NavigationLink {
//
//                            } label: {
//                                FruitCellView(fruit: fruit)
//                                    .border(.yellow, width: 2)
//    //                                .clipShape(.capsule)
//                                    .padding()
//                            }
                    }
                }
                Spacer()
            }.padding()
            
            VStack {
                ForEach(fruits) { fruit in
                    FruitCellView(fruit: fruit)
                        .border(.yellow, width: 2)
                        .padding()
                }
            }.padding(.horizontal)
        }
        .navigationTitle(navigationTitle)
        .navigationDestination(for: Fruit.self) { fruit in
            NotebooksLevelView(navigationTitle: fruit.name, path: $path)
        }
            
        
    }
}
//
//#Preview {
//    NotebooksLevelView()
//}

struct FolderSection: View {
    
    let items:[Item]
    
    var body: some View {
        Text("asdf")
    }
}

struct Fruit: Identifiable {
    let id: UUID = UUID()
    let name: String
    let color: Color
}

extension Fruit: Hashable {
    
}

struct FruitCellView: View {
    let fruit: Fruit

    var body: some View {
        HStack {
            Text(fruit.name)
                .font(.body)
            Spacer()
            Circle()
                .fill(fruit.color)
                .frame(width: 40, height: 40)
        }
        .padding()
    }
}

