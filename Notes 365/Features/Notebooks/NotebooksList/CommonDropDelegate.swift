// CommonDropDelegate.swift
// Copyright © Darkness Production. All rights reserved.

import SwiftUI

struct CommonDropDelegate<Item: Equatable>: DropDelegate {
    let currentItem: Item
    var operation: DropOperation = .move
    @Binding var items: [Item]
    @Binding var draggedItem: Item?
    var onEntered: ((Bool) -> ()) = { _ in }
    var onExit: (() -> ()) = {}
    var onPerform: (() -> ()) = {}

    func performDrop(info: DropInfo) -> Bool {
        onPerform()
        withAnimation { draggedItem = nil }
        return true
    }

    func dropExited(info: DropInfo) { onExit() }

    
    
    func dropUpdated(info: DropInfo) -> DropProposal? { .init(operation: operation)
    }

    func validateDrop(info: DropInfo) -> Bool {
        print(#function)
        return true
    }

    func dropEntered(info: DropInfo) {
        print(#function)
        guard
            let draggedItem = draggedItem,
            draggedItem != currentItem,
            let fromIndex = items.firstIndex(of: draggedItem),
            let toIndex = items.firstIndex(of: currentItem)
        else {
            print("else -- false")
            onEntered(false)
            return
        }
        withAnimation {
            
//            self.items.insert(draggedItem, at: toIndex + 1)
            
            self.items.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
        }
        onEntered(true)
    }
}
