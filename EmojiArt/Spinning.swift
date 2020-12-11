//
//  Spinning.swift
//  EmojiArt
//
//  Created by peerawat yoouthong on 11/12/2563 BE.
//

import SwiftUI

struct Spinning: ViewModifier {
    
    @State var isVisible = false
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: isVisible ? 360 : 0))
            .animation(Animation.linear.repeatForever(autoreverses: false))
            .onAppear{ self.isVisible = true}
    }
}
extension View{
    func spinning() -> some View{
        self.modifier(Spinning())
    }
}
