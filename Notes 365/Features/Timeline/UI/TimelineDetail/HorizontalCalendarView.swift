//
//  HorizontalCalendarView.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import SwiftUI



struct HorizontalCalendarView: View {
    @Binding var state: TimelineBaseViewState
    
    func makeAsSelected(_ item: any TopFilterOption) {
        state.selectedFilterOption = item
//        if var newDateRangeFilter = item as? TimelineDateRange {
////            newDateRangeFilter.dateRange = state.getDates(for: newDateRangeFilter)
//            state.selectedFilterOption = newDateRangeFilter
//        } else {
//            state.selectedFilterOption = item
//        }
    }
    
    func selectedStateColor(_ item: any TopFilterOption) -> Color {
        state.isSelected(input: item) ? item.filterType.iconColor.opacity(0.08) : Color.clear
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(state.filterOptions, id: \.id) { item in
                        VStack {
                            if item is SeperatorOption {
                                Text("   ")
                            } else {
                                if state.isSelected(input: item) {
                                    Button {
                                        makeAsSelected(item)
                                    } label: {
                                        Text(item.title)
    //                                    Label(item.title, systemImage: item.filterType.icon)
                                    }
                                    .buttonStyle(.borderedProminent)
                                } else {
                                    Button {
                                        makeAsSelected(item)
                                    } label: {
                                        Text(item.title)
    //                                    Label(item.title, systemImage: item.filterType.icon)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            
                        }
                        .padding(5)
                        .id(item.id)
                    }
                }
                .padding(.horizontal)
//                .buttonStyle(PrimaryButtonStyle())
            }
            .onAppear {
                // scroll to selected
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    withAnimation {
                        scrollProxy.scrollTo(state.selectedFilterOption.id, anchor: .center)
                    }
                }
            }
        }
    }
}



/*
 struct HorizontalCalendarView: View {
     @Binding var state: TimelineBaseViewState
     
     func makeAsSelected(_ item: any TopFilterOption) {
         if var newDateRangeFilter = item as? TimelineDateRange {
             newDateRangeFilter.dateRange = state.getDates(for: newDateRangeFilter)
             state.selectedFilterOption = newDateRangeFilter
         } else {
             state.selectedFilterOption = item
         }
     }
     
     func selectedStateColor(_ item: any TopFilterOption) -> Color {
         state.isSelected(input: item) ? item.filterType.iconColor.opacity(0.08) : Color.clear
     }
     
     var body: some View {
         ScrollViewReader { scrollProxy in
             ScrollView(.horizontal, showsIndicators: false) {
                 HStack {
                     
                     ForEach(state.filterOptions, id: \.id) { item in
                         VStack {
                             if state.isSelected(input: item) {
                                
                                 Button {
                                     makeAsSelected(item)
                                 } label: {
                                     Label {
                                         Text(item.title)
                                             .foregroundColor(.primary)
                                             .colorInvert()
                                     } icon: {
                                         Image(systemName: item.filterType.icon)
                                             .foregroundColor(.primary)
                                             .colorInvert()
                                     }
                                     .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                                     .overlay(
                                         RoundedRectangle(cornerRadius: 60).stroke(item.filterType.iconColor, lineWidth: 1.5)
                                     )
                                 }
                                 .background(item.filterType.iconColor)
                                 .cornerRadius(60)
                                 
                                
                                 
                             } else {
                                 
                                 Button {
                                     makeAsSelected(item)
                                 } label: {
                                     Label {
                                         Text(item.title)
                                     } icon: {
                                         Image(systemName: item.filterType.icon)
                                             .foregroundColor(item.filterType.iconColor)
                                     }
                                     .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
 //                                    .border(item.filterType.iconColor.opacity(0.2))
                                     .overlay(
                                         RoundedRectangle(cornerRadius: 60).stroke(item.filterType.iconColor.opacity(0.6), lineWidth: 1.5)
                                     )
                                 }
                                 .foregroundColor(.primary)
                                 .cornerRadius(60)
                             }
                         }
                         .padding(5)
                         .id(item.id)
                     }
                 }
                 .padding(.horizontal)
 //                .buttonStyle(PrimaryButtonStyle())
             }
             .onAppear(perform: {
                 state.constructFilterItemsIfRequired()
             })
         }

     }
 }

 */
