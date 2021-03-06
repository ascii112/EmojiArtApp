//
//  ContentView.swift
//  EmojiArt
//
//  Created by peerawat yoouthong on 11/12/2563 BE.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @State private var chosenPalette: String = ""
    var body: some View {
        VStack{
            HStack{
                PaletteChooser(document: document,chosenPalette: $chosenPalette)
                ScrollView(.horizontal){
                    HStack{
                        ForEach(chosenPalette.map {String($0) }, id: \.self){ emoji in
                            Text(emoji)
                                .font(Font.system(size: defaultEmojiSize))
                                .onDrag { NSItemProvider(object: emoji as NSString)}
                        }
                    }
                }
                .onAppear{self.chosenPalette = self.document.defaultPalette }
            }
            GeometryReader{ geometry in
                ZStack{
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(zoomScale)
                            .offset(self.panOffset)
                    )
                    .gesture(self.doubleTapToZoom(in: geometry.size))
                    if self.isLoading{
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    }else{
                        ForEach(self.document.emojis){ emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                                .position(self.position(for: emoji, in: geometry.size))
                                
                        }
                    }
                }
                .clipped()
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(self.document.$backgroundImage, perform: { (image) in
                    self.zoomToFit(image , in: geometry.size)
                })
                .onDrop(of: ["public.image","public.text"], isTargeted: nil, perform: { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2 , y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width , y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / zoomScale , y: location.y / zoomScale)
                    return self.drop(providers: providers, location: location)
                })
            }
        }
    }
    
    var isLoading: Bool{
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat{
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture{
        MagnificationGesture()
            .updating($gestureZoomScale, body: { (lastestGestureScale, gestureZoomScale, transaction) in
                gestureZoomScale = lastestGestureScale
            })
            
            .onEnded { (finalGestureScale) in
            self.steadyStateZoomScale *= finalGestureScale
        }
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize{
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture{
        DragGesture()
            .updating($gesturePanOffset) { lastestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = lastestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            }
        
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture{
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.linear(duration: 1)){
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize){
        if let image = image, image.size.width > 0, image.size.height > 0{
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyStatePanOffset = .zero
            self.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint{
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale , y: location.y * zoomScale)
        location = CGPoint(x: emoji.location.x + size.width/2 , y: emoji.location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width , y: location.y + panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], location: CGPoint) -> Bool{
        var found = providers.loadFirstObject(ofType: URL.self) { (url) in
            print("dropped /\(url)")
            self.document.backgroundURL = url
        }
        if !found{
            found = providers.loadObjects(ofType: String.self, using: { (string) in
                self.document.addEmoji(string, at: location, size: defaultEmojiSize)
            })
        }
        return found
    }
    private let defaultEmojiSize: CGFloat = 40
}
