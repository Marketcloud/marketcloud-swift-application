import UIKit
import Foundation

//A cache for the downloaded image
//The cache is made of a key:value array, where key is the image's product it and value is the downloaded UIImage data.
open class ImageCache {
    
    fileprivate static var someDict = [Int: UIImage]()
    
    open static func push(_ id:Int, image:UIImage) {
        someDict[id] = image
    }
    
    open static func isInCache(_ id:Int) -> Bool {
        if someDict.index(forKey: id) != nil {
            return true
        } else {
            return false
        }
    }
    
    open static func get(_ id:Int) -> UIImage? {
            return someDict[id]!
    }
    
    open static func emptyCache() {
        someDict.removeAll()
    }
}
