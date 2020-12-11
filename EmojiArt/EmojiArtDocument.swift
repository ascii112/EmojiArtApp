//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by peerawat yoouthong on 11/12/2563 BE.
//

import Foundation
import SwiftUI
class EmojiArtDocument: ObservableObject{
    static let palette: String = "🥐🥯🍞🥖🥨🧀"
    
    // @Published // workaround for property observer problem with property wrappers
    private var emojiArt: EmojiArt{
        willSet{
            objectWillChange.send()
        }
        didSet{
            UserDefaults.standard.setValue(emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
    }
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
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
    
    func setBackgroundURL(_ url: URL?){
        emojiArt.backgroundURL = url?.imageURL
        fecthBackgroundImageData()
    }
    
    func fecthBackgroundImageData(){
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL{
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url){
                    DispatchQueue.main.async{
                        if self.emojiArt.backgroundURL == url{
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}
extension EmojiArt.Emoji{
    var fontSize: CGFloat {CGFloat(self.size)}
    var location: CGPoint {CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))}
}
