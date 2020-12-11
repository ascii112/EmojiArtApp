//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by peerawat yoouthong on 11/12/2563 BE.
//

import SwiftUI
struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View{
        Group{
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
