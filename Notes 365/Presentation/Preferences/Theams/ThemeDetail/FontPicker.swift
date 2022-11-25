//
//  FontPicker.swift
//
//  Created by : Tomoaki Yagishita on 2021/01/09
//  © 2021  SmallDeskSoftware
//

#if os(macOS)

import SwiftUI

class FontPickerDelegate {
    var parent: FontPicker

    init(_ parent: FontPicker) {
        self.parent = parent
    }
    
    @objc
    func changeFont(_ id: Any) {
        parent.fontSelected()
    }

}

public struct FontPicker: View {
    let labelString: String
    
    @Binding var font: NSFont
    @State var fontPickerDelegate: FontPickerDelegate? = nil
    
    var didChangeValue: (()->())?
    
    public init(_ label: String, selection: Binding<NSFont>, didChangeValue: (()->())? = nil) {
        self.labelString = label
        self._font = selection
        self.didChangeValue = didChangeValue
    }
    
    func openFontPanel() {
        if NSFontPanel.shared.isVisible {
            NSFontPanel.shared.orderOut(nil)
            return
        }
        
        self.fontPickerDelegate = FontPickerDelegate(self)
        NSFontManager.shared.target = self.fontPickerDelegate
        NSFontPanel.shared.setPanelFont(self.font, isMultiple: false)
        NSFontPanel.shared.orderBack(nil)
    }
    
    public var body: some View {
        HStack {
            Text("\(font.displayName ?? "-") - \(Int(font.pointSize))")  // to improve tap area
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .onTapGesture {
                    openFontPanel()
                }
            
            Spacer()
            Button {
                openFontPanel()
            } label: {
                Image(systemName: "chevron.down")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 280)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray, lineWidth: 1)
                .brightness(0.2)
        )
        
    }
    
    func fontSelected() {
        self.font = NSFontPanel.shared.convert(self.font)
        didChangeValue?()
    }
}

struct FontPicker_Previews: PreviewProvider {
    static var previews: some View {
        FontPicker("font", selection: .constant(NSFont.systemFont(ofSize: 24)))
    }
}


#endif
