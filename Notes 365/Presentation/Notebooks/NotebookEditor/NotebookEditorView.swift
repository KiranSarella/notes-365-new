//
//  DetailView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 25/06/21.
//

import SwiftUI


struct NotebookEditorView: View {
    
//    var userSelectionState: SelectedNotebookInfo
    
    @Binding var notebookM: NotebookM?
    @StateObject private var editorState = NotebookEditorState()
    @FocusState private var isTextFieldFocused: Bool
    @State var currentTextStyleAction: (TextStyleKey?, Any, Bool) = (.none, false, false)
    @State private var contentEdited = false

  
    @StateObject private var speechHelperState = SpeechHelperState()
   
    var body: some View {
        
        VStack {
            
            if notebookM == nil {
                Text("No notebook selected")
            } else {
                
                VStack(alignment: .leading) {
                    // formatting bar view
                    FormattingOptionsView(currentTextStyleAction: $currentTextStyleAction)
                        .padding()
                    //                .padding([.top, .trailing, .leading], 10)
                        .background(.background)
                    
                    
                    if editorState.isFetchingData {
                        Text("loading..")
                    } else {
                        EditorUI(theme: editorState.theme, text: $editorState.contentStr, currentTextStyleAction: currentTextStyleAction, completion: { txt in
                            
                            // 500000000 = 0.5 sec
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500000000)) {
                                editorState.txt = txt
                                contentEdited = true
                            }
                            //                    DispatchQueue.main.async {
                            //                        self.txt = txt
                            //                        contentEdited = true
                            //                    }
                            //
                            
                            
                        }, actionCompleted: {
                            
                            // 500000000 = 0.5 sec
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500000000)) {
                                currentTextStyleAction = (nil, false, false)
                            }
                            
                        })
                        .font(Font.body)
                        .focused($isTextFieldFocused)
                        .onChange(of: isTextFieldFocused) { isFocused in
                            if isFocused {
                                // began editing...
                                //                            print(isTextFieldFocused)
                                //                            editorState.setBaseVersion(userSelectionState: self.userSelectionState)
                            } else {
                                // ended editing...
                                //                            print(isTextFieldFocused)
                            }
                        }
                    }
                }
                .onAppear(perform: {
                    editorState.loadContent(notebookM!.notebook)
                    //            editorState.loadContent(notebookInfo: self.userSelectionState)
                    // notify
                    var change = currentTextStyleAction.2
                    change.toggle()
                    currentTextStyleAction = (.textUpdate, true, change)
                })
                .onDisappear(perform: {
                    isTextFieldFocused = false
                    if speechHelperState.speechState != .stopped {
                        speechHelperState.speechHelper.stopSpeech()
                        speechHelperState.speechState = .stopped
                    }
                })
                //        .onChange(of: $selectedMode.wrappedValue, perform: { newValue in
                //            isTextFieldFocused = false
                //
                //            if contentEdited {
                //                editorState.saveContentChanges(userSelectionState: self.userSelectionState)
                //            }
                //
                //        })
                //        .onChange(of: self.userSelectionState, perform: { newValue in
                //
                //            if speechHelperState.speechState != .stopped {
                //                speechHelperState.speechHelper.stopSpeech()
                //                speechHelperState.speechState = .stopped
                //            }
                //
                //
                ////            self.notebook = UsersState.shared.getNotebook(levels: newValue.selectedLevels, index: newValue.selectedIndex)
                //
                //            isTextFieldFocused = false
                //
                //            if contentEdited {
                //                editorState.saveContentChanges(userSelectionState: self.userSelectionState)
                //            }
                //
                //            editorState.loadContent(notebookInfo: newValue)
                //            // notify
                //            var change = currentTextStyleAction.2
                //            change.toggle()
                //            currentTextStyleAction = (.textUpdate, true, change)
                //        })
                //        .onChange(of: fontName, perform: { newValue in
                //
                //            var change = currentTextStyleAction.2
                //            change.toggle()
                //            currentTextStyleAction = (.font, fontName, change)
                //        })
                .onReceive(editorState.autoSaveTimer, perform: { _ in
                    //            print("autoSaveTimer")
                    
                    //            if contentEdited {
                    //                editorState.saveContentChanges(userSelectionState: self.userSelectionState)
                    //            }
                    
                })
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("theme.modified"))) { output in
                    guard let newTheme = output.object as? MarkdownTheme else { return }
                    editorState.theme = newTheme
                }
                .onChange(of: editorState.theme, perform: { newValue in
                    
                    var change = currentTextStyleAction.2
                    change.toggle()
                    currentTextStyleAction = (.theme, newValue, change)
                    
                })
                
                .onDisappear(perform: {
                    // when navigating from notebooks to timeline tab
                    //            print("on disappear")
                    
                    if contentEdited {
                        //                editorState.saveContentChanges(userSelectionState: self.userSelectionState)
                    }
                    
                    if speechHelperState.speechState != .stopped {
                        speechHelperState.speechHelper.stopSpeech()
                        speechHelperState.speechState = .stopped
                    }
                })
                .navigationTitle(notebookM?.name ?? "")
                .toolbar {
                    /*
                     //            ScaleFontView(theme: $theme)
                     
                     Button {
                     
                     } label: {
                     Text("pdf")
                     }
                     
                     
                     Button {
                     
                     switch speechHelperState.speechState {
                     
                     case .stopped:
                     var input = editorState.contentStr
                     
                     
                     //                    var attrInput = NSMutableAttributedString()
                     //                    for timeline in timelineList {
                     //
                     //                        if let attrStr = timeline.attriburedString {
                     //                            attrInput.append(NSAttributedString(attrStr))
                     //                        }
                     //                    }
                     
                     
                     speechHelperState.speechHelper.startSpeech(string: input)
                     
                     //                    speechHelper.startSpeech(attributedStting: attrInput)
                     
                     speechHelperState.speechState = .playing
                     
                     speechHelperState.speechHelper.finished = {
                     speechHelperState.speechState = .stopped
                     }
                     
                     case .playing:
                     
                     speechHelperState.speechHelper.pauseSpeech()
                     speechHelperState.speechState = .paused
                     case .paused:
                     speechHelperState.speechHelper.continueSpeech()
                     speechHelperState.speechState = .playing
                     }
                     
                     
                     } label: {
                     Text(speechHelperState.speechState.buttonTitle)
                     }
                     
                     */
                    
                    Toggle("Mode", isOn: $editorState.showSymbols)
                        .toggleStyle(.switch)
                        .help(editorState.showSymbols == false ? "Show Symbols" : "Hide Symbols")
                        .onChange(of: editorState.showSymbols) { newValue in
                            if newValue {
                                editorState.editorType = .markdown
                            } else {
                                editorState.editorType = .smart
                            }
                            
                            //                    print(editorType)
                            
                            var change = currentTextStyleAction.2
                            change.toggle()
                            
                            currentTextStyleAction = (.editorType, editorState.editorType, change)
                        }
                }
                .pickerStyle(SegmentedPickerStyle())
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                
                
            }
            
            
        }
        .onChange(of: notebookM) { newValue in
            
            guard let newValue = newValue else { return }
            
            editorState.loadContent(newValue.notebook)
            //            editorState.loadContent(notebookInfo: self.userSelectionState)
            // notify
            var change = currentTextStyleAction.2
            change.toggle()
            currentTextStyleAction = (.textUpdate, true, change)
        }
        

        
    }
    
    
}

