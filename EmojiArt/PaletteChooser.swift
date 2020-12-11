//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by peerawat yoouthong on 11/12/2563 BE.
//

import SwiftUI

struct PaletteChooser: View{
    @ObservedObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    
    
    var body: some View{
        HStack{
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label:{EmptyView()})
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}
