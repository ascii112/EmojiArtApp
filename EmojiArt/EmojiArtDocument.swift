//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by peerawat yoouthong on 11/12/2563 BE.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject{
    static let palette: String = "🥐🥯🍞🥖🥨🧀"
    
    // @Published // workaround for property observer problem with property wrappers
    @Published private var emojiArt: EmojiArt
//    private var emojiArt: EmojiArt{
//        willSet{
//            objectWillChange.send()
//        }
//        didSet{
//            UserDefaults.standard.setValue(emojiArt.json, forKey: EmojiArtDocument.untitled)
//        }
//    }
    
    private var autosaveCancellable: AnyCancellable?
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
        autosaveCancellable = $emojiArt.sink { emoji in
            print("\(self.emojiArt.json?.utf8 ?? "nil")")
            UserDefaults.standard.setValue(self.emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
        fecthBackgroundImageData()
    }
    
    private static let untitled = "EmmojiArtDocument.Untitled"
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] {emojiArt.emojis}
    
    // MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat){
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize){
        if let index = emojiArt.emojis.firstIndex(matching: emoji){
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji,by scale: CGFloat){
        if let index = emojiArt.emojis.firstIndex(matching: emoji){
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    var backgroundURL: URL?{
        get{
            emojiArt.backgroundURL
        }
        set{
            emojiArt.backgroundURL = newValue?.imageURL
            fecthBackgroundImageData()
        }
    }
    private var fetchImageCancellable: AnyCancellable?
    func fecthBackgroundImageData(){
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL{
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, urlResponse in UIImage(data: data)}
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \.backgroundImage, on: self)
            
            
            
            
            
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let imageData = try? Data(contentsOf: url){
//                    DispatchQueue.main.async{
//                        if self.emojiArt.backgroundURL == url{
//                            self.backgroundImage = UIImage(data: imageData)
//                        }
//                    }
//                }
//            }
        }
    }
}
extension EmojiArt.Emoji{
    var fontSize: CGFloat {CGFloat(self.size)}
    var location: CGPoint {CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))}
}
